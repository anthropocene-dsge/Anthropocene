import React, { useState, useEffect } from 'react';
import { UserIcon, LockIcon, EyeIcon, AlertIcon, SolarPanelIcon } from '../components/Icons';
import { InputRow } from '../components/InputRow';
import { GRID_DOTS } from '../constants';
import { godotBridge } from '../services/godotBridge';

interface LoginScreenProps {
  onAccessGranted: () => void;
}

export function LoginScreen({ onAccessGranted }: LoginScreenProps) {
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPass, setShowPass] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [shaking, setShaking] = useState(false);
  const [activeTab, setActiveTab] = useState('solar');
  const [mouse, setMouse] = useState({ x: 0, y: 0 });

  // Escuchar la validación que viene desde el JSON de Godot
  useEffect(() => {
    const unsubscribe = godotBridge.subscribe('LOGIN_RESPONSE', (payload: { success: boolean; error?: string }) => {
      setLoading(false);
      if (payload.success) {
        setSuccess(true);
        setTimeout(() => onAccessGranted(), 3000);
      } else {
        setError('ERROR DE CONEXIÓN: Credenciales desconocidas en este cuadrante.');
        setShaking(true);
        setTimeout(() => setShaking(false), 500);
      }
    });
    return unsubscribe;
  }, [onAccessGranted]);

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

function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (loading || success) return;
    setError('');

    if (identifier.trim() === '' || password === '') {
      setError('CRÍTICO: completa todos los campos antes de continuar');
      setShaking(true);
      setTimeout(() => setShaking(false), 500);
      return;
    }

    setLoading(true);
    
    // Enviamos de forma limpia el evento y los datos al Bridge que ya corregimos
    godotBridge.send('LOGIN_REQUEST', { 
      username: identifier.trim(), 
      password: password 
    });
  }

  return (
    <div style={{ minHeight: '100vh', width: '100%', background: 'radial-gradient(circle at center, #1C1F16 0%, #0D0F0A 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative', overflow: 'hidden', fontFamily: "'Rajdhani', sans-serif" }}>
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none', transform: `translate3d(${mouse.x * -10}px, ${mouse.y * -10}px, 0)`, transition: 'transform 0.35s cubic-bezier(0.22, 1, 0.36, 1)', willChange: 'transform' }}>
        <div className="bg-image-drift" style={{ position: 'absolute', inset: '-24px', backgroundImage: "url('/assets/camino.png')", backgroundSize: 'cover', backgroundPosition: 'center', filter: 'brightness(0.38) saturate(0.65) contrast(1.05)', imageRendering: 'pixelated' }} />
      </div>

      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(13,15,10,0.55) 0%, rgba(13,15,10,0.72) 45%, rgba(13,15,10,0.92) 100%)', pointerEvents: 'none' }} />

      <div style={{ position: 'absolute', width: '500px', height: '500px', background: 'radial-gradient(circle, rgba(112, 101, 51, 0.15) 0%, transparent 70%)', pointerEvents: 'none', transform: `translate3d(${mouse.x * -50}px, ${mouse.y * -50}px, 0)`, transition: 'transform 0.35s cubic-bezier(0.22, 1, 0.36, 1)', willChange: 'transform' }} />

      <svg aria-hidden="true" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.7, pointerEvents: 'none', transform: `translate3d(${mouse.x * -18}px, ${mouse.y * -18}px, 0)`, transition: 'transform 0.35s cubic-bezier(0.22, 1, 0.36, 1)', willChange: 'transform' }}>
        {GRID_DOTS.filter((d) => d.op > 0).map((d) => (
          <rect key={d.id} x={`${d.x}%`} y={`${d.y}%`} width="2" height="2" fill={d.op > 0.2 ? '#F49162' : '#706533'} opacity={d.op} />
        ))}
      </svg>

      <div aria-hidden="true" style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 1 }}>
        <div style={{ position: 'absolute', left: 0, right: 0, height: '180px', background: 'linear-gradient(to bottom, transparent 0%, rgba(112,101,51,0.06) 50%, transparent 100%)', animation: 'scroll-scanline 6s linear infinite' }} />
      </div>

      <div style={{ position: 'fixed', top: '24px', left: '40px', display: 'flex', alignItems: 'center', gap: '10px', color: '#706533', fontFamily: "'Share Tech Mono', monospace", fontSize: '11px', zIndex: 5, letterSpacing: '1px' }}>
        <span>LOGIN.EXE — AUTH MODULE</span>
      </div>

      <div style={{ position: 'fixed', bottom: '24px', left: '40px', color: '#4E4133', fontFamily: "'Share Tech Mono', monospace", fontSize: '11px', zIndex: 5 }}>
        CO2 ATMOSFÉRICO: <span className="hud-glow-text" style={{ color: '#F49162' }}>280 PPM (ESTABLE)</span>
      </div>

      <div className={`login-panel${shaking ? ' shake' : ''}`} style={{ position: 'relative', zIndex: 10, width: 'min(450px, calc(100vw - 32px))' }}>
        <div className="panel-glow" style={{ position: 'relative', background: 'rgba(22, 24, 18, 0.95)', border: '4px solid #706533' }}>
          <div style={{ borderBottom: '2px solid #706533', background: 'rgba(112, 101, 51, 0.15)', padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', gap: '6px' }}>
              <button type="button" onClick={() => setActiveTab('solar')} style={{ background: activeTab === 'solar' ? '#706533' : 'transparent', border: '1px solid #706533', color: activeTab === 'solar' ? '#fff' : '#B2A99C', cursor: 'pointer', fontSize: '10px', fontFamily: "'Orbitron', monospace", padding: '3px 8px' }}>SOLAR_NET</button>
              <button type="button" onClick={() => setActiveTab('wind')} style={{ background: activeTab === 'wind' ? '#706533' : 'transparent', border: '1px solid #706533', color: activeTab === 'wind' ? '#fff' : '#B2A99C', cursor: 'pointer', fontSize: '10px', fontFamily: "'Orbitron', monospace", padding: '3px 8px' }}>EÓLICA_NET</button>
            </div>
            <span style={{ fontFamily: "'Share Tech Mono', monospace", fontSize: '11px', color: '#F49162' }}>{activeTab === 'solar' ? ' +4.8kW' : '+6.2kW'}</span>
          </div>

          <div style={{ padding: '32px 28px' }}>
            {!success && (
              <div style={{ textAlign: 'center', marginBottom: '28px' }}>
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
                  <SolarPanelIcon />
                  <span style={{ fontFamily: "'Orbitron', monospace", fontWeight: 900, fontSize: '24px', letterSpacing: '4px', color: '#ffffff' }}>ANTHROPOCENE</span>
                </div>
                <div style={{ fontFamily: "'Orbitron', monospace", fontSize: '11px', color: '#F49162', letterSpacing: '2.5px', fontWeight: 600, marginTop: '4px' }}>SOBREVIVE · RESTAURA · RECONECTA</div>
                <div style={{ width: '100%', height: '4px', background: '#4E4133', position: 'relative', marginTop: '14px' }}>
                  <div style={{ position: 'absolute', left: 0, top: 0, height: '100%', width: '74%', background: 'linear-gradient(90deg, #706533, #F49162)' }} />
                </div>
                <div style={{ fontFamily: "'Share Tech Mono', monospace", fontSize: '11px', color: '#B2A99C', letterSpacing: '2px', marginTop: '10px', textTransform: 'uppercase' }}>
                  acceso al ecosistema
                  <span style={{ display: 'inline-block', width: '8px', background: '#F49162', height: '11px', marginLeft: '4px', animation: 'blink-cursor 1s step-end infinite', verticalAlign: 'middle' }} />
                </div>
              </div>
            )}

            {success ? (
              <div style={{ textAlign: 'center', padding: '20px 0', animation: 'ecosystem-grow 0.8s ease-out forwards' }}>
                <div style={{ width: '85px', height: '85px', border: '2px solid #706533', margin: '0 auto 30px', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 25px rgba(112, 101, 51, 0.15), inset 0 0 15px rgba(112, 101, 51, 0.1)', background: 'transparent', borderRadius: '4px' }}>
                  <span style={{ fontSize: '44px', lineHeight: 1, filter: 'drop-shadow(0 0 15px rgba(124, 179, 66, 0.5))', userSelect: 'none' }}>🌱</span>
                </div>
                <div style={{ fontFamily: "'Orbitron', monospace", fontWeight: 600, fontSize: '20px', letterSpacing: '5px', color: '#8A7A40', marginBottom: '28px', textTransform: 'uppercase', textShadow: '0 0 15px rgba(138, 122, 64, 0.6)' }}>
                  Acceso Concedido
                </div>
                <div style={{ fontFamily: "'Share Tech Mono', monospace", fontSize: '20px', color: '#D1D5D1', letterSpacing: '1px', marginBottom: '16px', textShadow: '0 0 8px rgba(209, 213, 209, 0.3)' }}>
                  Bienvenido, <span style={{ color: '#F5F7F5', fontWeight: 'bold', textShadow: '0 0 10px rgba(245, 247, 245, 0.4)' }}>{identifier}</span>
                </div>
                <div style={{ fontFamily: "'Share Tech Mono', monospace", fontSize: '16px', color: '#5C5E58', letterSpacing: '1px', marginBottom: '25px', textShadow: '0 0 8px rgba(92, 94, 88, 0.4)' }}>
                  Iniciando protocolo de supervivencia...
                </div>
                <div style={{ display: 'flex', gap: '6px', justifyContent: 'center' }}>
                  {[...Array(5)].map((_, i) => (
                    <div key={i} style={{ width: '6px', height: '6px', background: '#7CB342', boxShadow: '0 0 8px #7CB342', animation: `blink-cursor 0.8s ease infinite ${i * 0.15}s` }} />
                  ))}
                </div>
              </div>
            ) : (
              <form onSubmit={handleSubmit} noValidate>
                <InputRow id="identifier" label="Identificador de Colono" type="text" value={identifier} onChange={(v) => { setIdentifier(v); setError(''); }} placeholder="tu_nombre_usuario" icon={<UserIcon />} disabled={loading} />
                <InputRow id="password" label="Código de Acceso" type={showPass ? 'text' : 'password'} value={password} onChange={(v) => { setPassword(v); setError(''); }} placeholder="Introduce tu clave de acceso..." icon={<LockIcon />} disabled={loading} suffix={
                  <button type="button" onClick={() => setShowPass((v) => !v)} aria-label={showPass ? 'Ocultar' : 'Mostrar'} style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: '#706533', padding: '4px', display: 'flex', alignItems: 'center' }}>
                    <EyeIcon off={showPass} />
                  </button>
                } />

                <div style={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', marginTop: '-8px', marginBottom: '24px' }}>
                  <a href="#recovery" onClick={(e) => e.preventDefault()} style={{ fontFamily: "'Share Tech Mono', monospace", fontSize: '12px', color: '#7A7F7D', textDecoration: 'none', borderBottom: '1px dashed #706533', transition: 'color 0.2s' }} onMouseEnter={(e) => (e.currentTarget.style.color = '#F49162')} onMouseLeave={(e) => (e.currentTarget.style.color = '#7A7F7D')}>¿Olvidaste tu contraseña?</a>
                </div>

                {error && (
                  <div role="alert" style={{ display: 'flex', alignItems: 'flex-start', gap: '10px', background: 'rgba(192,57,43,0.15)', border: '2px solid #c0392b', padding: '12px', marginBottom: '22px', color: '#ffffff', fontFamily: "'Share Tech Mono', monospace", fontSize: '12px', lineHeight: 1.4 }}>
                    <span style={{ color: '#F49162', flexShrink: 0 }}><AlertIcon /></span>
                    <span>{error}</span>
                  </div>
                )}

                <button type="submit" disabled={loading} style={{ width: '100%', background: loading ? '#4E4133' : '#706533', color: '#ffffff', fontFamily: "'Orbitron', monospace", fontWeight: 700, fontSize: '12px', letterSpacing: '3px', textTransform: 'uppercase', padding: '16px', border: '2px solid #8a7a40', borderRadius: '0px', cursor: loading ? 'not-allowed' : 'pointer', transition: 'all 0.2s cubic-bezier(0.1, 0.8, 0.2, 1)', marginBottom: '24px', boxShadow: '0 4px 0px #4E4133' }}>
                  {loading ? 'VERIFICANDO CREDENCIALES...' : 'INICIAR JUEGO'}
                </button>

                <p style={{ textAlign: 'center', fontFamily: "'Share Tech Mono', monospace", fontSize: '12px', color: '#7A7F7D', margin: 0 }}>
                  ¿Nuevo en el ecosistema?{' '}
                  <a href="#register" onClick={(e) => e.preventDefault()} style={{ color: '#F49162', textDecoration: 'none', fontWeight: 'bold', borderBottom: '1px solid #F49162', paddingBottom: '1px' }}>Registrar Nuevo Colono</a>
                </p>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}