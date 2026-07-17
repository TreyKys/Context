import React from "react";
import {
  AbsoluteFill,
  Audio,
  Sequence,
  interpolate,
  useCurrentFrame,
  Easing,
  spring,
  useVideoConfig,
  staticFile,
  delayRender,
  continueRender,
} from "remotion";

/* ══ Brand tokens (retained across the campaign) ══ */
const PURPLE = "#CE93D8";
const CYAN = "#00E5FF";
const CARD = "#0B0C10";
const CARD_BORDER = "#2A2A3E";
const WHITE = "#FFFFFF";
const GRAD = `linear-gradient(120deg, ${PURPLE}, ${CYAN})`;
const EASE = Easing.bezier(0.25, 0.1, 0.25, 1);

const fontFamily = "Bricolage Grotesque";
const useBricolage = () => {
  const [handle] = React.useState(() => delayRender("Loading Bricolage"));
  React.useEffect(() => {
    const f = new FontFace(
      fontFamily,
      `url(${staticFile("BricolageGrotesque.woff2")}) format('woff2')`,
      { weight: "200 800" }
    );
    f.load()
      .then((l) => {
        document.fonts.add(l);
        continueRender(handle);
      })
      .catch(() => continueRender(handle));
  }, [handle]);
};

const driftUp = (frame, start, dur = 20, dist = 26) => {
  const p = interpolate(frame, [start, start + dur], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return { opacity: p, transform: `translateY(${(1 - p) * dist}px)` };
};

const SceneFade = ({ children, life }) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 12, life - 12, life], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

/* ── Dark neon backdrop: drifting purple/cyan glows + faint grid + vignette ── */
const NeonBg = ({ children }) => {
  const frame = useCurrentFrame();
  const d = Math.sin(frame / 70) * 7;
  return (
    <AbsoluteFill style={{ background: "#07080B" }}>
      <AbsoluteFill
        style={{
          background: `radial-gradient(55% 60% at ${26 + d}% 20%, rgba(206,147,216,0.22), transparent 68%),
                       radial-gradient(55% 60% at ${76 - d}% 84%, rgba(0,229,255,0.16), transparent 70%)`,
        }}
      />
      <AbsoluteFill
        style={{
          opacity: 0.045,
          backgroundImage:
            "linear-gradient(#fff 1px, transparent 1px), linear-gradient(90deg, #fff 1px, transparent 1px)",
          backgroundSize: "90px 90px",
        }}
      />
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(85% 85% at 50% 50%, transparent 52%, rgba(0,0,0,0.62))",
        }}
      />
      {children}
    </AbsoluteFill>
  );
};

/* Neon glowing gradient word */
const GlowWord = ({ children, size, style }) => (
  <div style={{ position: "relative", display: "inline-block", ...style }}>
    <div
      style={{
        position: "absolute",
        inset: 0,
        fontSize: size,
        fontWeight: 700,
        letterSpacing: -size * 0.03,
        filter: "blur(34px)",
        opacity: 0.75,
        background: GRAD,
        WebkitBackgroundClip: "text",
        backgroundClip: "text",
        color: "transparent",
      }}
    >
      {children}
    </div>
    <div
      style={{
        position: "relative",
        fontSize: size,
        fontWeight: 700,
        letterSpacing: -size * 0.03,
        background: GRAD,
        WebkitBackgroundClip: "text",
        backgroundClip: "text",
        color: "transparent",
      }}
    >
      {children}
    </div>
  </div>
);

/* Phone device (landscape-friendly) */
const PhoneFrame = ({ children, style }) => (
  <div
    style={{
      width: 470,
      height: 940,
      borderRadius: 58,
      background: CARD,
      border: `2px solid ${CARD_BORDER}`,
      boxShadow: "0 40px 100px rgba(0,0,0,0.6)",
      overflow: "hidden",
      position: "relative",
      ...style,
    }}
  >
    <div
      style={{
        position: "absolute",
        top: 20,
        left: "50%",
        transform: "translateX(-50%)",
        width: 118,
        height: 24,
        borderRadius: 16,
        background: "#000",
        zIndex: 5,
      }}
    />
    {children}
  </div>
);

/* Persona result inside the phone (for payoff / brand) */
const PersonaPhone = () => (
  <div style={{ padding: "78px 34px 34px", height: "100%" }}>
    <div style={{ fontSize: 40, fontWeight: 700, color: WHITE, marginBottom: 22 }}>salty</div>
    <div style={{ display: "flex", gap: 10, marginBottom: 30 }}>
      <div style={{ background: "#111118", border: `1px solid ${CARD_BORDER}`, borderRadius: 12, padding: "10px 14px", fontSize: 17, color: "#9E9E9E" }}>Define</div>
      <div style={{ background: "rgba(206,147,216,0.10)", border: `1px solid ${PURPLE}`, borderRadius: 12, padding: "10px 14px", fontSize: 17, color: PURPLE, fontWeight: 600 }}>Gen Z ✦</div>
    </div>
    <div style={{ fontSize: 15, letterSpacing: 2, color: PURPLE, marginBottom: 10 }}>VIBE TRANSLATION</div>
    <div style={{ fontSize: 26, fontWeight: 700, color: CYAN, lineHeight: 1.35 }}>
      Big mad over something small.
    </div>
    <div style={{ height: 1, background: "#1E1E2E", margin: "26px 0 20px" }} />
    <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
      {["#salty", "#mood", "#slang"].map((t) => (
        <div key={t} style={{ padding: "8px 16px", borderRadius: 20, fontSize: 16, color: PURPLE, background: "#111118", border: `1px solid rgba(206,147,216,0.5)` }}>{t}</div>
      ))}
    </div>
  </div>
);

const GooglePlayBadge = () => (
  <div style={{ display: "inline-flex", alignItems: "center", gap: 18, background: "#0B0C10", border: `1px solid ${CARD_BORDER}`, borderRadius: 16, padding: "18px 32px" }}>
    <svg width="42" height="48" viewBox="0 0 24 24">
      <defs>
        <linearGradient id="c3a" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#00C2FF" /><stop offset="100%" stopColor="#0052FF" /></linearGradient>
        <linearGradient id="c3b" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#00E676" /><stop offset="100%" stopColor="#00897B" /></linearGradient>
        <linearGradient id="c3c" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#FFD600" /><stop offset="100%" stopColor="#FF6D00" /></linearGradient>
        <linearGradient id="c3d" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#FF5252" /><stop offset="100%" stopColor="#E040FB" /></linearGradient>
      </defs>
      <path d="M3.18 1.07C2.45 1.5 2 2.28 2 3.18v17.64c0 .9.45 1.68 1.18 2.11l.1.06 9.88-9.88v-.23L3.28 3l-.1.07z" fill="url(#c3a)" />
      <path d="M16.45 16.27l-3.29-3.3v-.24l3.3-3.29.07.04 3.9 2.22c1.11.63 1.11 1.67 0 2.31l-3.9 2.22-.08.04z" fill="url(#c3c)" />
      <path d="M16.53 16.23L13.16 12.85 3.18 22.83c.37.39.9.54 1.52.2l11.83-6.8" fill="url(#c3d)" />
      <path d="M16.53 7.77L4.7 1c-.62-.35-1.15-.2-1.52.2l9.98 9.97 3.37-3.4z" fill="url(#c3b)" />
    </svg>
    <div style={{ display: "flex", flexDirection: "column", lineHeight: 1.1 }}>
      <span style={{ fontSize: 16, color: "#9E9E9E", letterSpacing: 1 }}>GET IT ON</span>
      <span style={{ fontSize: 32, color: WHITE, fontWeight: 700 }}>Google Play</span>
    </div>
  </div>
);

/* ══════════════ SCENES ══════════════ */

/* S1 — one glowing word */
const S1 = () => {
  const frame = useCurrentFrame();
  return (
    <NeonBg>
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div style={{ fontSize: 44, fontWeight: 300, color: "#9E9E9E", letterSpacing: 2, marginBottom: 20, ...driftUp(frame, 6) }}>
          One word.
        </div>
        <div style={{ ...driftUp(frame, 26, 24) }}>
          <GlowWord size={300}>
            salty
            <span style={{ WebkitTextFillColor: CYAN, opacity: frame % 24 < 12 ? 1 : 0, background: "none" }}>|</span>
          </GlowWord>
        </div>
      </AbsoluteFill>
    </NeonBg>
  );
};

/* S2 — the persona cycle (kinetic) */
const PERSONAS = [
  ["GEN Z / TIKTOK", "Big mad over something small."],
  ["EXPLAIN LIKE I’M 5", "Grumpy because you didn’t win."],
  ["CORPORATE EXEC", "Expressing measured dissatisfaction."],
  ["LEGALESE / LAWYER", "Aggrieved — and eager to say so."],
  ["BOOMER ON FACEBOOK", "Back in my day, we just said cross!!"],
];
const SEG = 58;

const S2 = () => {
  const frame = useCurrentFrame();
  const intro = 40;
  const idx = Math.max(0, Math.min(PERSONAS.length - 1, Math.floor((frame - intro) / SEG)));
  const local = frame - intro - idx * SEG;
  const enter = interpolate(local, [0, 12], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  const exit = idx < PERSONAS.length - 1
    ? interpolate(local, [SEG - 12, SEG], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE })
    : 0;
  const x = (1 - enter) * 70 - exit * 70;
  const op = enter - exit;
  const [label, take] = PERSONAS[idx];
  const headline = interpolate(frame, [0, 18, intro - 4, intro + 6], [0, 1, 1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });

  return (
    <NeonBg>
      {/* persistent header */}
      <div style={{ position: "absolute", top: 70, left: 140, display: "flex", alignItems: "baseline", gap: 18 }}>
        <span style={{ fontSize: 22, letterSpacing: 3, color: "#6E6E73" }}>DEFINING</span>
        <span style={{ fontSize: 40, fontWeight: 700, color: WHITE }}>salty</span>
      </div>
      <div style={{ position: "absolute", top: 78, right: 140, fontSize: 24, fontWeight: 300, color: "#9E9E9E", letterSpacing: 1 }}>
        1 word · <span style={{ color: CYAN }}>25 ways</span>
      </div>

      {/* intro headline */}
      {headline > 0.01 && (
        <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
          <div style={{ fontSize: 96, fontWeight: 700, letterSpacing: -3, textAlign: "center", opacity: headline, background: GRAD, WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent" }}>
            Twenty-five ways<br />to hear it.
          </div>
        </AbsoluteFill>
      )}

      {/* persona take */}
      {frame >= intro && (
        <AbsoluteFill style={{ justifyContent: "center", paddingLeft: 140, paddingRight: 140 }}>
          <div style={{ opacity: op, transform: `translateX(${x}px)` }}>
            <div style={{ display: "inline-block", fontSize: 28, fontWeight: 600, letterSpacing: 4, color: CYAN, padding: "10px 22px", border: `1px solid rgba(0,229,255,0.4)`, borderRadius: 40, marginBottom: 34 }}>
              {label}
            </div>
            <div style={{ fontSize: 108, fontWeight: 700, color: WHITE, letterSpacing: -3, lineHeight: 1.04, maxWidth: 1500 }}>
              “{take}”
            </div>
          </div>
        </AbsoluteFill>
      )}

      {/* progress dots */}
      <div style={{ position: "absolute", bottom: 70, left: 140, display: "flex", gap: 14 }}>
        {PERSONAS.map((_, i) => (
          <div key={i} style={{ width: i === idx ? 44 : 14, height: 8, borderRadius: 8, background: i === idx ? GRAD : "#2A2A3E", transition: "all 0.3s" }} />
        ))}
      </div>
    </NeonBg>
  );
};

/* S3 — payoff */
const S3 = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const ph = spring({ frame: frame - 8, fps, config: { damping: 200 } });
  return (
    <NeonBg>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1.2, paddingLeft: 140 }}>
          <div style={{ fontSize: 60, fontWeight: 300, color: "#9E9E9E", letterSpacing: -1, ...driftUp(frame, 6, 22) }}>
            Until one of them
          </div>
          <div style={{ fontSize: 130, fontWeight: 700, color: WHITE, letterSpacing: -4, lineHeight: 1, margin: "6px 0 30px", ...driftUp(frame, 14, 22) }}>
            clicks.
          </div>
          <div style={{ fontSize: 46, fontWeight: 300, color: "#9E9E9E", ...driftUp(frame, 26, 22) }}>
            Then it’s yours — for good.
          </div>
        </div>
        <div style={{ flex: 1, display: "flex", justifyContent: "center", perspective: 1500 }}>
          <div style={{ transform: `translateX(${(1 - ph) * 400}px) rotateY(-18deg)`, transformStyle: "preserve-3d", filter: "drop-shadow(-24px 20px 50px rgba(0,229,255,0.28))" }}>
            <PhoneFrame>
              <PersonaPhone />
            </PhoneFrame>
          </div>
        </div>
      </AbsoluteFill>
    </NeonBg>
  );
};

/* S4 — brand close (dark neon variant) */
const S4 = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const ph = spring({ frame: frame - 6, fps, config: { damping: 200 } });
  return (
    <NeonBg>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1.25, paddingLeft: 140 }}>
          <div style={{ ...driftUp(frame, 4, 22) }}>
            <GlowWord size={168}>Context</GlowWord>
          </div>
          <div style={{ fontSize: 46, fontWeight: 300, color: "#B7B7BD", letterSpacing: -1, marginTop: 14, marginBottom: 46, ...driftUp(frame, 12, 22) }}>
            However you need to hear it.
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 40 }}>
            <div style={{ ...driftUp(frame, 20, 22) }}>
              <GooglePlayBadge />
            </div>
            <div style={{ fontSize: 24, fontWeight: 400, color: "#7A7A80", letterSpacing: 4, textTransform: "uppercase", ...driftUp(frame, 28, 22) }}>
              NeuroDev Labs
            </div>
          </div>
        </div>
        <div style={{ flex: 1, display: "flex", justifyContent: "center", perspective: 1500 }}>
          <div style={{ transform: `translateX(${(1 - ph) * 380}px) rotateY(-16deg) scale(0.96)`, transformStyle: "preserve-3d", filter: "drop-shadow(-24px 20px 50px rgba(206,147,216,0.30))" }}>
            <PhoneFrame>
              <PersonaPhone />
            </PhoneFrame>
          </div>
        </div>
      </AbsoluteFill>
    </NeonBg>
  );
};

/* ══════════════ TIMELINE (16:9) ══════════════ */
export const ContextAd3 = () => {
  useBricolage();
  return (
    <AbsoluteFill style={{ fontFamily, background: "#07080B" }}>
      <Audio src={staticFile("track3.wav")} volume={0.9} />
      <Sequence from={0} durationInFrames={130}>
        <SceneFade life={130}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={130} durationInFrames={330}>
        <SceneFade life={330}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={460} durationInFrames={95}>
        <SceneFade life={95}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={555} durationInFrames={75}>
        <SceneFade life={75}><S4 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
