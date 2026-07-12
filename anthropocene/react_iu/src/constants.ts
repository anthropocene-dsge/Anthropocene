export const MOCK_SAVE_DATA = {
  location: "Sector 01: El Despertar",
  date: "2026-07-09",
  time: "14:32",
  playtime: "02h 15m",
  progress: 42
};

export const GRID_DOTS = Array.from({ length: 420 }, (_, i) => ({
  id: i,
  x: (i % 21) * 5,
  y: Math.floor(i / 21) * 5,
  op: Math.random() > 0.65 ? Math.random() * 0.25 + 0.05 : 0,
}));