/**
 * Servicio encargado de enviar mensajes desde React hacia el motor Godot.
 * Detecta automáticamente el canal disponible según el sistema operativo (Windows/macOS).
 */

declare global {
  interface Window {
    chrome?: {
      webview: {
        postMessage: (message: any) => void;
      };
    };
    webkit?: {
      messageHandlers: {
        godot: {
          postMessage: (message: any) => void;
        };
      };
    };
    recibirMensajeDesdeGodot?: (jsonStr: string) => void;
  }
}

type BridgeMessage = { type: string; payload?: any };
type MessageCallback = (payload: any) => void;

class GodotBridge {
  private listeners: Map<string, MessageCallback[]> = new Map();

  constructor() {
    // Escucha lo que Godot le inyecta a React
    window.recibirMensajeDesdeGodot = (jsonStr: string) => {
      try {
        const data: BridgeMessage = JSON.parse(jsonStr);
        const callbacks = this.listeners.get(data.type);
        if (callbacks) {
          callbacks.forEach(cb => cb(data.payload));
        }
      } catch (e) {
        console.error("[REACT BRIDGE] Error al parsear mensaje de Godot", e);
      }
    };
  }

  // Método para enviar mensajes a Godot
public send(type: string, payload?: any) {
    const message = JSON.stringify({ type, payload });
    
    try {
      // 1. Canal estándar para plugins IPC de Godot (GDExtension / CEF / WebView)
      if ((window as any).godot?.postMessage) {
        (window as any).godot.postMessage(message);
      }
      // 2. Variante directa que usan algunos envoltorios nativos
      else if ((window as any).ipc?.postMessage) {
        (window as any).ipc.postMessage(message);
      }
      // 3. Ecosistema macOS nativo (WKWebView)
      else if (window.webkit?.messageHandlers?.godot) {
        window.webkit.messageHandlers.godot.postMessage(message);
      } 
      // 4. Ecosistema Windows nativo (WebView2)
      else if (window.chrome?.webview) {
        window.chrome.webview.postMessage(message);
      } 
      else {
        console.warn("[BRIDGE WARN] Sin canal nativo detectable:", message);
      }
    } catch (e) {
      console.error("[BRIDGE ERROR] Error crítico al emitir mensaje hacia Godot:", e);
    }
  }

  // Método para que las pantallas escuchen las respuestas de Godot
  public subscribe(type: string, callback: MessageCallback) {
    if (!this.listeners.has(type)) {
      this.listeners.set(type, []);
    }
    this.listeners.get(type)?.push(callback);
    
    // Función desuscriptora (para evitar memory leaks en useEffect)
    return () => {
      const list = this.listeners.get(type) || [];
      this.listeners.set(type, list.filter(cb => cb !== callback));
    };
  }
}

export const godotBridge = new GodotBridge();