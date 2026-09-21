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
  CARD,
  BG,
  EASE,
} from "./shared";

/* ══════════════════════════════════════════════════════════════════════════
 * Ad #4 — "The Room You're Locked Out Of" (v2)
 * 16:9, 32s @ 30fps = 960 frames.
 *
 * v2 change vs. the 18s cut: adds a real three-step walkthrough of the
 * "Define from any app" feature (Select → Tap Define → Card), a "you've
 * done this" beat before it, and a benefit line after — because the
 * shorter cut landed the FOMO but never explained the mechanism.
 * ══════════════════════════════════════════════════════════════════════════ */

/* ────────────────────────────────────────────────────────────────────────────
 * A stylised phone frame used across the walkthrough. The step scenes hand
 * it a `variant` and it swaps only what's inside — same body, same position,
 * so the viewer reads the beats as one continuous interaction.
 * ──────────────────────────────────────────────────────────────────────────── */

type PhoneVariant = "read" | "select" | "menu" | "card";

const READING_LINES = [
  "she's been reading up on her lore lately.",
  "acting like the crush is inevitable and",
  "everyone else just hasn't caught up yet.",
  "her friends call her ",
  "and honestly she's built different for it.",
];

const HIGHLIGHT_INDEX = 3; // "delulu" sits at the end of line 3

const PhoneCanvas: React.FC<{
  variant: PhoneVariant;
  /** 0→1 progress of the variant's own animation (card slide, handle drop). */
  progress: number;
}> = ({ variant, progress }) => {
  return (
    <div
      style={{
        width: 340,
        height: 700,
        borderRadius: 42,
        background: "#F6EFDD",
        border: `2.5px solid ${INK}`,
        boxShadow: `0 40px 90px rgba(42,37,33,0.28)`,
        position: "relative",
        overflow: "hidden",
      }}
    >
      {/* Notch */}
      <div
        style={{
          position: "absolute",
          top: 16,
          left: "50%",
          transform: "translateX(-50%)",
          width: 88,
          height: 20,
          borderRadius: 12,
          background: INK,
          zIndex: 5,
        }}
      />
      {/* Fake app header — makes it look like reading inside a real app. */}
      <div
        style={{
          position: "absolute",
          top: 52,
          left: 20,
          right: 20,
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          fontSize: 12,
          color: INK_SOFT,
        }}
      >
        <span style={{ fontWeight: 600 }}>@friend</span>
        <span>now</span>
      </div>
      <div
        style={{
          position: "absolute",
          top: 72,
          left: 20,
          right: 20,
          height: 1,
          background: BORDER,
        }}
      />

      {/* Reading pane */}
      <div
        style={{
          position: "absolute",
          top: 88,
          left: 22,
          right: 22,
          fontSize: 15,
          color: INK,
          lineHeight: 1.55,
          fontFamily: "Georgia, serif",
        }}
      >
        {READING_LINES.map((line, i) => (
          <div key={i} style={{ marginBottom: 8, position: "relative" }}>
            {i === HIGHLIGHT_INDEX ? (
              <span>
                {line}
                <span
                  style={{
                    position: "relative",
                    background:
                      variant !== "read"
                        ? `${CARAMEL}55`
                        : "transparent",
                    padding: variant !== "read" ? "1px 4px" : 0,
                    borderRadius: 3,
                    fontWeight: variant !== "read" ? 700 : 400,
                    color: INK,
                  }}
                >
                  delulu
                  {/* Selection handles drop in on the "select" variant. */}
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

      {/* Selection popup menu — the classic Android bubble bar. */}
      {variant === "menu" && (
        <div
          style={{
            position: "absolute",
            top: 156,
            left: 40,
            right: 40,
            transform: `translateY(${(1 - progress) * -8}px)`,
            opacity: progress,
            background: "#FFFCF3",
            border: `1px solid ${BORDER}`,
            borderRadius: 12,
            boxShadow: `0 10px 24px rgba(42,37,33,0.22)`,
            padding: "8px 4px",
            display: "flex",
            justifyContent: "space-around",
            fontSize: 12,
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
              padding: "3px 8px",
              borderRadius: 6,
              // Subtle tap pulse.
              transform: `scale(${1 + Math.sin(progress * Math.PI * 4) * 0.03})`,
            }}
          >
            Define
          </span>
          <span style={{ opacity: 0.55 }}>⋮</span>
        </div>
      )}

      {/* Floating Define card — the payoff */}
      {variant === "card" && (
        <div
          style={{
            position: "absolute",
            top: 190,
            left: 22,
            right: 22,
            opacity: progress,
            transform: `translateY(${(1 - progress) * 22}px)`,
          }}
        >
          <div
            style={{
              background: "#FFFCF3",
              border: `1px solid ${BORDER}`,
              borderRadius: 16,
              padding: 16,
              boxShadow: `0 22px 46px rgba(42,37,33,0.26)`,
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                marginBottom: 6,
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
              <span style={{ fontSize: 16, fontWeight: 700, color: INK }}>
                delulu
              </span>
              <span
                style={{
                  marginLeft: "auto",
                  fontSize: 8,
                  letterSpacing: 1.2,
                  color: CARAMEL,
                  border: `1px solid ${CARAMEL}55`,
                  padding: "2px 6px",
                  borderRadius: 4,
                  fontWeight: 600,
                }}
              >
                GEN Z · SLANG
              </span>
            </div>
            <div style={{ fontSize: 11, color: INK, lineHeight: 1.5 }}>
              Delusional, self-aware. Believing something improbable because
              the belief itself is what keeps you going.
            </div>
            <div
              style={{
                marginTop: 10,
                height: 1,
                background: BORDER,
                opacity: 0.7,
              }}
            />
            <div
              style={{
                marginTop: 6,
                fontSize: 8,
                color: INK_SOFT,
                letterSpacing: 1.2,
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
};

const SelectionHandle: React.FC<{
  side: "left" | "right";
  progress: number;
}> = ({ side, progress }) => (
  <div
    style={{
      position: "absolute",
      top: "100%",
      [side]: side === "left" ? -6 : -6,
      width: 12,
      height: 12,
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

/* ────────────────────────────────────────────────────────────────────────────
 * A left-column "step" panel used by S4/S5/S6.
 * Big numeral + short instruction + one-line explainer.
 * ──────────────────────────────────────────────────────────────────────────── */
const StepPanel: React.FC<{
  n: string;
  title: string;
  body: string;
  frame: number;
}> = ({ n, title, body, frame }) => (
  <div style={{ paddingLeft: 140 }}>
    <div
      style={{
        fontSize: 24,
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
        fontSize: 92,
        fontWeight: 700,
        color: INK,
        letterSpacing: -3,
        lineHeight: 1.02,
        marginTop: 14,
        maxWidth: 700,
        ...driftUp(frame, 12, 22, 30),
      }}
    >
      {title}
    </div>
    <div
      style={{
        fontSize: 22,
        color: INK_SOFT,
        marginTop: 22,
        maxWidth: 560,
        lineHeight: 1.6,
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

/* S1 — the ambient FOMO. Kept from v1. */
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
            ...driftUp(frame, 6, 22),
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
            ...driftUp(frame, 40, 22),
          }}
        >
          You smiled anyway.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S2 — the big type. Kept from v1. */
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
            ...driftUp(frame, 6, 24, 32),
          }}
        >
          Every room speaks<br />its own language.
        </div>
        <div
          style={{
            marginTop: 42,
            width: 88,
            height: 2,
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

/* S3 — the "you've done this" beat. Establishes the friction we're removing.
 *
 * Left: three failure-mode chips (Google · screenshot · ask the group chat).
 * Right: phone in the plain "read" state — the moment before intervention. */
const S3: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneIn = spring({ frame: frame - 4, fps, config: { damping: 200 } });
  return (
    <Paper>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1.1, paddingLeft: 140 }}>
          <div style={{ ...driftUp(frame, 4, 20) }}>
            <Kicker>YOU KNOW THIS MOMENT</Kicker>
          </div>
          <div
            style={{
              fontSize: 72,
              fontWeight: 700,
              color: INK,
              letterSpacing: -2,
              lineHeight: 1.06,
              marginTop: 20,
              maxWidth: 780,
              ...driftUp(frame, 12, 22, 28),
            }}
          >
            Hit a word you don't&nbsp;quite know.
          </div>
          <div
            style={{
              display: "flex",
              flexWrap: "wrap",
              gap: 12,
              marginTop: 30,
              maxWidth: 700,
            }}
          >
            {["Google it", "Screenshot it", "Ask the group chat", "Or nod and hope"].map(
              (label, i) => {
                const t = interpolate(
                  frame,
                  [24 + i * 6, 40 + i * 6],
                  [0, 1],
                  { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE }
                );
                return (
                  <div
                    key={label}
                    style={{
                      opacity: t,
                      transform: `translateY(${(1 - t) * 10}px)`,
                      padding: "10px 16px",
                      background: CARD,
                      border: `1px solid ${BORDER}`,
                      borderRadius: 100,
                      fontSize: 18,
                      color: INK_SOFT,
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
              fontSize: 22,
              color: INK,
              fontStyle: "italic",
              marginTop: 26,
              maxWidth: 620,
              lineHeight: 1.5,
              ...driftUp(frame, 60, 22),
            }}
          >
            Every option costs you your place.
          </div>
        </div>
        <div
          style={{
            flex: 0.9,
            display: "flex",
            justifyContent: "center",
            perspective: 1600,
          }}
        >
          <div
            style={{
              transform: `translateX(${(1 - phoneIn) * 220}px) rotateY(-12deg)`,
              transformStyle: "preserve-3d",
            }}
          >
            <PhoneCanvas variant="read" progress={1} />
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S4 — STEP 1: Select. */
const S4: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneIn = spring({ frame: frame - 2, fps, config: { damping: 200 } });
  const handles = interpolate(frame, [14, 34], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1.05 }}>
          <StepPanel
            n="1"
            title={"Long-press\nthe word."}
            body="Grab it with the handles, drag them wider if you want the whole phrase. Same gesture as Copy or Share."
            frame={frame}
          />
        </div>
        <div
          style={{
            flex: 0.95,
            display: "flex",
            justifyContent: "center",
            perspective: 1600,
          }}
        >
          <div
            style={{
              transform: `translateX(${(1 - phoneIn) * 180}px) rotateY(-12deg)`,
              transformStyle: "preserve-3d",
            }}
          >
            <PhoneCanvas variant="select" progress={handles} />
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S5 — STEP 2: Tap Define. */
const S5: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneIn = spring({ frame: frame - 2, fps, config: { damping: 200 } });
  const menu = interpolate(frame, [10, 30], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1.05 }}>
          <StepPanel
            n="2"
            title={"Tap\nDefine."}
            body='It sits in the same menu as Copy and Share — no permission to grant, no new app to open. Look under the "⋮" if the bar is full.'
            frame={frame}
          />
        </div>
        <div
          style={{
            flex: 0.95,
            display: "flex",
            justifyContent: "center",
            perspective: 1600,
          }}
        >
          <div
            style={{
              transform: `translateX(${(1 - phoneIn) * 180}px) rotateY(-12deg)`,
              transformStyle: "preserve-3d",
            }}
          >
            <PhoneCanvas variant="menu" progress={menu} />
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S6 — STEP 3: The card. */
const S6: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const phoneIn = spring({ frame: frame - 2, fps, config: { damping: 200 } });
  const card = interpolate(frame, [12, 34], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return (
    <Paper>
      <AbsoluteFill style={{ flexDirection: "row", alignItems: "center" }}>
        <div style={{ flex: 1.05 }}>
          <StepPanel
            n="3"
            title={"Read.\nCarry on."}
            body="A small card floats over what you were reading. Tap anywhere outside to dismiss — you're back on the same paragraph, place kept."
            frame={frame}
          />
        </div>
        <div
          style={{
            flex: 0.95,
            display: "flex",
            justifyContent: "center",
            perspective: 1600,
          }}
        >
          <div
            style={{
              transform: `translateX(${(1 - phoneIn) * 180}px) rotateY(-12deg)`,
              transformStyle: "preserve-3d",
            }}
          >
            <PhoneCanvas variant="card" progress={card} />
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S7 — the benefit line. Payoff before brand. */
const S7: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 160px",
          gap: 22,
        }}
      >
        <div
          style={{
            fontSize: 40,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.5,
            textAlign: "center",
            ...driftUp(frame, 4, 22),
          }}
        >
          You never left the app.
        </div>
        <div
          style={{
            fontSize: 40,
            color: INK_SOFT,
            fontWeight: 300,
            letterSpacing: -0.5,
            textAlign: "center",
            ...driftUp(frame, 20, 22),
          }}
        >
          You never asked.
        </div>
        <div
          style={{
            fontSize: 118,
            fontWeight: 700,
            color: INK,
            letterSpacing: -3,
            lineHeight: 1.04,
            marginTop: 18,
            textAlign: "center",
            ...driftUp(frame, 40, 24, 30),
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
        }}
      >
        <div style={{ ...driftUp(frame, 4, 20) }}>
          <AppIcon size={130} />
        </div>
        <div
          style={{
            fontSize: 60,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.8,
            ...driftUp(frame, 12, 20),
          }}
        >
          The Context Dictionary
        </div>
        <div
          style={{
            fontSize: 24,
            color: INK_SOFT,
            letterSpacing: -0.5,
            marginTop: -6,
            ...driftUp(frame, 20, 20),
          }}
        >
          Words have context. Now you do too.
        </div>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 28,
            marginTop: 18,
            ...driftUp(frame, 30, 20),
          }}
        >
          <PlayBadge />
          <span
            style={{
              fontSize: 13,
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

/* ══════════════ TIMELINE (16:9, 960 frames = 32s @ 30fps) ══════════════
 *
 *  0–120   S1  ambient FOMO       (4s)
 *  120–240 S2  big type reveal    (4s)
 *  240–390 S3  "you know this"    (5s)  ← problem
 *  390–540 S4  step 1 — select    (5s)
 *  540–690 S5  step 2 — define    (5s)
 *  690–840 S6  step 3 — the card  (5s)
 *  840–960 S7+S8 benefit + brand  (4s)
 *
 *  S7 and S8 share the last 120 frames, S7 fading out under S8's fade-in.
 * ═══════════════════════════════════════════════════════════════════════ */
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
