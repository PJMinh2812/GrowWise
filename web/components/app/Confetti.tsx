"use client";

import { useMemo } from "react";

// Lightweight confetti (no dependency): a burst of falling colored pieces.
// Render it conditionally; it covers its nearest positioned ancestor.
export default function Confetti({ count = 36 }: { count?: number }) {
  const pieces = useMemo(() => {
    const colors = ["#F7941D", "#7C4DFF", "#22C55E", "#F2C94C", "#EF5DA8", "#3AA0FF"];
    return Array.from({ length: count }).map((_, i) => ({
      left: Math.random() * 100,
      delay: Math.random() * 0.6,
      duration: 1.8 + Math.random() * 1.4,
      color: colors[i % colors.length],
      size: 7 + Math.random() * 6,
      rounded: Math.random() > 0.5,
    }));
  }, [count]);
  return (
    <div style={{ position: "absolute", inset: 0, overflow: "hidden", pointerEvents: "none", zIndex: 5 }}>
      {pieces.map((p, i) => (
        <span
          key={i}
          style={{
            position: "absolute",
            top: 0,
            left: `${p.left}%`,
            width: `${p.size}px`,
            height: `${p.size}px`,
            background: p.color,
            borderRadius: p.rounded ? "50%" : "2px",
            animation: `gw-confetti-fall ${p.duration}s linear ${p.delay}s forwards`,
          }}
        />
      ))}
    </div>
  );
}
