/*  Ambient-Tech score #3 — for the dark, neon "25 ways" ad (16:9).
    Darker, pulsing, cinematic — the "intelligent future" lane. Resolves to
    major at the brand close. Original synthesis. Writes public/track3.wav.

    Key: A minor (i–VI–III–VII), steady pulse under the persona cycle.
      0.0–4.3s  Hook    — low drone + soft Am pad
      4.3–15.3s Cycle   — kick pulse + pulsing synth, kinetic
     15.3–18.5s Payoff  — lift, resolve toward C major
     18.5–21.0s Brand   — bright shimmer, fade out
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
      v = Math.sin(ph) * 0.5 + Math.sin(ph * 1.001 + 0.3) * 0.3 + Math.sin(ph * 2) * 0.12;
    } else if (kind === "saw") {
      // mellow saw via partials — for the pulsing synth
      v = 0;
      for (let h = 1; h <= 6; h++) v += Math.sin(ph * h) / h;
      v *= 0.4;
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

const kick = (start, gain = 0.5) => {
  const dur = 0.42;
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const f = 125 * Math.exp(-t * 22) + 45;
    const e = Math.exp(-t * 8.5);
    L[i] += Math.sin(TAU * f * t) * e * gain;
    R[i] += Math.sin(TAU * f * t) * e * gain;
  }
};

const hat = (start, gain = 0.05) => {
  const dur = 0.05;
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  let last = 0;
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const white = Math.random() * 2 - 1;
    last = last * 0.4 + white * 0.6;
    const hp = white - last;
    const e = Math.exp(-t * 60);
    L[i] += hp * e * gain;
    R[i] += hp * e * gain;
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

const chord = (start, dur, notes, gain, kind = "pad", pan = 0) =>
  notes.forEach((m, idx) =>
    add(start, dur, midi(m), gain, pan + (idx - 1.5) * 0.18, kind, 0.9, 0.6, 0.85, 0.9)
  );

/* Low drone through the hook */
add(0.0, 4.8, midi(33), 0.14, 0, "bass", 0.6, 0.4, 0.9, 0.8); // A1
chord(0.0, 4.8, [57, 60, 64], 0.08); // Am soft

/* Persona-cycle progression: Am – F – C – G, two passes */
const prog = [
  [57, 60, 64, 67], // Am7
  [53, 57, 60, 65], // Fmaj7
  [55, 60, 64, 67], // C
  [50, 55, 59, 62], // G
];
const bassRoots = [33, 29, 36, 31];
let ct = 4.3;
for (let pass = 0; pass < 2; pass++) {
  for (let c = 0; c < 4; c++) {
    const dur = 1.375;
    chord(ct, dur + 0.2, prog[c], 0.09);
    add(ct, dur, midi(bassRoots[c]), 0.15, 0, "bass", 0.03, 0.2, 0.8, 0.25);
    ct += dur;
  }
}

/* Pulsing synth stabs on eighths (tension/energy), 4.3–15.3s */
const BPM = 112;
const beat = 60 / BPM;
const eighth = beat / 2;
{
  let k = 0;
  const notes = [69, 72, 76, 72]; // A minor upper
  for (let t = 4.3; t < 15.3; t += eighth, k++) {
    const fIn = clamp01((t - 4.3) / 1.0);
    const fOut = clamp01((15.3 - t) / 1.2);
    const pan = ((k % 2) * 2 - 1) * 0.45;
    add(t, eighth * 0.9, midi(notes[k % notes.length]), 0.032 * fIn * fOut, pan, "saw", 0.004, 0.05, 0.2, 0.06);
  }
}

/* Kick pulse + offbeat hats, 4.3–15.3s */
for (let t = 4.3; t < 15.4; t += beat) {
  const fIn = clamp01((t - 4.3) / 0.8);
  const fOut = clamp01((15.4 - t) / 1.0);
  kick(t, 0.46 * fIn * fOut);
}
for (let t = 4.3 + eighth; t < 15.3; t += beat) {
  hat(t, 0.045 * clamp01((t - 4.3) / 1.5) * clamp01((15.3 - t) / 1.2));
}

/* Bell arpeggio shimmer over the cycle */
{
  let k = 0;
  const notes = [72, 76, 79, 84, 79, 76];
  for (let t = 8.0; t < 15.3; t += eighth * 2, k++) {
    add(t, eighth * 3, midi(notes[k % notes.length]), 0.05, ((k % 3) - 1) * 0.4, "bell", 0.002, 0.2, 0, 0.25);
  }
}

/* Payoff lift — resolve to C major */
chord(15.3, 3.4, [60, 64, 67, 72], 0.12);
add(15.3, 3.3, midi(36), 0.16, 0, "bass", 0.05, 0.3, 0.8, 0.4); // C2
/* Brand shimmer */
chord(18.4, 3.0, [60, 64, 67, 72, 76], 0.12);
add(18.4, 2.9, midi(36), 0.13, 0, "bass", 0.05, 0.3, 0.8, 0.4);

/* Risers into cycle and payoff */
riser(3.0, 1.4, 0.06);
riser(13.9, 1.4, 0.07);

/* Master */
let peak = 0;
for (let i = 0; i < N; i++) peak = Math.max(peak, Math.abs(L[i]), Math.abs(R[i]));
const norm = peak > 0 ? 0.82 / peak : 1;
const fadeInS = 0.35;
const fadeOutS = 1.8;
const int16 = new Int16Array(N * 2);
for (let i = 0; i < N; i++) {
  const t = i / SR;
  let g = 1;
  if (t < fadeInS) g = t / fadeInS;
  if (t > DUR - fadeOutS) g = Math.min(g, (DUR - t) / fadeOutS);
  const soft = (x) => Math.tanh(x * 1.18);
  L[i] = soft(L[i] * norm) * g;
  R[i] = soft(R[i] * norm) * g;
  int16[i * 2] = Math.max(-32768, Math.min(32767, L[i] * 32767));
  int16[i * 2 + 1] = Math.max(-32768, Math.min(32767, R[i] * 32767));
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

const out = new URL("../public/track3.wav", import.meta.url);
mkdirSync(dirname(out.pathname), { recursive: true });
writeFileSync(out, buf);
console.log(`Wrote ${out.pathname} — ${(buf.length / 1e6).toFixed(2)} MB, ${DUR}s`);
