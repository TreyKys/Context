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
 * Ad #7 — "Before You Google It" (v3, portrait)
 * 9:16 · 1080×1920 · 30s @ 30fps (900 frames).
 *
 * Same 7-beat arc as v2 (1:1, 24s) but taller canvas and slower pace, so
 * each beat gets room to land — especially S4 (tab-multiplying + ticking
 * clock), which is the beat that actually proves the cost of the current
 * alternative. Plays natively on Reels / TikTok / IG Stories / X mobile.
 * ══════════════════════════════════════════════════════════════════════════ */

/* ────────────────────────────────────────────────────────────────────────────
 * Building blocks
 * ──────────────────────────────────────────────────────────────────────────── */

/** iMessage-style thread. Right = sent (caramel), left = received (cream). */
const Bubble: React.FC<{
  side: "left" | "right";
  children: React.ReactNode;
  faded?: boolean;
}> = ({ side, children, faded }) => (
  <div
    style={{
      alignSelf: side === "left" ? "flex-start" : "flex-end",
      maxWidth: "78%",
      padding: "12px 18px",
      borderRadius: 22,
      background: side === "right" ? CARAMEL : CARD,
      color: side === "right" ? "#FFFCF3" : INK,
      border: side === "left" ? `1px solid ${BORDER}` : "none",
      fontSize: 22,
      lineHeight: 1.35,
      opacity: faded ? 0.55 : 1,
      boxShadow:
        side === "left" ? `0 2px 4px rgba(42,37,33,0.05)` : `0 6px 14px rgba(176,122,71,0.22)`,
    }}
  >
    {children}
  </div>
);

/** Fake browser omnibar — reused across the Google beats. */
const BrowserBar: React.FC<{ text: string; caret?: boolean }> = ({
  text,
  caret = false,
}) => (
  <div
    style={{
      background: CARD,
      border: `1px solid ${BORDER}`,
      borderRadius: 40,
      padding: "16px 24px",
      display: "flex",
      alignItems: "center",
      gap: 14,
      width: "82%",
      boxShadow: `0 20px 50px rgba(42,37,33,0.10)`,
    }}
  >
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
      <circle cx="11" cy="11" r="7" stroke={INK_SOFT} strokeWidth="2" />
      <path d="M20 20L16 16" stroke={INK_SOFT} strokeWidth="2" strokeLinecap="round" />
    </svg>
    <div style={{ fontSize: 22, color: INK, fontWeight: 500 }}>
      {text}
      {caret && <span style={{ color: CARAMEL, fontWeight: 400 }}>|</span>}
    </div>
  </div>
);

/** Fake browser tab-strip that grows to communicate "you fell down a rabbit hole". */
const TabStrip: React.FC<{ count: number }> = ({ count }) => {
  const titles = [
    "what does mid mean",
    "mid — Urban Dictionary",
    "mid slang meaning",
    "10 slang words parents…",
    "mid vs mediocre - reddit",
  ];
  return (
    <div
      style={{
        display: "flex",
        gap: 4,
        width: "100%",
        maxWidth: 940,
      }}
    >
      {Array.from({ length: 5 }).map((_, i) => {
        const on = i < count;
        return (
          <div
            key={i}
            style={{
              flex: 1,
              padding: "10px 14px 10px 14px",
              background: on ? CARD : "transparent",
              border: `1px solid ${on ? BORDER : "transparent"}`,
              borderBottom: on ? `1px solid ${CARD}` : `1px solid ${BORDER}`,
              borderRadius: "10px 10px 0 0",
              fontSize: 12,
              color: on ? INK : "transparent",
              whiteSpace: "nowrap",
              overflow: "hidden",
              textOverflow: "ellipsis",
              opacity: on ? 1 : 0,
              transform: on ? "translateY(0)" : "translateY(-6px)",
              transition: "opacity 0.3s, transform 0.3s",
            }}
          >
            {titles[i]}
          </div>
        );
      })}
    </div>
  );
};

/* ══════════════════════════════════════════════════════════════════════════
 * SCENES
 * ══════════════════════════════════════════════════════════════════════════ */

/* S1 — The moment. You're in a chat, they used a word. */
const S1: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 70px",
          gap: 24,
        }}
      >
        <div style={{ ...driftUp(frame, 4, 18) }}>
          <Kicker size={13}>IN YOUR DMS, RIGHT NOW</Kicker>
        </div>
        <div
          style={{
            width: "100%",
            display: "flex",
            flexDirection: "column",
            gap: 10,
            marginTop: 12,
          }}
        >
          <div style={{ ...driftUp(frame, 12, 18) }}>
            <Bubble side="right" faded>
              did you see her new video
            </Bubble>
          </div>
          <div style={{ ...driftUp(frame, 22, 18) }}>
            <Bubble side="left" faded>
              yeah
            </Bubble>
          </div>
          <div style={{ ...driftUp(frame, 32, 22, 26) }}>
            <Bubble side="left">
              she's giving{" "}
              <span
                style={{
                  background: "rgba(255,252,243,0.55)",
                  padding: "1px 6px",
                  borderRadius: 4,
                  fontWeight: 700,
                }}
              >
                mid
              </span>{" "}
              ngl 💀
            </Bubble>
          </div>
        </div>
        <div
          style={{
            fontSize: 34,
            color: INK,
            fontStyle: "italic",
            marginTop: 30,
            textAlign: "center",
            lineHeight: 1.4,
            ...driftUp(frame, 70, 22),
          }}
        >
          A word you don't quite know.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S2 — The Google reflex. Cursor types in the omnibar. */
const S2: React.FC = () => {
  const frame = useCurrentFrame();
  const query = "what does mid mean";
  const typed = Math.min(
    query.length,
    Math.floor(
      interpolate(frame, [10, 60], [0, query.length], {
        extrapolateLeft: "clamp",
        extrapolateRight: "clamp",
      })
    )
  );
  const shown = query.slice(0, typed);
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
          <Kicker size={13}>BEFORE YOU GOOGLE IT…</Kicker>
        </div>
        <div style={{ ...driftUp(frame, 8, 20, 18), width: "100%", display: "flex", justifyContent: "center" }}>
          <BrowserBar text={shown} caret={caret && typed === query.length} />
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S3 — What Google gives you: 47M results, none for your DM. */
const S3: React.FC = () => {
  const frame = useCurrentFrame();
  const listIn = interpolate(frame, [4, 22], [0, 1], {
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
          gap: 22,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 16) }}>
          <Kicker size={12}>ABOUT 47,300,000 RESULTS</Kicker>
        </div>
        <div
          style={{
            width: "84%",
            display: "flex",
            flexDirection: "column",
            gap: 20,
            opacity: listIn,
          }}
        >
          {[
            "12 definitions of mid, explained",
            "The Complete History of the Word 'Mid'",
            "mid - Wiktionary",
            "Why Everyone Started Saying Mid in 2021",
          ].map((title, i) => (
            <div key={i} style={{ display: "flex", flexDirection: "column", gap: 6 }}>
              <div
                style={{
                  fontSize: 20,
                  color: CARAMEL,
                  fontWeight: 500,
                  textDecoration: "underline",
                  opacity: 0.85 - i * 0.08,
                }}
              >
                {title}
              </div>
              <div
                style={{
                  height: 6,
                  width: `${88 - i * 4}%`,
                  background: INK_SOFT,
                  opacity: 0.35,
                  borderRadius: 3,
                }}
              />
              <div
                style={{
                  height: 6,
                  width: `${68 - i * 4}%`,
                  background: INK_SOFT,
                  opacity: 0.35,
                  borderRadius: 3,
                }}
              />
            </div>
          ))}
        </div>
        <div
          style={{
            fontSize: 32,
            color: INK,
            fontStyle: "italic",
            marginTop: 18,
            textAlign: "center",
            lineHeight: 1.4,
            ...driftUp(frame, 90, 22),
          }}
        >
          Twelve definitions.<br />None for your DM.
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S4 — The hidden cost. Tabs multiply, clock ticks. */
const S4: React.FC = () => {
  const frame = useCurrentFrame();
  // Tabs open across the first third; each one lands with a ~25-frame beat.
  const tabs = Math.min(5, Math.floor(interpolate(frame, [10, 120], [0, 5], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  })));
  // Clock ticks up 00:47 → 05:34 across almost the whole scene, so the
  // number is still visibly climbing when the payoff line lands.
  const clockT = interpolate(frame, [10, 155], [47, 334], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const mm = Math.floor(clockT / 60).toString().padStart(2, "0");
  const ss = Math.floor(clockT % 60).toString().padStart(2, "0");
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 60px",
          gap: 30,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 16) }}>
          <Kicker size={12}>AND NOW…</Kicker>
        </div>
        <div style={{ width: "100%", display: "flex", justifyContent: "center" }}>
          <TabStrip count={tabs} />
        </div>
        <div
          style={{
            display: "flex",
            alignItems: "baseline",
            gap: 16,
            fontFamily: "'Courier New', monospace",
            fontVariantNumeric: "tabular-nums",
            marginTop: 6,
          }}
        >
          <span style={{ fontSize: 14, color: INK_SOFT, letterSpacing: 2 }}>
            TIME SPENT
          </span>
          <span
            style={{
              fontSize: 68,
              fontWeight: 700,
              color: INK,
              letterSpacing: -2,
            }}
          >
            {mm}:{ss}
          </span>
        </div>
        <div
          style={{
            fontSize: 40,
            color: INK,
            fontWeight: 700,
            marginTop: 10,
            textAlign: "center",
            lineHeight: 1.25,
            ...driftUp(frame, 80, 22),
          }}
        >
          You wanted to reply.<br />
          <span style={{ color: INK_SOFT, fontWeight: 300 }}>
            Not write a dissertation.
          </span>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S5 — the Context way. Back to the same DM. Long-press → Define → card. */
const S5: React.FC = () => {
  const frame = useCurrentFrame();
  // Card appears late in the scene.
  const cardIn = interpolate(frame, [40, 62], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  // Selection highlight on "mid" fades in early.
  const sel = interpolate(frame, [12, 28], [0, 1], {
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
          padding: "0 70px",
          gap: 22,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 16) }}>
          <Kicker size={13} color={CARAMEL}>OR — ONE TAP, RIGHT HERE</Kicker>
        </div>
        <div
          style={{
            width: "100%",
            display: "flex",
            flexDirection: "column",
            gap: 10,
            position: "relative",
          }}
        >
          <Bubble side="right" faded>did you see her new video</Bubble>
          <Bubble side="left" faded>yeah</Bubble>
          <Bubble side="left">
            she's giving{" "}
            <span
              style={{
                background: `rgba(176,122,71,${0.35 * sel})`,
                padding: sel > 0 ? "1px 6px" : "0",
                borderRadius: 4,
                fontWeight: 700,
              }}
            >
              mid
            </span>{" "}
            ngl 💀
          </Bubble>
          {/* Floating Define card slides up over the thread. */}
          <div
            style={{
              position: "absolute",
              top: 160,
              left: 0,
              right: 0,
              opacity: cardIn,
              transform: `translateY(${(1 - cardIn) * 30}px)`,
              zIndex: 5,
            }}
          >
            <CreamCard style={{ padding: 22 }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 8,
                  marginBottom: 8,
                }}
              >
                <div style={{ width: 7, height: 7, borderRadius: 4, background: CARAMEL }} />
                <span style={{ fontSize: 24, fontWeight: 700, color: INK }}>mid</span>
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
              <div style={{ fontSize: 16, color: INK, lineHeight: 1.5 }}>
                Mediocre. Not bad enough to hate, not good enough to remember —
                a dismissal wearing a shrug.
              </div>
              <div style={{ marginTop: 12, height: 1, background: BORDER, opacity: 0.7 }} />
              <div
                style={{
                  marginTop: 6,
                  fontSize: 10,
                  color: INK_SOFT,
                  letterSpacing: 1.4,
                  textTransform: "uppercase",
                }}
              >
                via Context Dictionary
              </div>
            </CreamCard>
          </div>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S6 — Payoff. You get the reply out and get on with your day. */
const S6: React.FC = () => {
  const frame = useCurrentFrame();
  // The reply bubble types itself in.
  const reply = "lol you're so right, super mid 😭";
  const typed = Math.min(
    reply.length,
    Math.floor(
      interpolate(frame, [10, 46], [0, reply.length], {
        extrapolateLeft: "clamp",
        extrapolateRight: "clamp",
      })
    )
  );
  const shown = reply.slice(0, typed);
  return (
    <Paper>
      <AbsoluteFill
        style={{
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          padding: "0 70px",
          gap: 22,
        }}
      >
        <div style={{ ...driftUp(frame, 2, 16) }}>
          <Kicker size={13}>BACK TO THE REPLY</Kicker>
        </div>
        <div
          style={{
            width: "100%",
            display: "flex",
            flexDirection: "column",
            gap: 10,
          }}
        >
          <Bubble side="left" faded>she's giving mid ngl 💀</Bubble>
          <Bubble side="right">{shown || " "}</Bubble>
        </div>
        <div
          style={{
            fontSize: 62,
            fontWeight: 700,
            color: INK,
            letterSpacing: -2,
            textAlign: "center",
            marginTop: 34,
            lineHeight: 1.06,
            ...driftUp(frame, 60, 24, 30),
          }}
        >
          You didn't need vocabulary.<br />
          <span style={{ color: CARAMEL }}>You needed to reply.</span>
        </div>
      </AbsoluteFill>
    </Paper>
  );
};

/* S7 — brand close. */
const S7: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Paper>
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
          <AppIcon size={130} />
        </div>
        <div
          style={{
            fontSize: 56,
            fontWeight: 700,
            color: INK,
            letterSpacing: -1.8,
            textAlign: "center",
            lineHeight: 1.05,
            ...driftUp(frame, 12, 22),
          }}
        >
          Context Dictionary
        </div>
        <div
          style={{
            fontSize: 20,
            color: INK_SOFT,
            marginTop: 4,
            textAlign: "center",
            ...driftUp(frame, 22, 20),
          }}
        >
          33 rooms · 25 voices · no accounts
        </div>
        <div
          style={{
            display: "flex",
            gap: 22,
            alignItems: "center",
            marginTop: 20,
            ...driftUp(frame, 32, 20),
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

/* ══════════════ TIMELINE (9:16 · 900 frames = 30s @ 30fps) ══════════════
 *
 *  0–130   S1  the moment (in your DMs)      (4.3s)
 *  130–230 S2  the Google reflex             (3.3s)
 *  230–390 S3  47M results, none yours       (5.3s)
 *  390–560 S4  hidden cost — tabs + clock    (5.7s)  ← the money beat
 *  560–730 S5  Or… Context Define card       (5.7s)
 *  730–840 S6  reply typed out + payoff      (3.7s)
 *  840–900 S7  brand close                   (2.0s)
 * ═══════════════════════════════════════════════════════════════════════ */
export const ContextAd7: React.FC = () => {
  useBricolage();
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={130}>
        <SceneFade life={130}><S1 /></SceneFade>
      </Sequence>
      <Sequence from={130} durationInFrames={100}>
        <SceneFade life={100}><S2 /></SceneFade>
      </Sequence>
      <Sequence from={230} durationInFrames={160}>
        <SceneFade life={160}><S3 /></SceneFade>
      </Sequence>
      <Sequence from={390} durationInFrames={170}>
        <SceneFade life={170}><S4 /></SceneFade>
      </Sequence>
      <Sequence from={560} durationInFrames={170}>
        <SceneFade life={170}><S5 /></SceneFade>
      </Sequence>
      <Sequence from={730} durationInFrames={110}>
        <SceneFade life={110}><S6 /></SceneFade>
      </Sequence>
      <Sequence from={840} durationInFrames={60}>
        <SceneFade life={60}><S7 /></SceneFade>
      </Sequence>
    </AbsoluteFill>
  );
};
