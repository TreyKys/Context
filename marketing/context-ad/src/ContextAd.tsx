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

/* Bundled Bricolage Grotesque (variable weight axis) — loaded locally so the
   render never depends on network fonts. */
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
      .then((loaded) => {
        document.fonts.add(loaded);
        continueRender(handle);
      })
      .catch(() => continueRender(handle));
  }, [handle]);
};

/* ─── Brand tokens (pulled from the app's real theme) ─── */
const INK = "#0B0C10"; // deep charcoal text
const INK_SOFT = "#6E6E73"; // Apple-style secondary grey
const BG = "#F5F5F7"; // Apple off-white
const WHITE = "#FFFFFF";
const PURPLE = "#CE93D8";
const CYAN = "#00E5FF";
const CARD = "#0B0C10";
const CARD_BORDER = "#2A2A3E";
const GRAD = `linear-gradient(120deg, ${PURPLE}, ${CYAN})`;

const EASE = Easing.bezier(0.25, 0.1, 0.25, 1);

/* Buttery drift-up + fade, the Apple/brief signature */
const driftUp = (
  frame: number,
  start: number,
  dur = 20,
  dist = 26
): React.CSSProperties => {
  const p = interpolate(frame, [start, start + dur], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return { opacity: p, transform: `translateY(${(1 - p) * dist}px)` };
};

/* Fade a scene's edges so cuts feel like dissolves */
const SceneFade: React.FC<{ children: React.ReactNode; life: number }> = ({
  children,
  life,
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(
    frame,
    [0, 12, life - 12, life],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE }
  );
  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

/* ─── Reusable app UI: the phone device ─── */
const PhoneFrame: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ children, style }) => (
  <div
    style={{
      width: 620,
      height: 1240,
      borderRadius: 74,
      background: CARD,
      border: `2px solid ${CARD_BORDER}`,
      boxShadow:
        "0 60px 120px rgba(11,12,16,0.28), 0 8px 24px rgba(11,12,16,0.18)",
      overflow: "hidden",
      position: "relative",
      ...style,
    }}
  >
    {/* notch */}
    <div
      style={{
        position: "absolute",
        top: 26,
        left: "50%",
        transform: "translateX(-50%)",
        width: 150,
        height: 30,
        borderRadius: 20,
        background: "#000",
        zIndex: 5,
      }}
    />
    {children}
  </div>
);

/* The Vibe Translate home screen (first screen users land on) */
const VibeScreen: React.FC<{ typed: string; showChip: boolean }> = ({
  typed,
  showChip,
}) => (
  <div style={{ padding: "96px 44px 44px", height: "100%" }}>
    <div style={{ fontSize: 26, fontWeight: 300, color: "#9E9E9E" }}>
      Good Evening 👋
    </div>
    <div
      style={{
        fontSize: 44,
        fontWeight: 700,
        color: "#E3E3E3",
        marginTop: 6,
        marginBottom: 40,
        lineHeight: 1.1,
      }}
    >
      What would you
      <br />
      like to know?
    </div>

    {/* input + gradient button */}
    <div style={{ display: "flex", gap: 16, marginBottom: 26 }}>
      <div
        style={{
          flex: 1,
          background: "#111118",
          border: `1px solid ${CARD_BORDER}`,
          borderRadius: 40,
          padding: "26px 32px",
          fontSize: 32,
          color: "#E3E3E3",
          minHeight: 30,
        }}
      >
        {typed}
        <span style={{ opacity: 0.7 }}>|</span>
      </div>
      <div
        style={{
          background: GRAD,
          borderRadius: 40,
          padding: "26px 30px",
          fontSize: 30,
          fontWeight: 700,
          color: "#000",
          display: "flex",
          alignItems: "center",
        }}
      >
        →
      </div>
    </div>

    {/* mode + persona selectors */}
    <div style={{ display: "flex", gap: 14, marginBottom: 34 }}>
      <div
        style={{
          flex: 1,
          background: "#111118",
          border: `1px solid ${CARD_BORDER}`,
          borderRadius: 18,
          padding: "18px 22px",
          fontSize: 24,
          color: "#9E9E9E",
        }}
      >
        Define
      </div>
      <div
        style={{
          flex: 1,
          background: "rgba(206,147,216,0.10)",
          border: `1px solid ${PURPLE}`,
          borderRadius: 18,
          padding: "18px 22px",
          fontSize: 24,
          color: PURPLE,
          fontWeight: 600,
          opacity: showChip ? 1 : 0.35,
          transition: "opacity 0.3s",
        }}
      >
        Gen Z / TikTok ✦
      </div>
    </div>

    {/* recent chips */}
    <div style={{ display: "flex", gap: 14, flexWrap: "wrap" }}>
      {["rizz", "HODL", "synergy"].map((w) => (
        <div
          key={w}
          style={{
            background: "#111118",
            border: `1px solid ${CARD_BORDER}`,
            borderRadius: 30,
            padding: "12px 24px",
            fontSize: 24,
            color: "#BBBBBB",
          }}
        >
          🕐 {w}
        </div>
      ))}
    </div>
  </div>
);

/* The result card — the money shot */
const ResultCardScreen: React.FC<{ frame: number }> = ({ frame }) => {
  const defText =
    "A shortening of “delusional” — believing, often knowingly, in an unrealistic outcome.";
  const chars = Math.floor(
    interpolate(frame, [8, 42], [0, defText.length], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    })
  );
  return (
    <div style={{ padding: "96px 44px 44px", height: "100%" }}>
      <div style={{ fontSize: 58, fontWeight: 700, color: WHITE }}>delulu</div>

      <div
        style={{
          fontSize: 20,
          letterSpacing: 3,
          color: "#757575",
          marginTop: 30,
          marginBottom: 12,
        }}
      >
        LITERAL DEFINITION
      </div>
      <div style={{ fontSize: 30, color: "#E0E0E0", lineHeight: 1.4, minHeight: 130 }}>
        {defText.slice(0, chars)}
        <span style={{ opacity: frame % 20 < 10 ? 1 : 0 }}>|</span>
      </div>

      <div
        style={{
          fontSize: 20,
          letterSpacing: 3,
          color: PURPLE,
          marginTop: 24,
          marginBottom: 12,
        }}
      >
        VIBE TRANSLATION
      </div>
      <div
        style={{
          fontSize: 34,
          fontWeight: 700,
          color: CYAN,
          lineHeight: 1.35,
          opacity: interpolate(frame, [44, 58], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        Bestie is manifesting the impossible — and honestly? We love that
        confidence.
      </div>

      <div style={{ height: 1, background: "#1E1E2E", margin: "34px 0 26px" }} />

      <div style={{ display: "flex", gap: 14, flexWrap: "wrap" }}>
        {["#delulu", "#standards", "#dating"].map((t, i) => (
          <div
            key={t}
            style={{
              padding: "12px 24px",
              borderRadius: 30,
              fontSize: 24,
              color: PURPLE,
              background: "#111118",
              border: "1.5px solid transparent",
              backgroundImage: `linear-gradient(#111118,#111118), linear-gradient(120deg, ${PURPLE}, ${CARD})`,
              backgroundOrigin: "border-box",
              backgroundClip: "padding-box, border-box",
              opacity: interpolate(frame, [58 + i * 6, 70 + i * 6], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
              }),
            }}
          >
            {t}
          </div>
        ))}
      </div>

      <div style={{ display: "flex", gap: 50, marginTop: 40 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 24, color: CYAN }}>
          <svg width="28" height="28" viewBox="0 0 24 24" fill={CYAN}>
            <path d="M6 2h12a1 1 0 0 1 1 1v18l-7-4-7 4V3a1 1 0 0 1 1-1z" />
          </svg>
          Saved
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 24, color: "#757575" }}>
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#757575" strokeWidth={2}>
            <rect x="9" y="9" width="12" height="12" rx="2" />
            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
          </svg>
          Copy
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 24, color: "#757575" }}>
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#757575" strokeWidth={2} strokeLinecap="round">
            <circle cx="18" cy="5" r="3" />
            <circle cx="6" cy="12" r="3" />
            <circle cx="18" cy="19" r="3" />
            <line x1="8.6" y1="13.5" x2="15.4" y2="17.5" />
            <line x1="15.4" y1="6.5" x2="8.6" y2="10.5" />
          </svg>
          Share
        </div>
      </div>

      <div
        style={{
          marginTop: 40,
          fontSize: 20,
          color: "#757575",
          display: "flex",
          alignItems: "center",
          gap: 12,
        }}
      >
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={CYAN} strokeWidth={2.4} strokeLinecap="round" strokeLinejoin="round">
          <path d="M20 6L9 17l-5-5" />
        </svg>
        Fact-checked against Wikipedia &amp; Dictionary
      </div>
    </div>
  );
};

const GooglePlayBadge: React.FC = () => (
  <div
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: 20,
      background: INK,
      borderRadius: 18,
      padding: "22px 38px",
    }}
  >
    <svg width="46" height="52" viewBox="0 0 24 24">
      <defs>
        <linearGradient id="a" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#00C2FF" />
          <stop offset="100%" stopColor="#0052FF" />
        </linearGradient>
        <linearGradient id="b" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#00E676" />
          <stop offset="100%" stopColor="#00897B" />
        </linearGradient>
        <linearGradient id="c" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#FFD600" />
          <stop offset="100%" stopColor="#FF6D00" />
        </linearGradient>
        <linearGradient id="d" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#FF5252" />
          <stop offset="100%" stopColor="#E040FB" />
        </linearGradient>
      </defs>
      <path
        d="M3.18 1.07C2.45 1.5 2 2.28 2 3.18v17.64c0 .9.45 1.68 1.18 2.11l.1.06 9.88-9.88v-.23L3.28 3l-.1.07z"
        fill="url(#a)"
      />
      <path
        d="M16.45 16.27l-3.29-3.3v-.24l3.3-3.29.07.04 3.9 2.22c1.11.63 1.11 1.67 0 2.31l-3.9 2.22-.08.04z"
        fill="url(#c)"
      />
      <path
        d="M16.53 16.23L13.16 12.85 3.18 22.83c.37.39.9.54 1.52.2l11.83-6.8"
        fill="url(#d)"
      />
      <path
        d="M16.53 7.77L4.7 1c-.62-.35-1.15-.2-1.52.2l9.98 9.97 3.37-3.4z"
        fill="url(#b)"
      />
    </svg>
    <div style={{ display: "flex", flexDirection: "column", lineHeight: 1.1 }}>
      <span style={{ fontSize: 18, color: "#D0D0D0", letterSpacing: 1 }}>
        GET IT ON
      </span>
      <span style={{ fontSize: 34, color: WHITE, fontWeight: 700 }}>
        Google Play
      </span>
    </div>
  </div>
);

/* ══════════════ SCENES ══════════════ */

/* S1 — The Hook. Bright white, the social-anxiety pain point. */
const Scene1: React.FC = () => {
  const frame = useCurrentFrame();
  const lines = ["You heard it.", "You nodded.", "You had no idea", "what it meant."];
  return (
    <AbsoluteFill
      style={{
        background: WHITE,
        justifyContent: "center",
        padding: "0 120px",
      }}
    >
      <div>
        {lines.map((l, i) => {
          const bold = i >= 2;
          return (
            <div
              key={l}
              style={{
                fontSize: bold ? 104 : 84,
                fontWeight: bold ? 700 : 300,
                color: INK,
                letterSpacing: bold ? -3 : -1,
                lineHeight: 1.08,
                ...driftUp(frame, 8 + i * 16),
              }}
            >
              {l}
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

/* S2 — The Reveal. "Now you always will." + live app typing "delulu". */
const Scene2: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const word = "delulu";
  const typed = word.slice(
    0,
    Math.floor(
      interpolate(frame, [46, 82], [0, word.length], {
        extrapolateLeft: "clamp",
        extrapolateRight: "clamp",
      })
    )
  );
  const phoneRise = spring({
    frame: frame - 40,
    fps,
    config: { damping: 200, mass: 1.2 },
  });
  return (
    <AbsoluteFill style={{ background: BG, alignItems: "center" }}>
      <div
        style={{
          marginTop: 150,
          fontSize: 96,
          fontWeight: 700,
          color: INK,
          letterSpacing: -3,
          textAlign: "center",
          ...driftUp(frame, 6, 22),
        }}
      >
        Now you
        <br />
        always will.
      </div>
      <div
        style={{
          position: "absolute",
          bottom: -140,
          transform: `translateY(${(1 - phoneRise) * 900}px)`,
        }}
      >
        <PhoneFrame>
          <VibeScreen typed={typed} showChip={frame > 70} />
        </PhoneFrame>
      </div>
    </AbsoluteFill>
  );
};

/* S3 — The Value Stack. TRANSLATE · DEFINE · SAVE, then the promise. */
const Scene3: React.FC = () => {
  const frame = useCurrentFrame();
  const words = ["TRANSLATE.", "DEFINE.", "SAVE."];
  const per = 26;
  const idx = Math.min(Math.floor(frame / per), words.length - 1);
  const local = frame - idx * per;
  const wordsDone = words.length * per; // 78
  const enter = interpolate(local, [0, 8], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const exit =
    idx < words.length - 1
      ? interpolate(local, [per - 8, per], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: EASE,
        })
      : 0;
  const showWords = frame < wordsDone;
  return (
    <AbsoluteFill
      style={{ background: BG, justifyContent: "center", padding: "0 120px" }}
    >
      {showWords ? (
        <div
          style={{
            fontSize: 128,
            fontWeight: 700,
            letterSpacing: -4,
            background: GRAD,
            WebkitBackgroundClip: "text",
            backgroundClip: "text",
            color: "transparent",
            transform: `translateY(${(1 - enter) * 90 - exit * 90}px)`,
            opacity: enter - exit,
          }}
        >
          {words[idx]}
        </div>
      ) : (
        <div>
          <div
            style={{
              fontSize: 62,
              fontWeight: 300,
              color: INK_SOFT,
              letterSpacing: -1,
              ...driftUp(frame, wordsDone + 2, 20),
            }}
          >
            Not just a dictionary.
          </div>
          <div
            style={{
              fontSize: 96,
              fontWeight: 700,
              color: INK,
              letterSpacing: -3,
              lineHeight: 1.05,
              marginTop: 14,
              ...driftUp(frame, wordsDone + 12, 22),
            }}
          >
            Cultural fluency,
            <br />
            on demand.
          </div>
        </div>
      )}
    </AbsoluteFill>
  );
};

/* S4 — The Payoff. The full result card. */
const Scene4: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const rise = spring({ frame, fps, config: { damping: 200, mass: 1.1 } });
  return (
    <AbsoluteFill style={{ background: BG, alignItems: "center" }}>
      <div
        style={{
          marginTop: 96,
          textAlign: "center",
          ...driftUp(frame, 4, 20),
        }}
      >
        <div style={{ fontSize: 60, fontWeight: 300, color: INK_SOFT }}>
          Your vocabulary.
        </div>
        <div
          style={{
            fontSize: 92,
            fontWeight: 700,
            color: INK,
            letterSpacing: -3,
          }}
        >
          Fully decoded.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          bottom: -150,
          transform: `translateY(${(1 - rise) * 700}px)`,
        }}
      >
        <PhoneFrame>
          <ResultCardScreen frame={frame} />
        </PhoneFrame>
      </div>
    </AbsoluteFill>
  );
};

/* S5 — The Brand Close. */
const Scene5: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phone = spring({ frame: frame - 6, fps, config: { damping: 200 } });
  return (
    <AbsoluteFill style={{ background: WHITE, flexDirection: "row" }}>
      <div
        style={{
          flex: 1.15,
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          paddingLeft: 120,
        }}
      >
        <div
          style={{
            fontSize: 130,
            fontWeight: 700,
            letterSpacing: -5,
            background: GRAD,
            WebkitBackgroundClip: "text",
            backgroundClip: "text",
            color: "transparent",
            ...driftUp(frame, 4, 22),
          }}
        >
          Context
        </div>
        <div
          style={{
            fontSize: 40,
            fontWeight: 300,
            color: INK_SOFT,
            letterSpacing: -1,
            marginTop: 10,
            marginBottom: 54,
            ...driftUp(frame, 12, 22),
          }}
        >
          Words have context.
          <br />
          Now you do too.
        </div>
        <div style={{ ...driftUp(frame, 22, 22) }}>
          <GooglePlayBadge />
        </div>
        <div
          style={{
            fontSize: 26,
            fontWeight: 400,
            color: "#9E9E9E",
            letterSpacing: 5,
            marginTop: 90,
            textTransform: "uppercase",
            ...driftUp(frame, 32, 22),
          }}
        >
          NeuroDev Labs
        </div>
      </div>

      <div
        style={{
          flex: 1,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          perspective: 1600,
        }}
      >
        <div
          style={{
            transform: `translateX(${(1 - phone) * 500}px) rotateY(-16deg) scale(0.62)`,
            transformStyle: "preserve-3d",
            filter: "drop-shadow(-30px 20px 60px rgba(206,147,216,0.35))",
          }}
        >
          <PhoneFrame>
            <VibeScreen typed="delulu" showChip />
          </PhoneFrame>
        </div>
      </div>
    </AbsoluteFill>
  );
};

/* ══════════════ TIMELINE ══════════════ */
export const ContextAd: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill style={{ fontFamily, background: WHITE }}>
      {/* Original ambient-tech score, keyed to the edit */}
      <Audio src={staticFile("track.wav")} volume={0.9} />

      <Sequence from={0} durationInFrames={150}>
        <SceneFade life={150}>
          <Scene1 />
        </SceneFade>
      </Sequence>
      <Sequence from={150} durationInFrames={135}>
        <SceneFade life={135}>
          <Scene2 />
        </SceneFade>
      </Sequence>
      <Sequence from={285} durationInFrames={150}>
        <SceneFade life={150}>
          <Scene3 />
        </SceneFade>
      </Sequence>
      <Sequence from={435} durationInFrames={120}>
        <SceneFade life={120}>
          <Scene4 />
        </SceneFade>
      </Sequence>
      <Sequence from={555} durationInFrames={75}>
        <SceneFade life={75}>
          <Scene5 />
        </SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
