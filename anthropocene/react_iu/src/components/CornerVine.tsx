import React from 'react';

interface CornerVineProps {
  corner: 'tl' | 'tr' | 'bl' | 'br';
  delay?: number;
}

export function CornerVine({ corner, delay = 0 }: CornerVineProps) {
  const flipX = corner === 'tr' || corner === 'br';
  const flipY = corner === 'bl' || corner === 'br';

  const posStyle: React.CSSProperties = {
    position: 'absolute',
    width: '76px',
    height: '76px',
    pointerEvents: 'none',
    zIndex: 2,
    top: corner === 'tl' || corner === 'tr' ? '-3px' : 'auto',
    bottom: corner === 'bl' || corner === 'br' ? '-3px' : 'auto',
    left: corner === 'tl' || corner === 'bl' ? '-3px' : 'auto',
    right: corner === 'tr' || corner === 'br' ? '-3px' : 'auto',
    transform: `scaleX(${flipX ? -1 : 1}) scaleY(${flipY ? -1 : 1})`,
  };

  return (
    <svg viewBox="0 0 76 76" style={posStyle} aria-hidden="true">
      <path d="M2,2 C15,3 14,17 23,21 C33,26 27,39 39,44 C48,48 45,58 58,62" fill="none" stroke="#7CB342" strokeWidth="1.6" strokeLinecap="round" style={{ strokeDasharray: 220, strokeDashoffset: 220, animation: `vine-grow 1.2s ease-out ${delay}s forwards`, filter: 'drop-shadow(0 0 2px rgba(124,179,66,0.55))`' }} />
      <path d="M23,21 C27,17 33,17 34,10" fill="none" stroke="#7CB342" strokeWidth="1.2" strokeLinecap="round" style={{ strokeDasharray: 60, strokeDashoffset: 60, animation: `vine-grow 0.5s ease-out ${delay + 0.55}s forwards`, opacity: 0.85 }} />
      <g style={{ opacity: 0, transformOrigin: '21px 20px', animation: `leaf-bud 0.5s ease-out ${delay + 0.85}s forwards` }}><path d="M20,18 Q27,13 25,23 Q17,25 20,18 Z" fill="#7CB342" /></g>
      <g style={{ opacity: 0, transformOrigin: '34px 10px', animation: `leaf-bud 0.5s ease-out ${delay + 1.05}s forwards` }}><circle cx="34" cy="10" r="2.2" fill="#F49162" /></g>
      <g style={{ opacity: 0, transformOrigin: '39px 44px', animation: `leaf-bud 0.5s ease-out ${delay + 1.05}s forwards` }}><circle cx="39" cy="44" r="2" fill="#F49162" /></g>
      <g style={{ opacity: 0, transformOrigin: '56px 60px', animation: `leaf-bud 0.5s ease-out ${delay + 1.25}s forwards` }}><path d="M55,58 Q64,54 61,64 Q52,64 55,58 Z" fill="#7CB342" /></g>
    </svg>
  );
}