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

/* ══ Shared brand tokens (kept in sync with ContextAd.tsx) ══ */
const INK = "#0B0C10";
const INK_SOFT = "#6E6E73";
const BG = "#F5F5F7";
const WHITE = "#FFFFFF";
const PURPLE = "#CE93D8";
const CYAN = "#00E5FF";
const CARD = "#0B0C10";
const CARD_BORDER = "#2A2A3E";
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
      .then((loaded) => {
        document.fonts.add(loaded);
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

const type = (frame, from, to, text) => {
  const n = Math.floor(
    interpolate(frame, [from, to], [0, text.length], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    })
  );
  return text.slice(0, n);
};

/* ══ Phone device ══ */
const PhoneFrame = ({ children, style }) => (
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

const Label = ({ children, color }) => (
  <div style={{ fontSize: 20, letterSpacing: 3, color, marginBottom: 12 }}>
    {children}
  </div>
);

const VerifiedBadge = ({ glow = 0 }) => (
  <div
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: 14,
      padding: "18px 26px",
      borderRadius: 18,
      background: "#0E1A17",
      border: `1px solid rgba(0,229,255,${0.3 + glow * 0.5})`,
      boxShadow: `0 0 ${20 + glow * 30}px rgba(0,229,255,${0.12 + glow * 0.25})`,
    }}
  >
    <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke={CYAN} strokeWidth={2.4} strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 2l7 3v6c0 4.4-3 8.4-7 9-4-.6-7-4.6-7-9V5z" fill="rgba(0,229,255,0.08)" />
      <path d="M9 12l2 2 4-4" />
    </svg>
    <div style={{ fontSize: 24, color: "#E0E0E0", fontWeight: 600 }}>
      Fact-checked
    </div>
  </div>
);

/* ── Phone content: Explain Like I'm 5 result ── */
const Eli5Screen = ({ frame }) => {
  const simple =
    "Imagine a trusted friend holds the money until both people keep their promise. That’s escrow.";
  return (
    <div style={{ padding: "96px 44px 44px", height: "100%" }}>
      <div style={{ fontSize: 26, fontWeight: 300, color: "#9E9E9E" }}>Direct Search</div>
      <div style={{ display: "flex", gap: 16, margin: "18px 0 26px" }}>
        <div
          style={{
            flex: 1,
            background: "#111118",
            border: `1px solid ${CARD_BORDER}`,
            borderRadius: 40,
            padding: "22px 30px",
            fontSize: 30,
            color: "#E3E3E3",
          }}
        >
          escrow
        </div>
        <div style={{ background: GRAD, borderRadius: 40, padding: "22px 28px", fontSize: 28, fontWeight: 700, color: "#000", display: "flex", alignItems: "center" }}>→</div>
      </div>

      {/* mode selector, ELI5 active */}
      <div style={{ display: "flex", gap: 12, marginBottom: 40 }}>
        <div style={{ background: "#111118", border: `1px solid ${CARD_BORDER}`, borderRadius: 16, padding: "14px 18px", fontSize: 22, color: "#9E9E9E" }}>Define</div>
        <div style={{ background: "rgba(0,229,255,0.10)", border: `1px solid ${CYAN}`, borderRadius: 16, padding: "14px 18px", fontSize: 22, color: CYAN, fontWeight: 600 }}>Explain Like I’m 5 ✦</div>
      </div>

      <Label color="#757575">THE WORD</Label>
      <div style={{ fontSize: 52, fontWeight: 700, color: WHITE, marginBottom: 30 }}>escrow</div>

      <Label color={CYAN}>IN PLAIN ENGLISH</Label>
      <div style={{ fontSize: 34, color: "#E0E0E0", lineHeight: 1.42, fontWeight: 500 }}>
        {type(frame, 18, 78, simple)}
        <span style={{ opacity: frame % 20 < 10 ? 1 : 0 }}>|</span>
      </div>
    </div>
  );
};

/* ── Phone content: fact-check hero ── */
const TrustScreen = ({ frame }) => {
  const def = "Making someone doubt their own memory or feelings — on purpose.";
  const glow = interpolate(frame, [40, 70], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <div style={{ padding: "96px 44px 44px", height: "100%" }}>
      <div style={{ fontSize: 58, fontWeight: 700, color: WHITE, marginBottom: 30 }}>gaslighting</div>
      <Label color="#757575">WHAT IT ACTUALLY MEANS</Label>
      <div style={{ fontSize: 32, color: "#E0E0E0", lineHeight: 1.42, marginBottom: 30 }}>
        {type(frame, 12, 56, def)}
        <span style={{ opacity: frame % 20 < 10 && frame < 60 ? 1 : 0 }}>|</span>
      </div>

      <div style={{ height: 1, background: "#1E1E2E", margin: "8px 0 34px" }} />

      <div style={{ opacity: glow, transform: `translateY(${(1 - glow) * 16}px)` }}>
        <VerifiedBadge glow={glow} />
        <div style={{ fontSize: 22, color: "#757575", marginTop: 22, lineHeight: 1.4 }}>
          Checked against Wikipedia &amp; the real dictionary — not a guess.
        </div>
      </div>
    </div>
  );
};

/* ── Phone content: My Library ── */
const LibraryScreen = ({ frame }) => {
  const rows = [
    ["escrow", "#money", CYAN],
    ["gaslighting", "#psychology", PURPLE],
    ["rizz", "#slang", CYAN],
    ["sonder", "#feelings", PURPLE],
    ["per my last email", "#work", CYAN],
  ];
  return (
    <div style={{ padding: "96px 44px 44px", height: "100%" }}>
      <div style={{ fontSize: 44, fontWeight: 700, color: "#E3E3E3" }}>My Library</div>
      <div style={{ fontSize: 24, fontWeight: 300, color: "#9E9E9E", marginTop: 6, marginBottom: 34 }}>
        Your saved words &amp; meanings
      </div>
      {rows.map((r, i) => {
        const app = interpolate(frame, [10 + i * 8, 24 + i * 8], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: EASE,
        });
        return (
          <div
            key={r[0]}
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              background: "#111118",
              border: `1px solid ${CARD_BORDER}`,
              borderRadius: 18,
              padding: "22px 24px",
              marginBottom: 16,
              opacity: app,
              transform: `translateY(${(1 - app) * 22}px)`,
            }}
          >
            <div>
              <div style={{ fontSize: 28, fontWeight: 600, color: "#E3E3E3" }}>{r[0]}</div>
              <div style={{ fontSize: 20, color: r[2], marginTop: 4 }}>{r[1]}</div>
            </div>
            <svg width="26" height="26" viewBox="0 0 24 24" fill={CYAN}>
              <path d="M6 2h12a1 1 0 0 1 1 1v18l-7-4-7 4V3a1 1 0 0 1 1-1z" />
            </svg>
          </div>
        );
      })}
    </div>
  );
};

/* ── Phone content: home (for brand close) ── */
const HomeMini = () => (
  <div style={{ padding: "96px 44px 44px", height: "100%" }}>
    <div style={{ fontSize: 26, fontWeight: 300, color: "#9E9E9E" }}>Good Evening 👋</div>
    <div style={{ fontSize: 44, fontWeight: 700, color: "#E3E3E3", marginTop: 6, marginBottom: 40, lineHeight: 1.1 }}>
      What would you<br />like to know?
    </div>
    <div style={{ display: "flex", gap: 16, marginBottom: 26 }}>
      <div style={{ flex: 1, background: "#111118", border: `1px solid ${CARD_BORDER}`, borderRadius: 40, padding: "26px 32px", fontSize: 32, color: "#E3E3E3" }}>escrow</div>
      <div style={{ background: GRAD, borderRadius: 40, padding: "26px 30px", fontSize: 30, fontWeight: 700, color: "#000", display: "flex", alignItems: "center" }}>→</div>
    </div>
    <div style={{ display: "flex", gap: 14 }}>
      <div style={{ flex: 1, background: "#111118", border: `1px solid ${CARD_BORDER}`, borderRadius: 18, padding: "18px 22px", fontSize: 24, color: "#9E9E9E" }}>Define</div>
      <div style={{ flex: 1, background: "rgba(0,229,255,0.10)", border: `1px solid ${CYAN}`, borderRadius: 18, padding: "18px 22px", fontSize: 24, color: CYAN, fontWeight: 600 }}>Like I’m 5 ✦</div>
    </div>
  </div>
);

const GooglePlayBadge = () => (
  <div style={{ display: "inline-flex", alignItems: "center", gap: 20, background: INK, borderRadius: 18, padding: "22px 38px" }}>
    <svg width="46" height="52" viewBox="0 0 24 24">
      <defs>
        <linearGradient id="b2a" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#00C2FF" /><stop offset="100%" stopColor="#0052FF" /></linearGradient>
        <linearGradient id="b2b" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#00E676" /><stop offset="100%" stopColor="#00897B" /></linearGradient>
        <linearGradient id="b2c" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#FFD600" /><stop offset="100%" stopColor="#FF6D00" /></linearGradient>
        <linearGradient id="b2d" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#FF5252" /><stop offset="100%" stopColor="#E040FB" /></linearGradient>
      </defs>
      <path d="M3.18 1.07C2.45 1.5 2 2.28 2 3.18v17.64c0 .9.45 1.68 1.18 2.11l.1.06 9.88-9.88v-.23L3.28 3l-.1.07z" fill="url(#b2a)" />
      <path d="M16.45 16.27l-3.29-3.3v-.24l3.3-3.29.07.04 3.9 2.22c1.11.63 1.11 1.67 0 2.31l-3.9 2.22-.08.04z" fill="url(#b2c)" />
      <path d="M16.53 16.23L13.16 12.85 3.18 22.83c.37.39.9.54 1.52.2l11.83-6.8" fill="url(#b2d)" />
      <path d="M16.53 7.77L4.7 1c-.62-.35-1.15-.2-1.52.2l9.98 9.97 3.37-3.4z" fill="url(#b2b)" />
    </svg>
    <div style={{ display: "flex", flexDirection: "column", lineHeight: 1.1 }}>
      <span style={{ fontSize: 18, color: "#D0D0D0", letterSpacing: 1 }}>GET IT ON</span>
      <span style={{ fontSize: 34, color: WHITE, fontWeight: 700 }}>Google Play</span>
    </div>
  </div>
);

/* ══════════════ SCENES ══════════════ */

/* S1 — Hook: reading something and it not landing. */
const S1 = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: WHITE, justifyContent: "center", padding: "0 120px" }}>
      <div>
        <div style={{ fontSize: 84, fontWeight: 300, color: INK, letterSpacing: -1, lineHeight: 1.1, ...driftUp(frame, 8) }}>
          You read it twice.
        </div>
        <div style={{ fontSize: 84, fontWeight: 300, color: INK, letterSpacing: -1, lineHeight: 1.1, marginBottom: 26, ...driftUp(frame, 26) }}>
          Still didn’t click.
        </div>
        <div style={{ fontSize: 104, fontWeight: 700, color: INK, letterSpacing: -3, lineHeight: 1.05, ...driftUp(frame, 58) }}>
          Now it will.
        </div>
      </div>
    </AbsoluteFill>
  );
};

/* S2 — Explain it simple. */
const S2 = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const rise = spring({ frame: frame - 34, fps, config: { damping: 200, mass: 1.2 } });
  return (
    <AbsoluteFill style={{ background: BG, alignItems: "center" }}>
      <div style={{ marginTop: 150, textAlign: "center", ...driftUp(frame, 6, 22) }}>
        <div style={{ fontSize: 60, fontWeight: 300, color: INK_SOFT }}>When a word’s too much,</div>
        <div style={{ fontSize: 96, fontWeight: 700, color: INK, letterSpacing: -3, lineHeight: 1.02 }}>
          ask for it simple.
        </div>
      </div>
      <div style={{ position: "absolute", bottom: -150, transform: `translateY(${(1 - rise) * 850}px)` }}>
        <PhoneFrame>
          <Eli5Screen frame={frame} />
        </PhoneFrame>
      </div>
    </AbsoluteFill>
  );
};

/* S3 — Trust / fact-check. */
const S3 = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const rise = spring({ frame: frame - 30, fps, config: { damping: 200, mass: 1.1 } });
  return (
    <AbsoluteFill style={{ background: BG, alignItems: "center" }}>
      <div style={{ marginTop: 96, textAlign: "center", padding: "0 90px", ...driftUp(frame, 4, 22) }}>
        <div style={{ fontSize: 54, fontWeight: 300, color: INK_SOFT, lineHeight: 1.2 }}>
          Half of what you think words mean…
        </div>
        <div style={{ fontSize: 90, fontWeight: 700, color: INK, letterSpacing: -3, marginTop: 8 }}>
          isn’t quite it.
        </div>
      </div>
      <div style={{ position: "absolute", bottom: -150, transform: `translateY(${(1 - rise) * 780}px)` }}>
        <PhoneFrame>
          <TrustScreen frame={frame} />
        </PhoneFrame>
      </div>
    </AbsoluteFill>
  );
};

/* S4 — Keep it / library. */
const S4 = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const rise = spring({ frame: frame - 28, fps, config: { damping: 200, mass: 1.1 } });
  return (
    <AbsoluteFill style={{ background: BG, alignItems: "center" }}>
      <div style={{ marginTop: 96, textAlign: "center", ...driftUp(frame, 4, 22) }}>
        <div style={{ fontSize: 60, fontWeight: 300, color: INK_SOFT }}>Look it up once.</div>
        <div style={{ fontSize: 92, fontWeight: 700, color: INK, letterSpacing: -3 }}>Keep it for good.</div>
      </div>
      <div style={{ position: "absolute", bottom: -150, transform: `translateY(${(1 - rise) * 760}px)` }}>
        <PhoneFrame>
          <LibraryScreen frame={frame} />
        </PhoneFrame>
      </div>
    </AbsoluteFill>
  );
};

/* S5 — Brand close (matches ad #1). */
const S5 = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phone = spring({ frame: frame - 6, fps, config: { damping: 200 } });
  return (
    <AbsoluteFill style={{ background: WHITE, flexDirection: "row" }}>
      <div style={{ flex: 1.15, display: "flex", flexDirection: "column", justifyContent: "center", paddingLeft: 120 }}>
        <div style={{ fontSize: 130, fontWeight: 700, letterSpacing: -5, background: GRAD, WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent", ...driftUp(frame, 4, 22) }}>
          Context
        </div>
        <div style={{ fontSize: 40, fontWeight: 300, color: INK_SOFT, letterSpacing: -1, marginTop: 10, marginBottom: 54, ...driftUp(frame, 12, 22) }}>
          Every word.<br />In plain English.
        </div>
        <div style={{ ...driftUp(frame, 22, 22) }}>
          <GooglePlayBadge />
        </div>
        <div style={{ fontSize: 26, fontWeight: 400, color: "#9E9E9E", letterSpacing: 5, marginTop: 90, textTransform: "uppercase", ...driftUp(frame, 32, 22) }}>
          NeuroDev Labs
        </div>
      </div>
      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", perspective: 1600 }}>
        <div style={{ transform: `translateX(${(1 - phone) * 500}px) rotateY(-16deg) scale(0.62)`, transformStyle: "preserve-3d", filter: "drop-shadow(-30px 20px 60px rgba(206,147,216,0.35))" }}>
          <PhoneFrame>
            <HomeMini />
          </PhoneFrame>
        </div>
      </div>
    </AbsoluteFill>
  );
};

/* ══════════════ TIMELINE ══════════════ */
export const ContextAd2 = () => {
  useBricolage();
  return (
    <AbsoluteFill style={{ fontFamily, background: WHITE }}>
      <Audio src={staticFile("track2.wav")} volume={0.9} />
      <Sequence from={0} durationInFrames={140}>
        <SceneFade life={140}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={140} durationInFrames={150}>
        <SceneFade life={150}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={290} durationInFrames={140}>
        <SceneFade life={140}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={430} durationInFrames={110}>
        <SceneFade life={110}><S4 /></SceneFade>
      </Sequence>
      <Sequence from={540} durationInFrames={90}>
        <SceneFade life={90}><S5 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
