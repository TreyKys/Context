import React from "react";
import {
  AbsoluteFill,
  Sequence,
  interpolate,
  useCurrentFrame,
} from "remotion";
import {
  AppIcon,
  PlayBadge,
  useBricolage,
  driftUp,
  SceneFade,
  INK,
  INK_SOFT,
  CARAMEL,
  BORDER,
  CARD,
  BG,
  EASE,
  FONT,
} from "./shared";

/* ══════════════════════════════════════════════════════════════════════════
 * Ad #9 — "The Conversation"
 * 9:16 · 1080×1920 · 25s @ 30fps (750 frames).
 *
 * Fundamentally different from the other cream ads: ZERO narration, ZERO
 * labels, ZERO "STEP 1" chrome. The viewer just watches a text thread
 * unfold, slang arrives, a finger long-presses, Define appears, the reply
 * goes out. Shows the feature by using it, not by explaining it.
 *
 * The whole ad takes place inside what looks like a native iMessage view,
 * so when it autoplays in someone's feed it reads as "a message I almost
 * swiped past" rather than "an ad". The brand only lands at the very end.
 * ══════════════════════════════════════════════════════════════════════════ */

/* iMessage-style thread background — slightly whiter cream than the rest of
 * the campaign, so this ad feels like it exists inside an app rather than
 * on an editorial cream page. */
const ThreadFrame: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <AbsoluteFill style={{ background: "#FBF7EC", fontFamily: FONT }}>
    {/* Fake status bar + conversation header. Minimal, just enough to orient. */}
    <div
      style={{
        padding: "70px 36px 20px",
        display: "flex",
        alignItems: "center",
        gap: 14,
        borderBottom: `1px solid ${BORDER}`,
      }}
    >
      <div
        style={{
          width: 48,
          height: 48,
          borderRadius: 24,
          background: `${CARAMEL}33`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: CARAMEL,
          fontWeight: 700,
          fontSize: 22,
        }}
      >
        A
      </div>
      <div style={{ display: "flex", flexDirection: "column" }}>
        <span style={{ fontSize: 22, color: INK, fontWeight: 600 }}>Ada</span>
        <span style={{ fontSize: 14, color: INK_SOFT }}>active now</span>
      </div>
    </div>
    {children}
  </AbsoluteFill>
);

/* A sent (caramel/right) or received (cream/left) bubble. */
const Bubble: React.FC<{
  side: "left" | "right";
  children: React.ReactNode;
  highlight?: number; // 0..1 — how strongly the "mid" word is highlighted
  progress: number; // 0..1 — enter animation
}> = ({ side, children, highlight = 0, progress }) => {
  const slideX = (1 - progress) * (side === "right" ? 60 : -60);
  return (
    <div
      style={{
        alignSelf: side === "left" ? "flex-start" : "flex-end",
        maxWidth: "78%",
        padding: "16px 22px",
        borderRadius: 28,
        background: side === "right" ? CARAMEL : CARD,
        color: side === "right" ? "#FFFCF3" : INK,
        border: side === "left" ? `1px solid ${BORDER}` : "none",
        fontSize: 28,
        lineHeight: 1.3,
        opacity: progress,
        transform: `translate(${slideX}px, ${(1 - progress) * 6}px)`,
        boxShadow:
          side === "left"
            ? `0 2px 4px rgba(42,37,33,0.05)`
            : `0 6px 16px rgba(176,122,71,0.22)`,
      }}
    >
      {typeof children === "string"
        ? children
        : React.Children.map(children, (child) => child)}
      {highlight > 0.01 && null}
    </div>
  );
};

/* Typing indicator — three pulsing dots. */
const TypingDots: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <div
      style={{
        alignSelf: "flex-start",
        background: CARD,
        border: `1px solid ${BORDER}`,
        padding: "14px 22px",
        borderRadius: 24,
        display: "flex",
        gap: 6,
      }}
    >
      {[0, 1, 2].map((i) => (
        <div
          key={i}
          style={{
            width: 10,
            height: 10,
            borderRadius: 5,
            background: INK_SOFT,
            opacity: 0.3 + 0.6 * Math.sin((frame - i * 4) / 6) ** 2,
          }}
        />
      ))}
    </div>
  );
};

/* Finger-tap gesture indicator — a soft circle that scales + fades. */
const FingerTap: React.FC<{ x: number; y: number; progress: number }> = ({
  x,
  y,
  progress,
}) => (
  <div
    style={{
      position: "absolute",
      left: x,
      top: y,
      width: 70,
      height: 70,
      borderRadius: 35,
      border: `3px solid ${CARAMEL}`,
      background: `${CARAMEL}22`,
      opacity: 1 - progress,
      transform: `translate(-50%, -50%) scale(${0.6 + progress * 1.1})`,
      pointerEvents: "none",
    }}
  />
);

/* ────────────────────────────────────────────────────────────────────────────
 * The whole ad is ONE scene — the thread accretes over the full 25s. */

const Conversation: React.FC = () => {
  const frame = useCurrentFrame();

  // Entry timings for each element, in frames.
  const t1 = interpolate(frame, [20, 36], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  const t2 = interpolate(frame, [60, 76], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  const t3 = interpolate(frame, [120, 138], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  // Typing dots appear while they're "thinking"
  const typingIn = interpolate(frame, [170, 185], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  const typingOut = interpolate(frame, [310, 325], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  const typingOpacity = Math.min(typingIn, typingOut);
  // Finger-tap on "mid": at frame ~220, over the slang bubble.
  const tapT = interpolate(frame, [220, 250], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  // Highlight pulse on "mid"
  const highlightOn = interpolate(frame, [250, 262], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  // Define card slides up
  const defIn = interpolate(frame, [280, 310], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  const defOut = interpolate(frame, [460, 490], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  const defOpacity = Math.min(defIn, defOut);
  // Reply bubble enters
  const t4 = interpolate(frame, [510, 540], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });
  // Laugh reaction
  const t5 = interpolate(frame, [600, 620], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE });

  // Reply types itself in character by character.
  const replyFull = "lol you're so right, super mid 😭";
  const typed = Math.min(
    replyFull.length,
    Math.max(
      0,
      Math.floor(
        interpolate(frame, [510, 585], [0, replyFull.length], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        })
      )
    )
  );

  return (
    <ThreadFrame>
      <div
        style={{
          padding: "28px 24px",
          display: "flex",
          flexDirection: "column",
          gap: 14,
          position: "relative",
          height: "100%",
        }}
      >
        {t1 > 0.01 && <Bubble side="right" progress={t1}>did you see her new vid</Bubble>}
        {t2 > 0.01 && <Bubble side="left" progress={t2}>yeah</Bubble>}
        {t3 > 0.01 && (
          <Bubble side="left" progress={t3}>
            she's giving{" "}
            <span
              style={{
                background: `rgba(255,252,243,${0.55 * highlightOn})`,
                padding: highlightOn > 0 ? "2px 6px" : "0",
                borderRadius: 4,
                fontWeight: highlightOn > 0 ? 700 : 400,
              }}
            >
              mid
            </span>{" "}
            ngl 💀
          </Bubble>
        )}
        {typingOpacity > 0.01 && (
          <div style={{ opacity: typingOpacity, display: "flex" }}>
            <TypingDots />
          </div>
        )}

        {/* The finger-tap gesture over "mid" (positioned relative to the thread) */}
        {tapT > 0 && tapT < 1 && (
          <FingerTap x={240} y={430} progress={tapT} />
        )}

        {/* The Define card floats OVER the thread. */}
        {defOpacity > 0.01 && (
          <div
            style={{
              position: "absolute",
              top: 480,
              left: 24,
              right: 24,
              opacity: defOpacity,
              transform: `translateY(${(1 - defIn) * 20}px)`,
              zIndex: 10,
            }}
          >
            <div
              style={{
                background: BG,
                border: `1px solid ${BORDER}`,
                borderRadius: 22,
                padding: 24,
                boxShadow: `0 30px 60px rgba(42,37,33,0.28)`,
              }}
            >
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                  marginBottom: 10,
                }}
              >
                <div style={{ width: 8, height: 8, borderRadius: 4, background: CARAMEL }} />
                <span style={{ fontSize: 30, fontWeight: 700, color: INK }}>mid</span>
                <span
                  style={{
                    marginLeft: "auto",
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: CARAMEL,
                    border: `1px solid ${CARAMEL}55`,
                    padding: "4px 10px",
                    borderRadius: 6,
                    fontWeight: 600,
                  }}
                >
                  GEN Z · SLANG
                </span>
              </div>
              <div style={{ fontSize: 22, color: INK, lineHeight: 1.5 }}>
                Mediocre. Not bad enough to hate, not good enough to remember —
                a dismissal wearing a shrug.
              </div>
              <div style={{ marginTop: 14, height: 1, background: BORDER, opacity: 0.7 }} />
              <div
                style={{
                  marginTop: 10,
                  fontSize: 12,
                  color: INK_SOFT,
                  letterSpacing: 1.6,
                  textTransform: "uppercase",
                }}
              >
                via Context Dictionary
              </div>
            </div>
          </div>
        )}

        {t4 > 0.01 && (
          <Bubble side="right" progress={t4}>
            {typed}
            {typed < replyFull.length && typed > 0 && (
              <span style={{ opacity: 0.6 }}>|</span>
            )}
          </Bubble>
        )}
        {t5 > 0.01 && <Bubble side="left" progress={t5}>😂😂😂</Bubble>}
      </div>
    </ThreadFrame>
  );
};

/* Brand close — understated, lands only at the end. */
const Brand: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: BG, fontFamily: FONT }}>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          gap: 20,
          padding: "0 60px",
        }}
      >
        <div style={{ ...driftUp(frame, 2, 20) }}>
          <AppIcon size={140} />
        </div>
        <div
          style={{
            fontSize: 54,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.5,
            textAlign: "center",
            lineHeight: 1.05,
            ...driftUp(frame, 12, 20),
          }}
        >
          Define in any app.<br />Without leaving it.
        </div>
        <div style={{ marginTop: 18, ...driftUp(frame, 24, 20) }}>
          <PlayBadge />
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

/* ══════════════ TIMELINE (9:16 · 750 frames · 25s @ 30fps) ══════════════ */
export const ContextAd9: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={660}>
        <SceneFade life={660}><Conversation /></SceneFade>
      </Sequence>
      <Sequence from={660} durationInFrames={90}>
        <SceneFade life={90}><Brand /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
