import React from "react";
import {
  AbsoluteFill,
  Sequence,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
  spring,
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
  GOLD,
  BORDER,
  GRAD,
  EASE,
} from "./shared";

/* ══════════════════════════════════════════════════════════════════════════
 * Ad #4 — "The Room You're Locked Out Of"
 * 16:9, 18s @ 30fps. Cinematic Apple-restraint.
 * FOMO: the moment when everyone in the room got the reference and you didn't.
 * ══════════════════════════════════════════════════════════════════════════ */

/* S1 — the ambient moment. Two small lines. Long silence. */
const S1: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 26,
        }}
      >
        <div
          style={{
            fontSize: 38,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.5,
            ...driftUp(frame, 6, 24),
          }}
        >
          Everyone laughed.
        </div>
        <div
          style={{
            fontSize: 38,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.5,
            ...driftUp(frame, 42, 24),
          }}
        >
          You smiled anyway.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S2 — the big-type reveal. */
const S2: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: 160,
          paddingRight: 160,
        }}
      >
        <div
          style={{
            fontSize: 118,
            fontWeight: 700,
            color: INK,
            letterSpacing: -3,
            lineHeight: 1.08,
            textAlign: "center",
            ...driftUp(frame, 6, 26, 34),
          }}
        >
          Every room speaks<br />its own language.
        </div>
        {/* Thin caramel hairline for punctuation. */}
        <div
          style={{
            marginTop: 42,
            width: 88,
            height: 2,
            background: CARAMEL,
            opacity: interpolate(frame, [26, 40], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
              easing: EASE,
            }),
          }}
        />
      </AbsoluteFill>
    </Paper>
  );
};

/* S3 — product beat. A stylised phone with an in-app selection + Define card. */
const PhoneMock: React.FC = () => {
  const frame = useCurrentFrame();
  const cardIn = interpolate(frame, [22, 38], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <div
      style={{
        width: 380,
        height: 780,
        borderRadius: 46,
        background: "#F6EFDD",
        border: `2px solid ${INK}`,
        boxShadow: `0 40px 90px rgba(42,37,33,0.28)`,
        position: "relative",
        overflow: "hidden",
      }}
    >
      {/* Notch */}
      <div
        style={{
          position: "absolute",
          top: 18,
          left: "50%",
          transform: "translateX(-50%)",
          width: 96,
          height: 22,
          borderRadius: 14,
          background: INK,
          zIndex: 5,
        }}
      />
      {/* Fake feed inside the phone */}
      <div style={{ padding: "72px 22px 24px", height: "100%" }}>
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            gap: 18,
            opacity: 0.55,
          }}
        >
          {[86, 74, 82, 68, 78, 40].map((w, i) => (
            <div key={i} style={{ display: "flex", flexDirection: "column", gap: 6 }}>
              <div
                style={{
                  height: 8,
                  width: `${w}%`,
                  background: INK_SOFT,
                  borderRadius: 4,
                }}
              />
              <div
                style={{
                  height: 8,
                  width: `${w * 0.7}%`,
                  background: INK_SOFT,
                  borderRadius: 4,
                }}
              />
            </div>
          ))}
        </div>
        {/* The selected word — caramel highlight over one bar */}
        <div
          style={{
            position: "absolute",
            top: 210,
            left: 46,
            width: 108,
            height: 22,
            background: `${CARAMEL}55`,
            borderRadius: 4,
          }}
        />
        {/* Floating Define card animates in */}
        <div
          style={{
            position: "absolute",
            top: 260,
            left: 22,
            right: 22,
            transform: `translateY(${(1 - cardIn) * 22}px)`,
            opacity: cardIn,
          }}
        >
          <div
            style={{
              background: "#FFFCF3",
              border: `1px solid ${BORDER}`,
              borderRadius: 18,
              padding: 18,
              boxShadow: `0 24px 40px rgba(42,37,33,0.22)`,
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                marginBottom: 8,
              }}
            >
              <div
                style={{
                  width: 6,
                  height: 6,
                  borderRadius: 3,
                  background: CARAMEL,
                }}
              />
              <div
                style={{
                  fontSize: 20,
                  fontWeight: 700,
                  color: INK,
                }}
              >
                delulu
              </div>
            </div>
            <div style={{ fontSize: 13, color: INK, lineHeight: 1.45 }}>
              Delusional in a self-aware, aspirational way — believing something
              improbable because the belief itself keeps you going.
            </div>
            <div
              style={{
                marginTop: 12,
                fontSize: 10,
                color: INK_SOFT,
                letterSpacing: 1,
                textTransform: "uppercase",
              }}
            >
              via Context Dictionary
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const S3: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneIn = spring({ frame: frame - 4, fps, config: { damping: 200 } });
  return (
    <Paper>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1.1, paddingLeft: 160 }}>
          <div style={{ ...driftUp(frame, 10, 22) }}>
            <Kicker>NOW YOU DO TOO</Kicker>
          </div>
          <div
            style={{
              fontSize: 68,
              fontWeight: 700,
              color: INK,
              letterSpacing: -2,
              lineHeight: 1.1,
              marginTop: 22,
              maxWidth: 720,
              ...driftUp(frame, 20, 24, 30),
            }}
          >
            Select any word.<br />In any app.
          </div>
          <div
            style={{
              fontSize: 22,
              color: INK_SOFT,
              marginTop: 22,
              maxWidth: 560,
              lineHeight: 1.6,
              ...driftUp(frame, 34, 24),
            }}
          >
            A small card. A real answer. Then straight back to what you were
            reading.
          </div>
        </div>
        <div
          style={{
            flex: 1,
            display: "flex",
            justifyContent: "center",
            perspective: 1600,
          }}
        >
          <div
            style={{
              transform: `translateX(${(1 - phoneIn) * 240}px) rotateY(-14deg)`,
              transformStyle: "preserve-3d",
            }}
          >
            <PhoneMock />
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S4 — brand close. */
const S4: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 26,
        }}
      >
        <div style={{ ...driftUp(frame, 4, 22) }}>
          <AppIcon size={140} />
        </div>
        <div
          style={{
            fontSize: 68,
            fontWeight: 700,
            color: INK,
            letterSpacing: -2,
            ...driftUp(frame, 14, 22),
          }}
        >
          The Context Dictionary
        </div>
        <div
          style={{
            fontSize: 26,
            color: INK_SOFT,
            letterSpacing: -0.5,
            marginTop: -6,
            ...driftUp(frame, 22, 22),
          }}
        >
          Words have context. Now you do too.
        </div>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 30,
            marginTop: 20,
            ...driftUp(frame, 32, 22),
          }}
        >
          <PlayBadge />
          <span
            style={{
              fontSize: 14,
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

/* ══════════════ TIMELINE (16:9, 540 frames = 18s @ 30fps) ══════════════ */
export const ContextAd4: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={135}>
        <SceneFade life={135}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={135} durationInFrames={130}>
        <SceneFade life={130}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={265} durationInFrames={150}>
        <SceneFade life={150}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={415} durationInFrames={125}>
        <SceneFade life={125}><S4 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
