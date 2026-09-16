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
 * Ad #5 — "The Meeting Nod"
 * 16:9, 20s. Corporate-jargon FOMO, played dry.
 * ══════════════════════════════════════════════════════════════════════════ */

/* S1 — the trigger line. A Slack-style bubble drops in. */
const S1: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: 200,
          paddingRight: 200,
          gap: 18,
        }}
      >
        <div style={{ ...driftUp(frame, 4, 22), alignSelf: "flex-start", marginLeft: 40 }}>
          <Kicker size={13}>SOMEONE, TWO CHAIRS DOWN</Kicker>
        </div>
        <div style={{ ...driftUp(frame, 16, 26, 24), alignSelf: "flex-start" }}>
          <CreamCard
            style={{
              maxWidth: 1180,
              padding: "34px 40px",
              borderRadius: 22,
            }}
          >
            <div style={{ fontSize: 42, color: INK, lineHeight: 1.35, letterSpacing: -0.6 }}>
              "Given Q4 headwinds, we should reassess the{" "}
              <span
                style={{
                  color: CARAMEL,
                  fontWeight: 700,
                  borderBottom: `2px solid ${CARAMEL}`,
                  paddingBottom: 3,
                }}
              >
                vesting cliff
              </span>
              ."
            </div>
          </CreamCard>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S2 — the internal panic. A giant "?" beat. */
const S2: React.FC = () => {
  const frame = useCurrentFrame();
  const wobble = Math.sin(frame / 6) * 2;
  return (
    <Paper>
      <AbsoluteFill
        style={{ justifyContent: "center", alignItems: "center", gap: 6 }}
      >
        <div style={{ ...driftUp(frame, 4, 22) }}>
          <Kicker size={13}>YOU, INTERNALLY</Kicker>
        </div>
        <div
          style={{
            fontSize: 220,
            fontWeight: 700,
            color: INK,
            letterSpacing: -8,
            transform: `translateY(${wobble}px)`,
            ...driftUp(frame, 12, 20, 40),
          }}
        >
          vesting cliff?
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S3 — wall of jargon. Words flash in and out fast. */
const JARGON = [
  "escrow",
  "amortisation",
  "ARR",
  "burn rate",
  "GAAP",
  "going concern",
  "TAM",
  "runway",
  "zero-day",
  "mezzanine",
  "unit economics",
  "vesting cliff",
];

const S3: React.FC = () => {
  const frame = useCurrentFrame();
  // Grid animates in staggered; the "vesting cliff" tile is highlighted.
  return (
    <Paper>
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: 120,
          paddingRight: 120,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 18) }}>
          <Kicker size={13}>WORDS THAT QUIETLY TELL YOU YOU DON'T BELONG</Kicker>
        </div>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(4, minmax(0, 1fr))",
            gap: 18,
            marginTop: 40,
            width: "100%",
            maxWidth: 1500,
          }}
        >
          {JARGON.map((word, i) => {
            const t = interpolate(
              frame,
              [12 + i * 4, 22 + i * 4],
              [0, 1],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE }
            );
            const isHi = word === "vesting cliff";
            return (
              <div
                key={word}
                style={{
                  background: isHi ? `${CARAMEL}22` : CARD,
                  border: `1px solid ${isHi ? CARAMEL : BORDER}`,
                  borderRadius: 14,
                  padding: "20px 22px",
                  fontSize: 26,
                  fontWeight: 600,
                  color: isHi ? CARAMEL : INK,
                  textAlign: "center",
                  opacity: t,
                  transform: `translateY(${(1 - t) * 16}px)`,
                }}
              >
                {word}
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S4 — the turn + product. Left: the turn line. Right: a Define card. */
const S4: React.FC = () => {
  const frame = useCurrentFrame();
  const cardIn = interpolate(frame, [18, 34], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1, paddingLeft: 160 }}>
          <div style={{ ...driftUp(frame, 4, 22) }}>
            <Kicker size={13}>EVERY FIELD HAS A LANGUAGE</Kicker>
          </div>
          <div
            style={{
              fontSize: 96,
              fontWeight: 700,
              color: INK,
              letterSpacing: -3,
              lineHeight: 1.02,
              marginTop: 22,
              ...driftUp(frame, 14, 24, 30),
            }}
          >
            Never nod<br />again.
          </div>
        </div>
        <div style={{ flex: 1, display: "flex", justifyContent: "center", paddingRight: 120 }}>
          <div
            style={{
              transform: `translateY(${(1 - cardIn) * 24}px) rotate(-2deg)`,
              opacity: cardIn,
            }}
          >
            <CreamCard style={{ maxWidth: 560, padding: 32 }}>
              <Kicker size={12}>VESTING CLIFF · IN PLAIN ENGLISH</Kicker>
              <div
                style={{
                  fontSize: 30,
                  color: INK,
                  lineHeight: 1.4,
                  marginTop: 18,
                  fontWeight: 500,
                }}
              >
                The first year of a share-vesting schedule where you get{" "}
                <em style={{ color: CARAMEL, fontStyle: "normal", fontWeight: 700 }}>
                  nothing
                </em>{" "}
                — then, on day one of year two, you get the whole first year at once.
              </div>
              <div
                style={{
                  marginTop: 22,
                  height: 1,
                  background: BORDER,
                }}
              />
              <div
                style={{
                  fontSize: 12,
                  color: INK_SOFT,
                  marginTop: 14,
                  letterSpacing: 1.4,
                  textTransform: "uppercase",
                }}
              >
                via Context Dictionary · 33 fields
              </div>
            </CreamCard>
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S5 — brand close (short). */
const S5: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{ flexDirection: "column", justifyContent: "center", alignItems: "center", gap: 22 }}
      >
        <div style={{ ...driftUp(frame, 2, 20) }}>
          <AppIcon size={124} />
        </div>
        <div
          style={{
            fontSize: 56,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.5,
            ...driftUp(frame, 10, 20),
          }}
        >
          The Context Dictionary
        </div>
        <div
          style={{
            display: "flex",
            gap: 28,
            alignItems: "center",
            marginTop: 12,
            ...driftUp(frame, 20, 20),
          }}
        >
          <PlayBadge />
          <span
            style={{
              fontSize: 13,
              letterSpacing: 3,
              color: INK_SOFT,
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

/* ══════════════ TIMELINE (16:9, 600 frames = 20s @ 30fps) ══════════════ */
export const ContextAd5: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={110}>
        <SceneFade life={110}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={110} durationInFrames={90}>
        <SceneFade life={90}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={200} durationInFrames={165}>
        <SceneFade life={165}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={365} durationInFrames={140}>
        <SceneFade life={140}><S4 /></SceneFade>
      </Sequence>
      <Sequence from={505} durationInFrames={95}>
        <SceneFade life={95}><S5 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
