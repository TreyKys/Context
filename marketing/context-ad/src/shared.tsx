import React from "react";
import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
  Easing,
  staticFile,
  delayRender,
  continueRender,
} from "remotion";

/* ══ Brand tokens — matches the app + Play store assets ══
 * Palette: warm cream editorial, deep near-black type, caramel accents.
 * Deliberately NO purple, cyan, or neon — those are the retired identity.
 */
export const BG = "#F2EBDD";        // page cream
export const CARD = "#FBF6EC";      // card off-white
export const BORDER = "#E2D8C4";    // hairline
export const INK = "#2A2521";       // near-black type
export const INK_SOFT = "#8A7F6E";  // muted brown text
export const CARAMEL = "#B07A47";   // primary accent
export const GOLD = "#CDA15F";      // secondary accent
export const GRAD = `linear-gradient(120deg, ${CARAMEL}, ${GOLD})`;
export const EASE = Easing.bezier(0.25, 0.1, 0.25, 1);
export const FONT = "Bricolage Grotesque";

/** Load the local Bricolage woff2 the campaign already ships. */
export const useBricolage = () => {
  const [handle] = React.useState(() => delayRender("Bricolage"));
  React.useEffect(() => {
    const f = new FontFace(
      FONT,
      `url(${staticFile("BricolageGrotesque.woff2")}) format('woff2')`,
      { weight: "200 800" }
    );
    f.load()
      .then((l) => {
        document.fonts.add(l);
        continueRender(handle);
      })
      .catch(() => continueRender(handle));
  }, [handle]);
};

/** Slide-and-fade helper: nothing here uses cheap 0→1 opacity alone. */
export const driftUp = (frame: number, start: number, dur = 20, dist = 22) => {
  const p = interpolate(frame, [start, start + dur], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });
  return { opacity: p, transform: `translateY(${(1 - p) * dist}px)` };
};

/** Wrap a scene so it fades in on entry and out before the next Sequence. */
export const SceneFade: React.FC<{ children: React.ReactNode; life: number }> = ({
  children,
  life,
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(
    frame,
    [0, 10, life - 10, life],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: EASE }
  );
  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

/** The cream canvas with a barely-visible warm grain, used by every ad. */
export const Paper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <AbsoluteFill style={{ background: BG, fontFamily: FONT }}>
    {/* Barely-there vignette so pure cream has some depth. */}
    <AbsoluteFill
      style={{
        background:
          "radial-gradient(90% 90% at 50% 40%, transparent 55%, rgba(0,0,0,0.05))",
        pointerEvents: "none",
      }}
    />
    {children}
  </AbsoluteFill>
);

/** The rounded-cream app icon that appears on every brand close. */
export const AppIcon: React.FC<{ size?: number }> = ({ size = 130 }) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: size * 0.22,
      background: CARD,
      border: `1px solid ${BORDER}`,
      boxShadow: `0 20px 40px rgba(176,122,71,0.15)`,
      position: "relative",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
    }}
  >
    <span
      style={{
        fontSize: size * 0.62,
        fontWeight: 700,
        color: INK,
        letterSpacing: -size * 0.03,
        lineHeight: 1,
      }}
    >
      c
    </span>
    <span
      style={{
        position: "absolute",
        top: size * 0.17,
        right: size * 0.16,
        color: CARAMEL,
        fontSize: size * 0.28,
        fontWeight: 700,
        letterSpacing: -1,
      }}
    >
      ,,
    </span>
  </div>
);

/** Google Play badge in the cream palette. */
export const PlayBadge: React.FC = () => (
  <div
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: 14,
      background: CARD,
      border: `1px solid ${BORDER}`,
      borderRadius: 14,
      padding: "14px 24px",
    }}
  >
    <svg width="30" height="34" viewBox="0 0 24 24">
      <path d="M3.18 1.07C2.45 1.5 2 2.28 2 3.18v17.64c0 .9.45 1.68 1.18 2.11l.1.06 9.88-9.88v-.23L3.28 3l-.1.07z" fill={CARAMEL} opacity="0.85" />
      <path d="M16.45 16.27l-3.29-3.3v-.24l3.3-3.29.07.04 3.9 2.22c1.11.63 1.11 1.67 0 2.31l-3.9 2.22-.08.04z" fill={GOLD} />
      <path d="M16.53 16.23L13.16 12.85 3.18 22.83c.37.39.9.54 1.52.2l11.83-6.8" fill={CARAMEL} />
      <path d="M16.53 7.77L4.7 1c-.62-.35-1.15-.2-1.52.2l9.98 9.97 3.37-3.4z" fill={INK} />
    </svg>
    <div style={{ display: "flex", flexDirection: "column", lineHeight: 1.05 }}>
      <span style={{ fontSize: 11, color: INK_SOFT, letterSpacing: 1.4 }}>GET IT ON</span>
      <span style={{ fontSize: 22, color: INK, fontWeight: 700 }}>Google Play</span>
    </div>
  </div>
);

/** A cream card with a hairline border — the recurring container motif. */
export const CreamCard: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ children, style }) => (
  <div
    style={{
      background: CARD,
      border: `1px solid ${BORDER}`,
      borderRadius: 22,
      padding: 28,
      boxShadow: `0 24px 60px rgba(42,37,33,0.08)`,
      ...style,
    }}
  >
    {children}
  </div>
);

/** Small letterspaced label used above headings, cards, and personas. */
export const Kicker: React.FC<{
  children: React.ReactNode;
  color?: string;
  size?: number;
}> = ({ children, color = CARAMEL, size = 14 }) => (
  <div
    style={{
      fontSize: size,
      fontWeight: 600,
      color,
      letterSpacing: 3,
      textTransform: "uppercase",
    }}
  >
    {children}
  </div>
);
