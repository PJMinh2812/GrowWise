// Light, dependency-free success feedback for kids: a short cheerful chime
// (Web Audio) + a gentle haptic buzz. Safe no-ops where unsupported. Must be
// triggered from a user gesture (click) to satisfy autoplay policies.

let audioCtx: AudioContext | null = null;

function ctx(): AudioContext | null {
  if (typeof window === "undefined") return null;
  try {
    const AC = window.AudioContext || (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
    if (!AC) return null;
    if (!audioCtx) audioCtx = new AC();
    return audioCtx;
  } catch {
    return null;
  }
}

/** A quick three-note rising chime. */
export function playChime() {
  const ac = ctx();
  if (!ac) return;
  try {
    if (ac.state === "suspended") ac.resume();
    const now = ac.currentTime;
    const notes = [523.25, 659.25, 783.99]; // C5, E5, G5
    notes.forEach((freq, i) => {
      const osc = ac.createOscillator();
      const gain = ac.createGain();
      osc.type = "triangle";
      osc.frequency.value = freq;
      const start = now + i * 0.09;
      gain.gain.setValueAtTime(0.0001, start);
      gain.gain.exponentialRampToValueAtTime(0.18, start + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.22);
      osc.connect(gain).connect(ac.destination);
      osc.start(start);
      osc.stop(start + 0.24);
    });
  } catch {
    /* ignore */
  }
}

/** Gentle vibration on supporting devices (mobile). */
export function buzz(pattern: number | number[] = 30) {
  try {
    navigator.vibrate?.(pattern);
  } catch {
    /* ignore */
  }
}

/** Combined celebration cue. */
export function celebrate() {
  playChime();
  buzz([20, 40, 20]);
}
