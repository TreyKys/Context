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
  BORDER,
  CARD,
  EASE,
} from "./shared";

/* ══════════════════════════════════════════════════════════════════════════
 * Ad #6 — "Same Word. Different Rooms."
 * 9:16 vertical, 22s. Editorial magazine motion.
 * ══════════════════════════════════════════════════════════════════════════ */

/* Small connector — hairline linking a headword to a definition card. */
const Hairline: React.FC<{ progress: number; length?: number }> = ({
  progress,
  length = 84,
}) => (
  <div
    style={{
      width: length,
      height: 1,
      background: CARAMEL,
      transformOrigin: "left center",
      transform: `scaleX(${progress})`,
    }}
  />
);

/* S1 — the single word. */
const S1: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{ justifyContent: "center", alignItems: "center", flexDirection: "column", gap: 16 }}
      >
        <div style={{ ...driftUp(frame, 6, 20) }}>
          <Kicker>ONE WORD</Kicker>
        </div>
        <div
          style={{
            fontSize: 260,
            fontWeight: 700,
            color: INK,
            letterSpacing: -8,
            lineHeight: 0.95,
            ...driftUp(frame, 16, 24, 30),
          }}
        >
          salty.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* Utility — a lens card. Kicker on top, definition below. */
const LensCard: React.FC<{
  label: string;
  body: string;
  progress: number;
}> = ({ label, body, progress }) => (
  <div
    style={{
      opacity: progress,
      transform: `translateY(${(1 - progress) * 18}px)`,
    }}
  >
    <CreamCard style={{ padding: 26, borderRadius: 20 }}>
      <Kicker size={11}>{label}</Kicker>
      <div
        style={{
          marginTop: 12,
          fontSize: 32,
          color: INK,
          fontWeight: 500,
          letterSpacing: -0.6,
          lineHeight: 1.35,
        }}
      >
        {body}
      </div>
    </CreamCard>
  </div>
);

/* S2 — three cards animate around "salty". */
const S2: React.FC = () => {
  const frame = useCurrentFrame();
  const p1 = interpolate(frame, [12, 32], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const p2 = interpolate(frame, [26, 46], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const p3 = interpolate(frame, [40, 60], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill
        style={{
          padding: "120px 90px 80px",
          display: "flex",
          flexDirection: "column",
          gap: 26,
        }}
      >
        <div
          style={{
            fontSize: 128,
            fontWeight: 700,
            color: INK,
            letterSpacing: -4,
            lineHeight: 1,
          }}
        >
          salty
        </div>
        <Hairline progress={interpolate(frame, [4, 18], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: EASE,
        })} />
        <LensCard
          label="GAMING"
          body="Bitter about losing. Especially publicly."
          progress={p1}
        />
        <LensCard
          label="COOKING"
          body="High in sodium. What the recipe needs, or already has too much of."
          progress={p2}
        />
        <LensCard
          label="SAILING"
          body="Of the sea. As in air, spray, or an experienced hand."
          progress={p3}
        />
      </AbsoluteFill>
    </Paper>
  );
};

/* S3 — the turn line. */
const S3: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{ justifyContent: "center", alignItems: "center", padding: "0 90px" }}
      >
        <div
          style={{
            fontSize: 108,
            fontWeight: 700,
            color: INK,
            letterSpacing: -3,
            lineHeight: 1.02,
            textAlign: "center",
            ...driftUp(frame, 8, 24, 32),
          }}
        >
          Same word.<br />
          <span style={{ color: CARAMEL }}>Different rooms.</span>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S4 — second example: "consideration". */
const S4: React.FC = () => {
  const frame = useCurrentFrame();
  const p1 = interpolate(frame, [10, 28], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const p2 = interpolate(frame, [22, 40], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  const p3 = interpolate(frame, [34, 52], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill
        style={{
          padding: "120px 90px 80px",
          display: "flex",
          flexDirection: "column",
          gap: 22,
        }}
      >
        <div
          style={{
            fontSize: 96,
            fontWeight: 700,
            color: INK,
            letterSpacing: -3,
            lineHeight: 1,
          }}
        >
          consideration
        </div>
        <Hairline progress={interpolate(frame, [4, 16], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: EASE,
        })} />
        <LensCard
          label="CONTRACT LAW"
          body="The thing exchanged that makes a promise binding — money, service, silence."
          progress={p1}
        />
        <LensCard
          label="ENGLISH"
          body="Thought. Kindness. The pause you take before you answer."
          progress={p2}
        />
        <LensCard
          label="PHILOSOPHY"
          body="An object of contemplation. What we hold in mind, deliberately."
          progress={p3}
        />
      </AbsoluteFill>
    </Paper>
  );
};

/* S5 — the claim + brand close, back-to-back. */
const S5: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 80px",
          gap: 22,
        }}
      >
        <div
          style={{
            fontSize: 60,
            color: INK_SOFT,
            fontWeight: 300,
            textAlign: "center",
            lineHeight: 1.3,
            letterSpacing: -1,
            ...driftUp(frame, 4, 22),
          }}
        >
          Google gives you<br />the most common.
        </div>
        <div
          style={{
            fontSize: 88,
            fontWeight: 700,
            color: INK,
            letterSpacing: -2.5,
            textAlign: "center",
            lineHeight: 1.06,
            ...driftUp(frame, 22, 24, 30),
          }}
        >
          We give you<br />
          <span style={{ color: CARAMEL }}>the right one.</span>
        </div>
        <div style={{ marginTop: 40, ...driftUp(frame, 42, 20) }}>
          <AppIcon size={110} />
        </div>
        <div
          style={{
            fontSize: 30,
            fontWeight: 700,
            color: INK,
            letterSpacing: -0.5,
            ...driftUp(frame, 52, 20),
          }}
        >
          The Context Dictionary
        </div>
        <div style={{ ...driftUp(frame, 62, 20) }}>
          <PlayBadge />
        </div>
        <div
          style={{
            fontSize: 12,
            letterSpacing: 3,
            color: INK_SOFT,
            textTransform: "uppercase",
            fontWeight: 600,
            ...driftUp(frame, 72, 20),
          }}
        >
          NeuroDev Labs
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* ══════════════ TIMELINE (9:16, 660 frames = 22s @ 30fps) ══════════════ */
export const ContextAd6: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={110}>
        <SceneFade life={110}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={110} durationInFrames={180}>
        <SceneFade life={180}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={290} durationInFrames={90}>
        <SceneFade life={90}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={380} durationInFrames={140}>
        <SceneFade life={140}><S4 /></SceneFade>
      </Sequence>
      <Sequence from={520} durationInFrames={140}>
        <SceneFade life={140}><S5 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
