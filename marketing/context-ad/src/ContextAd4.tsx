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
 * Ad #4 — "The Room You're Locked Out Of" (portrait/vertical cut)
 * 9:16 · 1080×1920 · 32s @ 30fps (960 frames).
 *
 * Same 8-scene arc as the landscape v2, restructured top-to-bottom so the
 * phone-in-phone canvas becomes the visual centrepiece rather than a side
 * panel. All copy identical to keep both cuts on-message.
 * ══════════════════════════════════════════════════════════════════════════ */

type PhoneVariant = "read" | "select" | "menu" | "card";

const READING_LINES = [
  "she's been reading up on her lore lately.",
  "acting like the crush is inevitable and",
  "everyone else just hasn't caught up yet.",
  "her friends call her ",
  "and honestly she's built different for it.",
];
const HIGHLIGHT_INDEX = 3;

/* Selection handle "drop" indicator on the highlighted word. */
const SelectionHandle: React.FC<{
  side: "left" | "right";
  progress: number;
}> = ({ side, progress }) => (
  <div
    style={{
      position: "absolute",
      top: "100%",
      [side]: -7,
      width: 14,
      height: 14,
      borderRadius: "50% 50% 50% 0",
      background: CARAMEL,
      transform: `translateY(${(1 - progress) * -4}px) rotate(${
        side === "left" ? 45 : -45
      }deg)`,
      opacity: progress,
      transformOrigin: "top",
    }}
  />
);

/* The phone canvas. Bigger than in landscape because portrait has room. */
const PhoneCanvas: React.FC<{
  variant: PhoneVariant;
  progress: number;
}> = ({ variant, progress }) => (
  <div
    style={{
      width: 460,
      height: 940,
      borderRadius: 54,
      background: "#F6EFDD",
      border: `3px solid ${INK}`,
      boxShadow: `0 40px 100px rgba(42,37,33,0.30)`,
      position: "relative",
      overflow: "hidden",
    }}
  >
    {/* Notch */}
    <div
      style={{
        position: "absolute",
        top: 22,
        left: "50%",
        transform: "translateX(-50%)",
        width: 110,
        height: 26,
        borderRadius: 15,
        background: INK,
        zIndex: 5,
      }}
    />
    {/* Fake app chrome */}
    <div
      style={{
        position: "absolute",
        top: 68,
        left: 28,
        right: 28,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        fontSize: 15,
        color: INK_SOFT,
      }}
    >
      <span style={{ fontWeight: 600 }}>@friend</span>
      <span>now</span>
    </div>
    <div
      style={{
        position: "absolute",
        top: 96,
        left: 28,
        right: 28,
        height: 1,
        background: BORDER,
      }}
    />

    {/* Reading pane */}
    <div
      style={{
        position: "absolute",
        top: 118,
        left: 30,
        right: 30,
        fontSize: 20,
        color: INK,
        lineHeight: 1.55,
        fontFamily: "Georgia, serif",
      }}
    >
      {READING_LINES.map((line, i) => (
        <div key={i} style={{ marginBottom: 10, position: "relative" }}>
          {i === HIGHLIGHT_INDEX ? (
            <span>
              {line}
              <span
                style={{
                  position: "relative",
                  background: variant !== "read" ? `${CARAMEL}55` : "transparent",
                  padding: variant !== "read" ? "2px 5px" : 0,
                  borderRadius: 3,
                  fontWeight: variant !== "read" ? 700 : 400,
                  color: INK,
                }}
              >
                delulu
                {variant === "select" && (
                  <>
                    <SelectionHandle side="left" progress={progress} />
                    <SelectionHandle side="right" progress={progress} />
                  </>
                )}
              </span>
            </span>
          ) : (
            line
          )}
        </div>
      ))}
    </div>

    {/* Selection popup menu — Android bubble bar. */}
    {variant === "menu" && (
      <div
        style={{
          position: "absolute",
          top: 208,
          left: 60,
          right: 60,
          transform: `translateY(${(1 - progress) * -10}px)`,
          opacity: progress,
          background: "#FFFCF3",
          border: `1px solid ${BORDER}`,
          borderRadius: 14,
          boxShadow: `0 12px 30px rgba(42,37,33,0.24)`,
          padding: "12px 8px",
          display: "flex",
          justifyContent: "space-around",
          fontSize: 16,
          fontWeight: 600,
          color: INK,
          zIndex: 8,
        }}
      >
        <span style={{ opacity: 0.55 }}>Copy</span>
        <span style={{ opacity: 0.55 }}>Share</span>
        <span
          style={{
            color: CARAMEL,
            background: `${CARAMEL}18`,
            padding: "4px 12px",
            borderRadius: 8,
            transform: `scale(${1 + Math.sin(progress * Math.PI * 4) * 0.04})`,
          }}
        >
          Define
        </span>
        <span style={{ opacity: 0.55 }}>⋮</span>
      </div>
    )}

    {/* Floating Define card. */}
    {variant === "card" && (
      <div
        style={{
          position: "absolute",
          top: 258,
          left: 30,
          right: 30,
          opacity: progress,
          transform: `translateY(${(1 - progress) * 26}px)`,
        }}
      >
        <div
          style={{
            background: "#FFFCF3",
            border: `1px solid ${BORDER}`,
            borderRadius: 20,
            padding: 22,
            boxShadow: `0 26px 54px rgba(42,37,33,0.28)`,
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
                width: 7,
                height: 7,
                borderRadius: 4,
                background: CARAMEL,
              }}
            />
            <span style={{ fontSize: 22, fontWeight: 700, color: INK }}>
              delulu
            </span>
            <span
              style={{
                marginLeft: "auto",
                fontSize: 10,
                letterSpacing: 1.4,
                color: CARAMEL,
                border: `1px solid ${CARAMEL}55`,
                padding: "3px 8px",
                borderRadius: 5,
                fontWeight: 600,
              }}
            >
              GEN Z · SLANG
            </span>
          </div>
          <div style={{ fontSize: 15, color: INK, lineHeight: 1.5 }}>
            Delusional, self-aware. Believing something improbable because
            the belief itself is what keeps you going.
          </div>
          <div
            style={{
              marginTop: 12,
              height: 1,
              background: BORDER,
              opacity: 0.7,
            }}
          />
          <div
            style={{
              marginTop: 8,
              fontSize: 10,
              color: INK_SOFT,
              letterSpacing: 1.4,
              textTransform: "uppercase",
            }}
          >
            via Context Dictionary
          </div>
        </div>
      </div>
    )}
  </div>
);

/* Top block: kicker, big title, one-line explainer. Stacks above the phone. */
const StepHeader: React.FC<{
  n: string;
  title: string;
  body: string;
  frame: number;
}> = ({ n, title, body, frame }) => (
  <div
    style={{
      padding: "80px 60px 30px",
      display: "flex",
      flexDirection: "column",
      alignItems: "flex-start",
      gap: 14,
    }}
  >
    <div
      style={{
        fontSize: 22,
        fontWeight: 600,
        color: CARAMEL,
        letterSpacing: 3,
        ...driftUp(frame, 4, 20),
      }}
    >
      STEP {n}
    </div>
    <div
      style={{
        fontSize: 82,
        fontWeight: 700,
        color: INK,
        letterSpacing: -3,
        lineHeight: 0.98,
        ...driftUp(frame, 12, 22, 30),
      }}
    >
      {title}
    </div>
    <div
      style={{
        fontSize: 22,
        color: INK_SOFT,
        marginTop: 8,
        lineHeight: 1.5,
        maxWidth: 960,
        ...driftUp(frame, 24, 22),
      }}
    >
      {body}
    </div>
  </div>
);

/* ══════════════════════════════════════════════════════════════════════════
 * SCENES
 * ══════════════════════════════════════════════════════════════════════════ */

/* S1 — ambient FOMO. */
const S1: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 32,
          padding: "0 60px",
        }}
      >
        <div
          style={{
            fontSize: 52,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.8,
            textAlign: "center",
            ...driftUp(frame, 6, 22),
          }}
        >
          Everyone laughed.
        </div>
        <div
          style={{
            fontSize: 52,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.8,
            textAlign: "center",
            ...driftUp(frame, 40, 22),
          }}
        >
          You smiled anyway.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S2 — big-type reveal. */
const S2: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          padding: "0 60px",
          flexDirection: "column",
        }}
      >
        <div
          style={{
            fontSize: 118,
            fontWeight: 700,
            color: INK,
            letterSpacing: -4,
            lineHeight: 1.02,
            textAlign: "center",
            ...driftUp(frame, 6, 24, 34),
          }}
        >
          Every room<br />speaks its own<br />language.
        </div>
        <div
          style={{
            marginTop: 44,
            width: 96,
            height: 3,
            background: CARAMEL,
            opacity: interpolate(frame, [24, 40], [0, 1], {
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

/* S3 — "you know this moment" beat. Kicker + hook + 2×2 chip grid + payoff. */
const S3: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 60px",
          gap: 34,
        }}
      >
        <div style={{ ...driftUp(frame, 4, 20) }}>
          <Kicker size={20}>YOU KNOW THIS MOMENT</Kicker>
        </div>
        <div
          style={{
            fontSize: 90,
            fontWeight: 700,
            color: INK,
            letterSpacing: -3,
            lineHeight: 1.02,
            textAlign: "center",
            ...driftUp(frame, 12, 22, 30),
          }}
        >
          Hit a word<br />you don't quite&nbsp;know.
        </div>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: 16,
            marginTop: 12,
            width: "100%",
            maxWidth: 780,
          }}
        >
          {["Google it", "Screenshot it", "Ask the group chat", "Or nod and hope"].map(
            (label, i) => {
              const t = interpolate(
                frame,
                [30 + i * 6, 46 + i * 6],
                [0, 1],
                {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: EASE,
                }
              );
              return (
                <div
                  key={label}
                  style={{
                    opacity: t,
                    transform: `translateY(${(1 - t) * 12}px)`,
                    padding: "16px 20px",
                    background: CARD,
                    border: `1px solid ${BORDER}`,
                    borderRadius: 100,
                    fontSize: 22,
                    color: INK_SOFT,
                    textAlign: "center",
                  }}
                >
                  {label}
                </div>
              );
            }
          )}
        </div>
        <div
          style={{
            fontSize: 28,
            color: INK,
            fontStyle: "italic",
            marginTop: 16,
            textAlign: "center",
            lineHeight: 1.4,
            ...driftUp(frame, 72, 22),
          }}
        >
          Every option costs you your place.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* Step scene template — header on top, phone underneath. */
const StepScene: React.FC<{
  n: string;
  title: string;
  body: string;
  variant: PhoneVariant;
  actionStart: number;
}> = ({ n, title, body, variant, actionStart }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneIn = spring({ frame: frame - 6, fps, config: { damping: 200 } });
  const action = interpolate(
    frame,
    [actionStart, actionStart + 20],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE }
  );
  return (
    <Paper>
      <AbsoluteFill style={{ flexDirection: "column" }}>
        <StepHeader n={n} title={title} body={body} frame={frame} />
        <div
          style={{
            flex: 1,
            display: "flex",
            justifyContent: "center",
            alignItems: "flex-start",
            paddingTop: 20,
          }}
        >
          <div
            style={{
              transform: `translateY(${(1 - phoneIn) * 40}px) scale(${
                0.94 + phoneIn * 0.06
              })`,
            }}
          >
            <PhoneCanvas variant={variant} progress={action} />
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

const S4: React.FC = () => (
  <StepScene
    n="1"
    title={"Long-press\nthe word."}
    body="Grab it with the handles, drag them wider if you want the whole phrase. Same gesture as Copy or Share."
    variant="select"
    actionStart={18}
  />
);

const S5: React.FC = () => (
  <StepScene
    n="2"
    title={"Tap\nDefine."}
    body={'It sits in the same menu as Copy and Share — no permission to grant, no new app to open. Look under the "⋮" if the bar is full.'}
    variant="menu"
    actionStart={14}
  />
);

const S6: React.FC = () => (
  <StepScene
    n="3"
    title={"Read.\nCarry on."}
    body="A small card floats over what you were reading. Tap anywhere outside — you're back on the same paragraph, place kept."
    variant="card"
    actionStart={16}
  />
);

/* S7 — the benefit line. */
const S7: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 60px",
          gap: 22,
        }}
      >
        <div
          style={{
            fontSize: 46,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.6,
            textAlign: "center",
            ...driftUp(frame, 4, 22),
          }}
        >
          You never left the app.
        </div>
        <div
          style={{
            fontSize: 46,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.6,
            textAlign: "center",
            ...driftUp(frame, 20, 22),
          }}
        >
          You never asked.
        </div>
        <div
          style={{
            fontSize: 140,
            fontWeight: 700,
            color: INK,
            letterSpacing: -4,
            lineHeight: 1.02,
            marginTop: 22,
            textAlign: "center",
            ...driftUp(frame, 40, 24, 34),
          }}
        >
          You just <span style={{ color: CARAMEL }}>knew</span>.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S8 — brand close. */
const S8: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 22,
          padding: "0 60px",
        }}
      >
        <div style={{ ...driftUp(frame, 4, 20) }}>
          <AppIcon size={150} />
        </div>
        <div
          style={{
            fontSize: 60,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.8,
            textAlign: "center",
            ...driftUp(frame, 12, 20),
          }}
        >
          The Context<br />Dictionary
        </div>
        <div
          style={{
            fontSize: 26,
            color: INK_SOFT,
            letterSpacing: -0.5,
            marginTop: 6,
            textAlign: "center",
            ...driftUp(frame, 20, 20),
          }}
        >
          Words have context.<br />Now you do too.
        </div>
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 16,
            marginTop: 24,
            ...driftUp(frame, 30, 20),
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

/* ══════════════ TIMELINE (9:16 · 960 frames · 32s @ 30fps) ══════════════ */
export const ContextAd4: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={120}>
        <SceneFade life={120}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={120} durationInFrames={120}>
        <SceneFade life={120}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={240} durationInFrames={150}>
        <SceneFade life={150}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={390} durationInFrames={150}>
        <SceneFade life={150}><S4 /></SceneFade>
      </Sequence>
      <Sequence from={540} durationInFrames={150}>
        <SceneFade life={150}><S5 /></SceneFade>
      </Sequence>
      <Sequence from={690} durationInFrames={150}>
        <SceneFade life={150}><S6 /></SceneFade>
      </Sequence>
      <Sequence from={840} durationInFrames={70}>
        <SceneFade life={70}><S7 /></SceneFade>
      </Sequence>
      <Sequence from={910} durationInFrames={50}>
        <SceneFade life={50}><S8 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
