/*  Ambient-Tech score for the Context Dictionary ad.
    Original, procedurally synthesised — no samples, no licensing.
    Writes public/track.wav (stereo, 44.1kHz, 16-bit).

    Arc (matches the edit):
      0.0–5.0s  Hook      — sparse Cmaj7 pad, airy, curious
      5.0–9.5s  Reveal    — Am7, bell arpeggio enters, sub bass
      9.5–14.5s Value     — Fmaj7→G, soft kick pulse, brighter
     14.5–18.5s Payoff    — Cmaj7 resolve, full & warm
     18.5–21.0s Brand     — Cadd9 shimmer, tail, fade out
*/

import { writeFileSync } from "node:fs";
import { mkdirSync } from "node:fs";
import { dirname } from "node:path";

const SR = 44100;
const DUR = 21.2; // a touch past the 21.056s video; render trims
const N = Math.floor(SR * DUR);
const TAU = Math.PI * 2;

const L = new Float64Array(N);
const R = new Float64Array(N);

const midi = (m) => 440 * Math.pow(2, (m - 69) / 12);
const clamp01 = (x) => (x < 0 ? 0 : x > 1 ? 1 : x);

/* ADSR-ish envelope */
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
  const lg = Math.cos((pan + 1) * (Math.PI / 4)); // equal-power pan
  const rg = Math.sin((pan + 1) * (Math.PI / 4));
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const e = env(t, dur, aa, dd, ss, rr);
    if (e <= 0) continue;
    const ph = TAU * freq * t;
    let v;
    if (kind === "pad") {
      // warm detuned stack
      v =
        Math.sin(ph) * 0.5 +
        Math.sin(ph * 1.001 + 0.3) * 0.3 +
        Math.sin(ph * 2) * 0.12 +
        Math.sin(ph * 3) * 0.05;
    } else if (kind === "bell") {
      // FM-ish bell / pluck
      const mod = Math.sin(ph * 2.01) * 2.2 * Math.exp(-t * 6);
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

/* soft kick — pitch-dropping sine thump */
const kick = (start, gain = 0.5) => {
  const dur = 0.42;
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const f = 120 * Math.exp(-t * 24) + 46;
    const e = Math.exp(-t * 9);
    const v = Math.sin(TAU * f * t) * e * gain;
    L[i] += v;
    R[i] += v;
  }
};

/* airy noise swell / riser */
const riser = (start, dur, gain) => {
  const s0 = Math.floor(start * SR);
  const s1 = Math.min(N, Math.floor((start + dur) * SR));
  let last = 0;
  for (let i = s0; i < s1; i++) {
    const t = (i - s0) / SR;
    const p = t / dur;
    // gentle high-passed noise that swells
    const white = Math.random() * 2 - 1;
    last = last * 0.6 + white * 0.4; // low-pass a touch
    const hp = white - last; // crude high-pass -> airy
    const e = p * p; // swell
    const g = hp * e * gain;
    L[i] += g;
    R[i] += g * 0.9;
  }
};

/* ── Pad chords (root position, spread) ── */
const chord = (start, dur, notes, gain, pan = 0) => {
  notes.forEach((m, idx) =>
    add(start, dur, midi(m), gain, pan + (idx - 1.5) * 0.18, "pad", 0.9, 0.6, 0.85, 0.9)
  );
};

// Cmaj7, Am7, Fmaj7, G, Cmaj7, Cadd9
chord(0.0, 5.4, [60, 64, 67, 71], 0.09);
chord(5.0, 4.9, [57, 60, 64, 67], 0.11);
chord(9.5, 2.6, [53, 57, 60, 64], 0.12);
chord(12.0, 2.8, [55, 59, 62, 65], 0.12);
chord(14.5, 4.2, [60, 64, 67, 71], 0.13);
chord(18.4, 3.0, [60, 64, 67, 72, 74], 0.12);

/* ── Sub bass (root per section) ── */
const bass = (start, dur, m, gain = 0.16) =>
  add(start, dur, midi(m), gain, 0, "bass", 0.04, 0.2, 0.8, 0.3);
bass(5.0, 4.6, 45);
bass(9.5, 2.5, 41);
bass(12.0, 2.7, 43);
bass(14.5, 4.0, 48);
bass(18.4, 2.7, 48);

/* ── Bell arpeggio ── (eighth notes, from ~5s to ~19s) */
const BPM = 100;
const beat = 60 / BPM;
const eighth = beat / 2;
const arpSections = [
  { t0: 5.0, t1: 9.5, notes: [69, 72, 76, 79, 76, 72] }, // Am7 up high
  { t0: 9.5, t1: 12.0, notes: [65, 69, 72, 77, 72, 69] }, // Fmaj7
  { t0: 12.0, t1: 14.5, notes: [67, 71, 74, 79, 74, 71] }, // G
  { t0: 14.5, t1: 19.0, notes: [72, 76, 79, 84, 79, 76] }, // Cmaj7 bright
];
for (const sec of arpSections) {
  let k = 0;
  for (let t = sec.t0; t < sec.t1 - 0.01; t += eighth, k++) {
    const m = sec.notes[k % sec.notes.length];
    const pan = ((k % 4) - 1.5) * 0.4;
    const g = 0.075 * (0.7 + 0.3 * Math.sin(k * 1.3));
    add(t, eighth * 2.2, midi(m), g, pan, "bell", 0.002, 0.15, 0.0, 0.2);
  }
}

/* ── Soft kick pulse (Value → Payoff), fades out before the end ── */
for (let t = 9.5; t < 18.5; t += beat) {
  const fadeIn = clamp01((t - 9.5) / 1.2);
  const fadeOut = clamp01((18.5 - t) / 1.5);
  kick(t, 0.42 * fadeIn * fadeOut);
}

/* ── Risers into the two key reveals ── */
riser(3.4, 1.6, 0.05); // into "Now you always will." + phone
riser(13.2, 1.3, 0.06); // into the payoff card

/* ── Master: gentle limiter + global fade in/out ── */
let peak = 0;
for (let i = 0; i < N; i++) {
  peak = Math.max(peak, Math.abs(L[i]), Math.abs(R[i]));
}
const norm = peak > 0 ? 0.82 / peak : 1;

const fadeInS = 0.4;
const fadeOutS = 1.8;
const int16 = new Int16Array(N * 2);
for (let i = 0; i < N; i++) {
  const t = i / SR;
  let g = 1;
  if (t < fadeInS) g = t / fadeInS;
  if (t > DUR - fadeOutS) g = Math.min(g, (DUR - t) / fadeOutS);
  const soft = (x) => Math.tanh(x * 1.15); // warm soft-clip
  const l = soft(L[i] * norm) * g;
  const r = soft(R[i] * norm) * g;
  int16[i * 2] = Math.max(-32768, Math.min(32767, l * 32767));
  int16[i * 2 + 1] = Math.max(-32768, Math.min(32767, r * 32767));
}

/* ── WAV container ── */
const dataBytes = int16.length * 2;
const buf = Buffer.alloc(44 + dataBytes);
buf.write("RIFF", 0);
buf.writeUInt32LE(36 + dataBytes, 4);
buf.write("WAVE", 8);
buf.write("fmt ", 12);
buf.writeUInt32LE(16, 16);
buf.writeUInt16LE(1, 20); // PCM
buf.writeUInt16LE(2, 22); // stereo
buf.writeUInt32LE(SR, 24);
buf.writeUInt32LE(SR * 2 * 2, 28); // byte rate
buf.writeUInt16LE(2 * 2, 32); // block align
buf.writeUInt16LE(16, 34); // bits
buf.write("data", 36);
buf.writeUInt32LE(dataBytes, 40);
Buffer.from(int16.buffer).copy(buf, 44);

const out = new URL("../public/track.wav", import.meta.url);
mkdirSync(dirname(out.pathname), { recursive: true });
writeFileSync(out, buf);
console.log(`Wrote ${out.pathname} — ${(buf.length / 1e6).toFixed(2)} MB, ${DUR}s`);
