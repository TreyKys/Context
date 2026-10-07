import React from "react";
import {
  AbsoluteFill,
  Sequence,
  interpolate,
  useCurrentFrame,
} from "remotion";
import {
  Paper,
  AppIcon,
  PlayBadge,
  useBricolage,
  driftUp,
  SceneFade,
  INK,
  INK_SOFT,
  CARAMEL,
  BORDER,
  EASE,
} from "./shared";

/* ══════════════════════════════════════════════════════════════════════════
 * Ad #8 — "The Translation"
 * 9:16 · 1080×1920 · 15s @ 30fps (450 frames).
 *
 * Totally different pace from the slow editorial cuts: hard-cut kinetic
 * typography, no scene fades, every ~2s a new slang word slams in and its
 * plain-English translation drops under it. Reads like a lyric video, not
 * an ad. Designed to STOP a scroll in the first 2 seconds.
 * ══════════════════════════════════════════════════════════════════════════ */

/** One word-pair slide: SLANG on top, plain-English below. */
const Pair: React.FC<{ slang: string; plain: string; kicker: string }> = ({
  slang,
  plain,
  kicker,
}) => {
  const frame = useCurrentFrame();
  // Slang slams in with a tiny overshoot — 0→1.08→1 feels like a typewriter key.
  const slamT = interpolate(frame, [0, 7, 11], [0, 1.08, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const slangOpacity = interpolate(frame, [0, 4], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  // Plain-english drops in on beat 2 (~0.4s later).
  const plainT = interpolate(frame, [11, 24], [0, 1], {
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
          padding: "0 60px",
          gap: 32,
        }}
      >
        <div
          style={{
            fontSize: 16,
            color: CARAMEL,
            letterSpacing: 4,
            fontWeight: 700,
            textTransform: "uppercase",
            opacity: plainT,
          }}
        >
          {kicker}
        </div>
        <div
          style={{
            fontSize: 240,
            fontWeight: 700,
            color: INK,
            letterSpacing: -10,
            lineHeight: 0.95,
            textAlign: "center",
            transform: `scale(${slamT})`,
            opacity: slangOpacity,
          }}
        >
          {slang}
        </div>
        <div
          style={{
            width: 80 + plainT * 60,
            height: 3,
            background: CARAMEL,
            opacity: plainT,
          }}
        />
        <div
          style={{
            fontSize: 50,
            color: INK_SOFT,
            fontWeight: 400,
            letterSpacing: -1,
            textAlign: "center",
            lineHeight: 1.25,
            maxWidth: 920,
            opacity: plainT,
            transform: `translateY(${(1 - plainT) * 14}px)`,
          }}
        >
          {plain}
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* The outro — ties the point together. */
const Outro: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 60px",
          gap: 18,
        }}
      >
        <div
          style={{
            fontSize: 94,
            fontWeight: 700,
            color: INK,
            letterSpacing: -3,
            lineHeight: 1.02,
            textAlign: "center",
            ...driftUp(frame, 4, 20, 32),
          }}
        >
          Every word.
        </div>
        <div
          style={{
            fontSize: 94,
            fontWeight: 700,
            color: CARAMEL,
            letterSpacing: -3,
            lineHeight: 1.02,
            textAlign: "center",
            ...driftUp(frame, 18, 20, 32),
          }}
        >
          Translated<br />for your room.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* Brand close — compact. */
const Brand: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 18,
          padding: "0 60px",
        }}
      >
        <div style={{ ...driftUp(frame, 2, 16) }}>
          <AppIcon size={128} />
        </div>
        <div
          style={{
            fontSize: 54,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.5,
            textAlign: "center",
            lineHeight: 1.05,
            ...driftUp(frame, 10, 18),
          }}
        >
          The Context<br />Dictionary
        </div>
        <div style={{ marginTop: 16, ...driftUp(frame, 20, 18) }}>
          <PlayBadge />
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* ══════════════ TIMELINE (9:16 · 450 frames · 15s @ 30fps) ══════════════
 * Hard-cuts between pairs (no SceneFade). Each pair held 60 frames = 2s.
 * ══════════════════════════════════════════════════════════════════════ */
export const ContextAd8: React.FC = () => {
  useBricolage();
  const pairs: Array<[string, string, string]> = [
    ["mid", "Mediocre. A dismissal wearing a shrug.", "GEN Z"],
    ["slay", "To do something excellently. To crush it.", "GEN Z"],
    ["delulu", "Aspirationally delusional. On purpose.", "SLANG"],
    ["yap", "To talk a lot. Often about nothing.", "GEN Z"],
    ["cheugy", "Trying too hard to be relevant.", "SLANG"],
  ];
  return (
    <AbsoluteFill>
      {pairs.map((p, i) => (
        <Sequence key={i} from={i * 60} durationInFrames={60}>
          <Pair slang={p[0]} plain={p[1]} kicker={p[2]} />
        </Sequence>
      ))}
      <Sequence from={300} durationInFrames={90}>
        <SceneFade life={90}><Outro /></SceneFade>
      </Sequence>
      <Sequence from={390} durationInFrames={60}>
        <SceneFade life={60}><Brand /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
