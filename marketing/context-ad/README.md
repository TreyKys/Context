# Context Dictionary — Motion Ad (Remotion)

A bright, Apple-style 4-scene motion ad for **The Context Dictionary** (NeuroDev Labs),
built with [Remotion](https://remotion.dev). Every scene is grounded in what the app
actually does — the VibeTranslate home screen, the AI result card, the real brand
colors (`#CE93D8` → `#00E5FF`) and Bricolage Grotesque type.

- **Format:** 9:16 vertical (TikTok / IG Reels / X) · 1080×1920 · 30fps · ~21s
- **Rendered file:** `out/context-ad.mp4`

## Scenes
1. **Hook** — white screen, the social-anxiety pain point: *"You heard it. You nodded. You had no idea what it meant."*
2. **Reveal** — *"Now you always will."* + the VibeTranslate screen typing `delulu`.
3. **Value stack** — `TRANSLATE. / DEFINE. / SAVE.` → *"Not just a dictionary. Cultural fluency, on demand."*
4. **Payoff** — *"Your vocabulary. Fully decoded."* + the full result card (literal definition, vibe translation, tags, verified badge).
5. **Brand close** — gradient `Context` wordmark, Google Play badge, NeuroDev Labs, 3D-perspective phone.

## Develop / preview
```bash
npm install
npm start          # opens Remotion Studio
```

## Render
```bash
npm run render
```
In a headless/CI environment without a full Chrome, point Remotion at a
headless shell and use the software renderer:
```bash
npx remotion render ContextAd out/context-ad.mp4 \
  --browser-executable=/path/to/chrome-headless-shell \
  --gl=swiftshader
```

## Notes
- The Bricolage Grotesque font (`public/BricolageGrotesque.woff2`, SIL Open Font
  License) is bundled locally so renders never depend on network fonts.
- `node_modules/` is git-ignored; run `npm install` to restore.
