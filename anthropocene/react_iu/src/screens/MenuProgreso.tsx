import React, { useState, useEffect } from 'react';
import { DiskIcon, ClockIcon, MapIcon, WarningIcon } from '../components/Icons';
import { CornerVine } from '../components/CornerVine';
import { PixelArtThumbnail } from '../components/PixelArtThumbnail';
import { GRID_DOTS } from '../constants';
import { godotBridge } from '../services/godotBridge';

export interface SaveDataProps {
  location: string;
  date: string;
  time: string;
  playtime: string;
  progress: number;
}

interface MenuProgresoProps {
  saveData: SaveDataProps | null;
}

export function MenuProgreso({ saveData }: MenuProgresoProps) {
  const [loading, setLoading] = useState(false);
  const [mouse, setMouse] = useState({ x: 0, y: 0 });

  const hasSaveData = saveData !== null;

  useEffect(() => {
    let frame: number | null = null;
    function handleMouseMove(e: MouseEvent) {
      if (frame !== null) return;
      frame = requestAnimationFrame(() => {
        setMouse({ x: e.clientX / window.innerWidth - 0.5, y: e.clientY / window.innerHeight - 0.5 });
        frame = null;
      });
    }
    window.addEventListener('mousemove', handleMouseMove);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      if (frame !== null) cancelAnimationFrame(frame);
    };
  }, []);

  function handleContinue() {
    setLoading(true);
    // Le indicamos al juego que cargue el nivel guardado
    godotBridge.send('CONTINUE_GAME');
  }

  function handleNewGame() {
    if (hasSaveData) {
      const confirmOverwrite = window.confirm('¿Sobrescribir los datos locales actuales? Todo el progreso se perderá.');
      if (!confirmOverwrite) return;
    }
    setLoading(true);
    // Le ordenamos a Godot resetear el archivo JSON de guardado
    godotBridge.send('NEW_GAME');
  }

  // TODO TU RENDERIZADO VISUAL CON PARALLAX Y CORNER VINES SE MANTIENE 100% IGUAL...
  return (
    <div style={{ minHeight: '100vh', width: '100%', background: 'radial-gradient(circle at center, #1C1F16 0%, #0D0F0A 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative', overflow: 'hidden', fontFamily: "'Rajdhani', sans-serif" }}>
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none', transform: `translate3d(${mouse.x * -10}px, ${mouse.y * -10}px, 0)`, transition: 'transform 0.35s cubic-bezier(0.22, 1, 0.36, 1)' }}>
        <div className="bg-image-drift" style={{ position: 'absolute', inset: '-24px', backgroundImage: "url('/assets/camino.png')", backgroundSize: 'cover', backgroundPosition: 'center', filter: 'brightness(0.38) saturate(0.65) contrast(1.05)' }} />
      </div>
      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(13,15,10,0.55) 0%, rgba(13,15,10,0.72) 45%, rgba(13,15,10,0.92) 100%)', pointerEvents: 'none' }} />
      
      <div className="panel-anim" style={{ position: 'relative', zIndex: 10, width: 'min(500px, calc(100vw - 32px))' }}>
        <div className="panel-glow" style={{ position: 'relative', background: 'rgba(22, 24, 18, 0.95)', border: '4px solid #706533' }}>
          <CornerVine corner="tl" delay={0.55} />
          <CornerVine corner="tr" delay={0.7} />
          <CornerVine corner="bl" delay={0.85} />
          <CornerVine corner="br" delay={1.0} />

          <div style={{ borderBottom: '2px solid #706533', background: 'rgba(112, 101, 51, 0.15)', padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ color: '#B2A99C' }}><DiskIcon /></div>
            <span style={{ fontFamily: "'Share Tech Mono', monospace", fontSize: '11px', color: hasSaveData ? '#F49162' : '#706533' }}>
              {hasSaveData ? 'ARCHIVO ENCONTRADO' : 'MEMORIA VACÍA'}
            </span>
          </div>

          <div style={{ padding: '32px 28px' }}>
            <div style={{ textAlign: 'center', marginBottom: '28px' }}>
              <span style={{ fontFamily: "'Orbitron', monospace", fontWeight: 900, fontSize: '22px', letterSpacing: '4px', color: '#ffffff' }}>PROGRESO DEL DEMO</span>
            </div>

            {hasSaveData ? (
              <>
                <div style={{ background: 'rgba(112, 101, 51, 0.1)', border: '2px solid #4E4133', padding: '16px', marginBottom: '24px', display: 'flex', gap: '16px' }}>
                  <div style={{ flexShrink: 0, width: '80px', height: '80px', border: '2px solid #706533' }}><PixelArtThumbnail /></div>
                  <div style={{ flexGrow: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                    <div style={{ fontFamily: "'Orbitron', monospace", fontSize: '12px', color: '#ffffff', letterSpacing: '1px', marginBottom: '8px' }}>{saveData.location}</div>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', fontFamily: "'Share Tech Mono', monospace", fontSize: '11px', color: '#B2A99C' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}><ClockIcon /> {saveData.playtime}</div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}><MapIcon /> {saveData.date}</div>
                    </div>
                    <div style={{ marginTop: '12px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontFamily: "'Share Tech Mono', monospace", fontSize: '10px', color: '#706533', marginBottom: '4px' }}>
                        <span>SECTOR COMPLETADO</span>
                        <span style={{ color: '#F49162' }}>{saveData.progress}%</span>
                      </div>
                      <div style={{ width: '100%', height: '6px', background: '#1C1F16', border: '1px solid #4E4133' }}>
                        <div style={{ height: '100%', background: '#F49162', width: `${saveData.progress}%`, transition: 'width 1s ease-out' }} />
                      </div>
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  <button onClick={handleContinue} disabled={loading} style={{ width: '100%', background: loading ? '#4E4133' : '#F49162', color: loading ? '#B2A99C' : '#1C1F16', fontFamily: "'Orbitron', monospace", fontWeight: 700, fontSize: '14px', letterSpacing: '2px', padding: '16px', border: '2px solid #ffffff', cursor: loading ? 'not-allowed' : 'pointer' }}>
                    {loading ? 'SINCRONIZANDO...' : 'CONTINUAR DEMO'}
                  </button>
                  <button onClick={handleNewGame} disabled={loading} style={{ width: '100%', background: 'transparent', color: '#B2A99C', fontFamily: "'Share Tech Mono', monospace", fontSize: '13px', padding: '12px', border: '2px dashed #4E4133', cursor: loading ? 'not-allowed' : 'pointer' }}>
                    NUEVA PARTIDA
                  </button>
                </div>
              </>
            ) : (
              <>
                <div style={{ textAlign: 'center', padding: '32px 0 40px', border: '2px dashed #4E4133', marginBottom: '24px', background: 'rgba(112, 101, 51, 0.05)' }}>
                  <div style={{ color: '#706533', marginBottom: '12px', display: 'flex', justifyContent: 'center' }}><WarningIcon /></div>
                  <div style={{ fontFamily: "'Orbitron', monospace", fontSize: '14px', color: '#ffffff', letterSpacing: '1px', marginBottom: '8px' }}>NO HAY DATOS LOCALES</div>
                  <div style={{ fontFamily: "'Share Tech Mono', monospace", fontSize: '12px', color: '#B2A99C', maxWidth: '80%', margin: '0 auto' }}>No se detectó progreso previo en el juego actual. El ecosistema espera tu intervención.</div>
                </div>
                <button onClick={handleNewGame} disabled={loading} style={{ width: '100%', background: loading ? '#4E4133' : '#706533', color: '#ffffff', fontFamily: "'Orbitron', monospace", fontWeight: 700, fontSize: '14px', letterSpacing: '2px', padding: '16px', border: '2px solid #8a7a40', cursor: loading ? 'not-allowed' : 'pointer' }}>
                  {loading ? 'GENERANDO ENTORNO...' : 'INICIAR NUEVA PARTIDA'}
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}