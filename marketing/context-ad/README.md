# Context Dictionary — Motion Ads (Remotion)

Bright, Apple-style motion ads for **The Context Dictionary** (NeuroDev Labs),
built with [Remotion](https://remotion.dev). Every scene is grounded in what the app
actually does — real screens, the real brand colors (`#CE93D8` → `#00E5FF`) and
Bricolage Grotesque type. Same visual identity across the campaign, different message
per ad.

- **Compositions:** `ContextAd` (ad #1), `ContextAd2` (ad #2), `ContextAd3` (ad #3)
- **Rendered files:** `out/context-ad.mp4`, `out/context-ad-2.mp4`, `out/context-ad-3-16x9.mp4`
- Ads #1–2: 9:16 vertical (TikTok / IG Reels / X) · 1080×1920. Ad #3: 16:9 landscape (YouTube / X / web) · 1920×1080. All 30fps · ~21s.

## Ad #1 — the social-slang angle (`ContextAd`)
1. **Hook** — *"You heard it. You nodded. You had no idea what it meant."*
2. **Reveal** — *"Now you always will."* + the VibeTranslate screen typing `delulu`.
3. **Value stack** — `TRANSLATE. / DEFINE. / SAVE.` → *"Not just a dictionary. Cultural fluency, on demand."*
4. **Payoff** — *"Your vocabulary. Fully decoded."* + the full result card.
5. **Brand close** — gradient `Context` wordmark, Google Play badge, NeuroDev Labs, 3D-perspective phone.

Music: `public/track.wav` (`tools/make-track.mjs`).

## Ad #2 — the everyday plain-English angle (`ContextAd2`)
Markets the problems anyone recognises — no jargon.
1. **Hook** — *"You read it twice. Still didn't click." → "Now it will."*
2. **Explain it simple** — *"When a word's too much, ask for it simple."* + the *Explain Like I'm 5* mode turning `escrow` into a plain-English sentence.
3. **Trust** — *"Half of what you think words mean… isn't quite it."* + the glowing **Fact-checked** badge (real meaning, checked — not a guess).
4. **Keep it** — *"Look it up once. Keep it for good."* + the My Library screen.
5. **Brand close** — same identity; tagline *"Every word. In plain English."*

Music: `public/track2.wav` (`tools/make-track2.mjs`).

## Ad #3 — the "25 ways" angle · 16:9, dark neon style (`ContextAd3`)
Same font and brand palette, but a deliberately different look — the app's dark
"intelligent-future" side: near-black backdrop, drifting purple/cyan glow, a faint
tech grid, and kinetic typography. Markets the 25 persona lenses in plain terms.
1. **Hook** — one glowing word, `salty`. *"One word."*
2. **Kinetic cycle** — *"Twenty-five ways to hear it."* The same word re-explained as the voice flips: Gen Z, Explain Like I'm 5, Corporate, Lawyer, Boomer — sliding through with progress dots.
3. **Payoff** — *"Until one of them clicks. Then it's yours — for good."* + the result card on a tilted phone.
4. **Brand close** — glowing `Context` wordmark, *"However you need to hear it."*, Google Play, NeuroDev Labs.

Music: `public/track3.wav` (`tools/make-track3.mjs`) — darker, pulsing, resolves to major.

## Develop / preview
```bash
npm install
npm start          # opens Remotion Studio
```

## Render
```bash
npm run render                                          # ad #1  → out/context-ad.mp4
npx remotion render ContextAd2 out/context-ad-2.mp4     # ad #2  (9:16)
npx remotion render ContextAd3 out/context-ad-3-16x9.mp4  # ad #3 (16:9)
```
In a headless/CI environment without a full Chrome, point Remotion at a
headless shell and use the software renderer:
```bash
npx remotion render ContextAd out/context-ad.mp4 \
  --browser-executable=/path/to/chrome-headless-shell \
  --gl=swiftshader
```

## Music
The soundtrack is an **original, procedurally-synthesised "Ambient Tech" score**
(`public/track.wav`) — no third-party samples, no licensing. Regenerate it with:
```bash
node tools/make-track.mjs
```
It's arranged to the edit: sparse Cmaj7 pad on the hook, a bell arpeggio + sub bass
on the reveal, a soft kick pulse through the value/payoff beats, resolving to a
Cadd9 shimmer on the brand close, with risers into the two key reveals. Swap in a
different track by dropping a file in `public/` and updating the `<Audio>` src in
`src/ContextAd.tsx`.

## Notes
- The Bricolage Grotesque font (`public/BricolageGrotesque.woff2`, SIL Open Font
  License) is bundled locally so renders never depend on network fonts.
- `node_modules/` is git-ignored; run `npm install` to restore.
