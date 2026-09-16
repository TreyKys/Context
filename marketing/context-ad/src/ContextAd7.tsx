import React from "react";
import {
  AbsoluteFill,
  Sequence,
  interpolate,
  useCurrentFrame,
} from "remotion";
import {
  Paper,
  CreamCard,
  AppIcon,
  PlayBadge,
  Kicker,
  useBricolage,
  driftUp,
  SceneFade,
  INK,
  INK_SOFT,
  CARAMEL,
  BG,
  BORDER,
  CARD,
  EASE,
} from "./shared";

/* ══════════════════════════════════════════════════════════════════════════
 * Ad #7 — "Before You Google It"
 * 1:1 square, 14s. Comparison / punchy.
 * FOMO: everyone else is still Googling like a caveman; you already have
 * the exact answer for your exact context.
 * ══════════════════════════════════════════════════════════════════════════ */

/* A fake "browser bar" element, minimal and clean. */
const BrowserBar: React.FC<{ text: string; caretVisible: boolean }> = ({
  text,
  caretVisible,
}) => (
  <div
    style={{
      background: CARD,
      border: `1px solid ${BORDER}`,
      borderRadius: 40,
      padding: "18px 26px",
      display: "flex",
      alignItems: "center",
      gap: 14,
      width: 720,
      maxWidth: "80%",
      boxShadow: `0 24px 60px rgba(42,37,33,0.10)`,
    }}
  >
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
      <circle cx="11" cy="11" r="7" stroke={INK_SOFT} strokeWidth="2" />
      <path d="M20 20L16 16" stroke={INK_SOFT} strokeWidth="2" strokeLinecap="round" />
    </svg>
    <div style={{ fontSize: 22, color: INK, fontWeight: 500 }}>
      {text}
      {caretVisible && (
        <span style={{ color: CARAMEL, fontWeight: 400 }}>|</span>
      )}
    </div>
  </div>
);

/* Fake messy search results — grey blocks that read as noise, not signal. */
const FakeResults: React.FC<{ progress: number }> = ({ progress }) => (
  <div
    style={{
      width: 720,
      maxWidth: "80%",
      opacity: progress,
      display: "flex",
      flexDirection: "column",
      gap: 22,
    }}
  >
    {[0, 1, 2, 3].map((i) => (
      <div key={i} style={{ display: "flex", flexDirection: "column", gap: 6 }}>
        <div
          style={{
            height: 12,
            width: `${60 + i * 6}%`,
            background: CARAMEL,
            opacity: 0.55 - i * 0.08,
            borderRadius: 4,
          }}
        />
        <div style={{ height: 6, width: `${88 - i * 4}%`, background: INK_SOFT, opacity: 0.35, borderRadius: 3 }} />
        <div style={{ height: 6, width: `${72 - i * 4}%`, background: INK_SOFT, opacity: 0.35, borderRadius: 3 }} />
      </div>
    ))}
  </div>
);

/* S1 — the Google search bar with a word being typed. */
const S1: React.FC = () => {
  const frame = useCurrentFrame();
  // Character-by-character typing of the word.
  const query = "what does mid mean";
  const typed = Math.min(query.length, Math.floor(interpolate(frame, [6, 46], [0, query.length], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  })));
  const shownText = query.slice(0, typed);
  const caret = frame % 20 < 10;
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 30,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 18) }}>
          <Kicker size={12}>BEFORE YOU GOOGLE IT</Kicker>
        </div>
        <div style={{ ...driftUp(frame, 8, 20, 20) }}>
          <BrowserBar text={shownText} caretVisible={caret && typed === query.length} />
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S2 — the messy Google response. */
const S2: React.FC = () => {
  const frame = useCurrentFrame();
  const results = interpolate(frame, [4, 22], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 34,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 16) }}>
          <Kicker size={12}>ABOUT 47,300,000 RESULTS</Kicker>
        </div>
        <FakeResults progress={results} />
        <div
          style={{
            fontSize: 26,
            color: INK_SOFT,
            fontWeight: 300,
            fontStyle: "italic",
            marginTop: 8,
            ...driftUp(frame, 30, 18),
          }}
        >
          which one applies to your DMs, though?
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S3 — the sharp cut to Context: one clean card. */
const S3: React.FC = () => {
  const frame = useCurrentFrame();
  const cardIn = interpolate(frame, [4, 22], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 26,
          padding: "0 60px",
        }}
      >
        <div style={{ ...driftUp(frame, 2, 16) }}>
          <Kicker size={12}>OR — ONE TAP, THE RIGHT ANSWER</Kicker>
        </div>
        <div
          style={{
            width: 720,
            maxWidth: "80%",
            opacity: cardIn,
            transform: `translateY(${(1 - cardIn) * 26}px)`,
          }}
        >
          <CreamCard style={{ padding: 30 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
              <div style={{ width: 8, height: 8, borderRadius: 4, background: CARAMEL }} />
              <div style={{ fontSize: 30, fontWeight: 700, color: INK }}>mid</div>
              <div
                style={{
                  marginLeft: "auto",
                  fontSize: 11,
                  color: CARAMEL,
                  letterSpacing: 2,
                  border: `1px solid ${CARAMEL}55`,
                  borderRadius: 6,
                  padding: "3px 10px",
                  fontWeight: 600,
                }}
              >
                GEN Z · SLANG
              </div>
            </div>
            <div style={{ fontSize: 20, color: INK, lineHeight: 1.5 }}>
              Mediocre. Not bad enough to hate, not good enough to remember —
              a dismissal wearing a shrug.
            </div>
            <div
              style={{
                marginTop: 16,
                height: 1,
                background: BORDER,
              }}
            />
            <div
              style={{
                marginTop: 12,
                fontSize: 11,
                color: INK_SOFT,
                letterSpacing: 1.6,
                textTransform: "uppercase",
              }}
            >
              via Context Dictionary
            </div>
          </CreamCard>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S4 — the claim + brand close. */
const S4: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{ flexDirection: "column", justifyContent: "center", alignItems: "center", gap: 20 }}
      >
        <div style={{ ...driftUp(frame, 2, 20) }}>
          <AppIcon size={120} />
        </div>
        <div
          style={{
            fontSize: 66,
            fontWeight: 700,
            color: INK,
            letterSpacing: -2,
            textAlign: "center",
            lineHeight: 1.05,
            ...driftUp(frame, 12, 22, 28),
          }}
        >
          One tap.<br />
          <span style={{ color: CARAMEL }}>Real context.</span>
        </div>
        <div
          style={{
            fontSize: 20,
            color: INK_SOFT,
            marginTop: 6,
            ...driftUp(frame, 24, 20),
          }}
        >
          33 rooms · 25 voices · no accounts
        </div>
        <div
          style={{
            display: "flex",
            gap: 22,
            alignItems: "center",
            marginTop: 22,
            ...driftUp(frame, 36, 20),
          }}
        >
          <PlayBadge />
          <span
            style={{
              fontSize: 12,
              color: INK_SOFT,
              letterSpacing: 3,
              textTransform: "uppercase",
              fontWeight: 600,
            }}
          >
            NeuroDev Labs
          </span>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* ══════════════ TIMELINE (1:1, 420 frames = 14s @ 30fps) ══════════════ */
export const ContextAd7: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={90}>
        <SceneFade life={90}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={90} durationInFrames={110}>
        <SceneFade life={110}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={200} durationInFrames={110}>
        <SceneFade life={110}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={310} durationInFrames={110}>
        <SceneFade life={110}><S4 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
