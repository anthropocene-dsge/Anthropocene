import React from 'react';

export function PixelArtThumbnail() {
  return (
    <div style={{ width: '100%', height: '100%', background: '#1C1F16', overflow: 'hidden' }}>
      <img
        src="/assets/casacada.png"
        alt="Cascada del nivel"
        style={{
          width: '100%',
          height: '100%',
          objectFit: 'cover',
          objectPosition: '72% center',
          display: 'block',
          imageRendering: 'pixelated',
        }}
      />
    </div>
  );
}