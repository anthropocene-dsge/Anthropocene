import React from 'react';
import { GRID_DOTS } from '../constants';

export function LoadingScreen() {
  return (
    <div style={{ minHeight: '100vh', width: '100%', background: '#0D0F0A', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative', overflow: 'hidden', fontFamily: "'Rajdhani', sans-serif" }}>
      {/* Fondo y scanlines */}
      <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle, rgba(112, 101, 51, 0.08) 0%, transparent 70%)' }} />
      <svg aria-hidden="true" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.5 }}>
        {GRID_DOTS.filter((d) => d.op > 0).map((d) => (
          <rect key={d.id} x={`${d.x}%`} y={`${d.y}%`} width="2" height="2" fill="#706533" opacity={d.op} />
        ))}
      </svg>
      <div style={{ position: 'absolute', left: 0, right: 0, height: '180px', background: 'linear-gradient(to bottom, transparent 0%, rgba(112,101,51,0.06) 50%, transparent 100%)', animation: 'scroll-scanline 6s linear infinite' }} />

      {/* Contenido de Carga */}
      <div style={{ textAlign: 'center', zIndex: 10 }}>
        <div style={{ width: '60px', height: '60px', border: '2px solid #706533', borderTopColor: '#F49162', borderRadius: '50%', margin: '0 auto 24px', animation: 'spin 1s linear infinite' }} />
        <style>{`@keyframes spin { 100% { transform: rotate(360deg); } }`}</style>
        
        <h2 style={{ fontFamily: "'Orbitron', monospace", color: '#ffffff', fontSize: '18px', letterSpacing: '4px', textTransform: 'uppercase', marginBottom: '8px' }}>
          Sincronizando Sistema
        </h2>
        <p style={{ fontFamily: "'Share Tech Mono', monospace", color: '#B2A99C', fontSize: '12px', letterSpacing: '2px', textTransform: 'uppercase' }}>
          Consultando registros locales de progreso...
          <span style={{ display: 'inline-block', width: '8px', background: '#F49162', height: '11px', marginLeft: '4px', animation: 'blink-cursor 1s step-end infinite' }} />
        </p>
      </div>
    </div>
  );
}