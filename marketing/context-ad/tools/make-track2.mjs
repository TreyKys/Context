/*  Ambient-Tech score #2 — for the "Plain English" ad.
    Brighter, warmer, a touch more forward than track 1. Original synthesis,
    no samples. Writes public/track2.wav (stereo, 44.1kHz, 16-bit).

    Key: D major (I–V–vi–IV), reassuring / "clarity" feel.
      0.0–5.0s  Hook    — soft Dmaj7 pad, sparse
      5.0–10.0s Simple  — pluck arpeggio + sub bass, gentle shaker
     10.0–15.0s Trust   — full & warm, soft kick pulse
     15.0–18.5s Keep    — resolve
     18.5–21.0s Brand   — shimmer tail, fade out
*/

import { writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

const SR = 44100;
const DUR = 21.2;
const N = Math.floor(SR * DUR);
const TAU = Math.PI * 2;
const L = new Float64Array(N);
const R = new Float64Array(N);

const midi = (m) => 440 * Math.pow(2, (m - 69) / 12);
const clamp01 = (x) => (x < 0 ? 0 : x > 1 ? 1 : x);

const env = (t, dur, a, d, s, r) => {
  if (t < 0 || t > dur) return 0;
  if (t < a) return t / a;
  if (t < a + d) return 1 - (1 - s) * ((t - a) / d);
  if (t < dur - r) return s;
  return s * (1 - (t - (dur - r)) / r);
};

const add = (start, dur, freq, gain, pan, kind, aa, dd, ss, rr) => {
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  const lg = Math.cos((pan + 1) * (Math.PI / 4));
  const rg = Math.sin((pan + 1) * (Math.PI / 4));
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const e = env(t, dur, aa, dd, ss, rr);
    if (e <= 0) continue;
    const ph = TAU * freq * t;
    let v;
    if (kind === "pad") {
      v =
        Math.sin(ph) * 0.5 +
        Math.sin(ph * 1.001 + 0.3) * 0.3 +
        Math.sin(ph * 2) * 0.12 +
        Math.sin(ph * 3) * 0.05;
    } else if (kind === "pluck") {
      // warm plucked string-ish: 2 partials, quick decay
      v = (Math.sin(ph) + Math.sin(ph * 2) * 0.4) * Math.exp(-t * 3.5);
    } else if (kind === "bell") {
      const mod = Math.sin(ph * 2.01) * 2.0 * Math.exp(-t * 6);
      v = Math.sin(ph + mod);
    } else if (kind === "bass") {
      v = Math.sin(ph) * 0.8 + Math.sin(ph * 0.5) * 0.4;
    } else {
      v = Math.sin(ph);
    }
    const g = v * e * gain;
    L[i] += g * lg;
    R[i] += g * rg;
  }
};

const kick = (start, gain = 0.42) => {
  const dur = 0.4;
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const f = 115 * Math.exp(-t * 24) + 46;
    const e = Math.exp(-t * 9);
    L[i] += Math.sin(TAU * f * t) * e * gain;
    R[i] += Math.sin(TAU * f * t) * e * gain;
  }
};

// soft shaker: short filtered-noise tick
const shaker = (start, gain = 0.06) => {
  const dur = 0.06;
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  let last = 0;
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const white = Math.random() * 2 - 1;
    last = last * 0.5 + white * 0.5;
    const hp = white - last;
    const e = Math.exp(-t * 45);
    L[i] += hp * e * gain;
    R[i] += hp * e * gain * 0.95;
  }
};

const riser = (start, dur, gain) => {
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  let last = 0;
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const p = t / dur;
    const white = Math.random() * 2 - 1;
    last = last * 0.6 + white * 0.4;
    const hp = white - last;
    const g = hp * p * p * gain;
    L[i] += g;
    R[i] += g * 0.9;
  }
};

const chord = (start, dur, notes, gain, pan = 0) =>
  notes.forEach((m, idx) =>
    add(start, dur, midi(m), gain, pan + (idx - 1.5) * 0.18, "pad", 0.9, 0.6, 0.85, 0.9)
  );

/* Progression: Dmaj7 – A – Bm7 – G – Dmaj7 – D(add9) */
chord(0.0, 5.4, [62, 66, 69, 73], 0.09);
chord(5.0, 2.6, [57, 61, 64, 69], 0.11);
chord(7.5, 2.7, [59, 62, 66, 69], 0.11);
chord(10.0, 2.6, [55, 59, 62, 67], 0.12);
chord(12.5, 2.7, [62, 66, 69, 73], 0.12);
chord(15.0, 3.5, [62, 66, 69, 73], 0.13);
chord(18.4, 3.0, [62, 66, 69, 74, 76], 0.12);

/* Sub bass roots */
const bass = (start, dur, m, gain = 0.16) =>
  add(start, dur, midi(m), gain, 0, "bass", 0.04, 0.2, 0.8, 0.3);
bass(5.0, 2.4, 38);
bass(7.5, 2.5, 33);
bass(10.0, 2.4, 35);
bass(12.5, 2.5, 31);
bass(15.0, 3.3, 38);
bass(18.4, 2.7, 38);

/* Pluck arpeggio (warm, D major), 5s–18.5s on eighths */
const BPM = 104;
const beat = 60 / BPM;
const eighth = beat / 2;
const arpSections = [
  { t0: 5.0, t1: 7.5, notes: [66, 69, 73, 78, 73, 69] }, // D
  { t0: 7.5, t1: 10.0, notes: [64, 69, 73, 76, 73, 69] }, // A
  { t0: 10.0, t1: 12.5, notes: [66, 69, 74, 78, 74, 69] }, // Bm
  { t0: 12.5, t1: 15.0, notes: [62, 67, 71, 74, 71, 67] }, // G
  { t0: 15.0, t1: 18.5, notes: [69, 73, 78, 81, 78, 73] }, // D bright
];
for (const sec of arpSections) {
  let k = 0;
  for (let t = sec.t0; t < sec.t1 - 0.01; t += eighth, k++) {
    const m = sec.notes[k % sec.notes.length];
    const pan = ((k % 4) - 1.5) * 0.4;
    const g = 0.07 * (0.7 + 0.3 * Math.sin(k * 1.1));
    add(t, eighth * 2.0, midi(m), g, pan, "pluck", 0.002, 0.2, 0.0, 0.25);
  }
}

/* Gentle shaker on offbeats from 5s to 18.5s */
for (let t = 5.0 + eighth; t < 18.5; t += beat) {
  const fIn = clamp01((t - 5.0) / 1.0);
  const fOut = clamp01((18.5 - t) / 1.2);
  shaker(t, 0.05 * fIn * fOut);
}

/* Soft kick pulse (Trust → Keep), fades before end */
for (let t = 10.0; t < 18.5; t += beat) {
  const fIn = clamp01((t - 10.0) / 1.2);
  const fOut = clamp01((18.5 - t) / 1.5);
  kick(t, 0.4 * fIn * fOut);
}

/* Risers into the two reveals */
riser(3.6, 1.5, 0.05);
riser(13.6, 1.3, 0.06);

/* Master */
let peak = 0;
for (let i = 0; i < N; i++) peak = Math.max(peak, Math.abs(L[i]), Math.abs(R[i]));
const norm = peak > 0 ? 0.82 / peak : 1;
const fadeInS = 0.4;
const fadeOutS = 1.8;
const int16 = new Int16Array(N * 2);
for (let i = 0; i < N; i++) {
  const t = i / SR;
  let g = 1;
  if (t < fadeInS) g = t / fadeInS;
  if (t > DUR - fadeOutS) g = Math.min(g, (DUR - t) / fadeOutS);
  const soft = (x) => Math.tanh(x * 1.15);
  const l = soft(L[i] * norm) * g;
  const r = soft(R[i] * norm) * g;
  int16[i * 2] = Math.max(-32768, Math.min(32767, l * 32767));
  int16[i * 2 + 1] = Math.max(-32768, Math.min(32767, r * 32767));
}

const dataBytes = int16.length * 2;
const buf = Buffer.alloc(44 + dataBytes);
buf.write("RIFF", 0);
buf.writeUInt32LE(36 + dataBytes, 4);
buf.write("WAVE", 8);
buf.write("fmt ", 12);
buf.writeUInt32LE(16, 16);
buf.writeUInt16LE(1, 20);
buf.writeUInt16LE(2, 22);
buf.writeUInt32LE(SR, 24);
buf.writeUInt32LE(SR * 2 * 2, 28);
buf.writeUInt16LE(2 * 2, 32);
buf.writeUInt16LE(16, 34);
buf.write("data", 36);
buf.writeUInt32LE(dataBytes, 40);
Buffer.from(int16.buffer).copy(buf, 44);

const out = new URL("../public/track2.wav", import.meta.url);
mkdirSync(dirname(out.pathname), { recursive: true });
writeFileSync(out, buf);
console.log(`Wrote ${out.pathname} — ${(buf.length / 1e6).toFixed(2)} MB, ${DUR}s`);
