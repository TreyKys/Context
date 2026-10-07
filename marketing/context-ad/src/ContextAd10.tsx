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
  Kicker,
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
 * Ad #10 — "By the Numbers"
 * 16:9 · 1920×1080 · 15s @ 30fps (450 frames).
 *
 * A minimalist count-up infographic. Three honest facts about the app
 * (33 domains, 25 voices, 1 dictionary that knows which room you're in),
 * each big-number-first, then labelled.
 *
 * Deliberately quiet and brand-forward — pairs well with the louder ads
 * as a palate-cleanser post. The LinkedIn/thought-leader cut.
 * ══════════════════════════════════════════════════════════════════════════ */

/* A numeric scene: giant counter + small label underneath. */
const Stat: React.FC<{
  from: number;
  to: number;
  label: string;
  subtext: string;
  suffix?: string;
}> = ({ from, to, label, subtext, suffix = "" }) => {
  const frame = useCurrentFrame();
  // Count-up with ease-out so it decelerates into the final number.
  const counterT = interpolate(frame, [6, 46], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const value = Math.round(from + (to - from) * counterT);
  const labelOpacity = interpolate(frame, [40, 56], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const subOpacity = interpolate(frame, [50, 66], [0, 1], {
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
          gap: 18,
        }}
      >
        <div
          style={{
            fontSize: 400,
            fontWeight: 700,
            color: INK,
            letterSpacing: -18,
            lineHeight: 0.92,
            fontVariantNumeric: "tabular-nums",
            display: "flex",
            alignItems: "baseline",
          }}
        >
          {value}
          {suffix && (
            <span
              style={{
                fontSize: 160,
                color: CARAMEL,
                marginLeft: 10,
                letterSpacing: -4,
              }}
            >
              {suffix}
            </span>
          )}
        </div>
        <div
          style={{
            width: 86 + labelOpacity * 46,
            height: 3,
            background: CARAMEL,
            opacity: labelOpacity,
            marginTop: 10,
            marginBottom: 10,
          }}
        />
        <div
          style={{
            fontSize: 46,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.5,
            opacity: labelOpacity,
            transform: `translateY(${(1 - labelOpacity) * 12}px)`,
          }}
        >
          {label}
        </div>
        <div
          style={{
            fontSize: 22,
            color: INK_SOFT,
            maxWidth: 760,
            textAlign: "center",
            lineHeight: 1.5,
            opacity: subOpacity,
            transform: `translateY(${(1 - subOpacity) * 10}px)`,
          }}
        >
          {subtext}
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* Pivot scene — the single "1" that reframes the whole set. */
const One: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 20,
        }}
      >
        <div
          style={{
            fontSize: 420,
            fontWeight: 700,
            color: CARAMEL,
            letterSpacing: -20,
            lineHeight: 0.92,
            ...driftUp(frame, 2, 20, 36),
          }}
        >
          1
        </div>
        <div
          style={{
            width: 132,
            height: 3,
            background: CARAMEL,
            marginTop: 10,
            marginBottom: 10,
            opacity: interpolate(frame, [14, 28], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        />
        <div
          style={{
            fontSize: 58,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.8,
            textAlign: "center",
            lineHeight: 1.1,
            ...driftUp(frame, 20, 22, 20),
          }}
        >
          dictionary that knows<br />
          <span style={{ color: INK_SOFT, fontWeight: 300 }}>
            which room you're in.
          </span>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* Brand close. */
const Brand: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "row",
          justifyContent: "center",
          alignItems: "center",
          gap: 44,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 18) }}>
          <AppIcon size={160} />
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          <div
            style={{
              fontSize: 68,
              fontWeight: 700,
              color: INK,
              letterSpacing: -2,
              lineHeight: 1,
              ...driftUp(frame, 10, 18),
            }}
          >
            The Context Dictionary
          </div>
          <div
            style={{
              fontSize: 24,
              color: INK_SOFT,
              letterSpacing: -0.5,
              ...driftUp(frame, 18, 18),
            }}
          >
            Words have context. Now you do too.
          </div>
          <div style={{ marginTop: 18, ...driftUp(frame, 26, 18) }}>
            <PlayBadge />
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* ══════════════ TIMELINE (16:9 · 450 frames · 15s @ 30fps) ══════════════
 *
 *  0–90    S1  33  domains (3.0s)
 *  90–180  S2  25  voices  (3.0s)
 *  180–270 S3  1   dictionary that knows (3.0s)
 *  270–360 S4  reveal line — ties it together via Brand    (3.0s)
 *  360–450 S5  brand close + Play badge                     (3.0s)
 * ═══════════════════════════════════════════════════════════════════════ */
export const ContextAd10: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={90}>
        <SceneFade life={90}>
          <Stat
            from={0}
            to={33}
            label="domains"
            subtext="From Medical to Crypto to Legalese — the vocabulary of 33 fields, understood."
          />
        </SceneFade>
      </Sequence>
      <Sequence from={90} durationInFrames={90}>
        <SceneFade life={90}>
          <Stat
            from={0}
            to={25}
            label="voices"
            subtext="Gen Z. Lawyer. Boomer. Pharmacist. 25 ways to hear the same word."
          />
        </SceneFade>
      </Sequence>
      <Sequence from={180} durationInFrames={90}>
        <SceneFade life={90}><One /></SceneFade>
      </Sequence>
      <Sequence from={270} durationInFrames={90}>
        <SceneFade life={90}><Brand /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
