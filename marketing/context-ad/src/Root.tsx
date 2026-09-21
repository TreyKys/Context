import { Composition } from "remotion";
import { ContextAd } from "./ContextAd";
import { ContextAd2 } from "./ContextAd2";
import { ContextAd3 } from "./ContextAd3";
import { ContextAd4 } from "./ContextAd4";
import { ContextAd5 } from "./ContextAd5";
import { ContextAd6 } from "./ContextAd6";
import { ContextAd7 } from "./ContextAd7";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* ── Legacy purple/cyan cut (v1 identity, retired). ── */}
      <Composition
        id="ContextAd"
        component={ContextAd}
        durationInFrames={630}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="ContextAd2"
        component={ContextAd2}
        durationInFrames={630}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="ContextAd3"
        component={ContextAd3}
        durationInFrames={630}
        fps={30}
        width={1920}
        height={1080}
      />

      {/* ── Cream cut (v2 identity, matches app + Play listing). ── */}

      {/* Ad #4 — "The Room You're Locked Out Of" (v2, 32s): cinematic FOMO
          plus an explicit three-step walkthrough of the Define feature. */}
      <Composition
        id="ContextAd4"
        component={ContextAd4}
        durationInFrames={960}
        fps={30}
        width={1920}
        height={1080}
      />
      {/* Ad #5 — "The Meeting Nod": corporate-jargon FOMO, 16:9. */}
      <Composition
        id="ContextAd5"
        component={ContextAd5}
        durationInFrames={600}
        fps={30}
        width={1920}
        height={1080}
      />
      {/* Ad #6 — "Same Word. Different Rooms.": editorial precision, 9:16. */}
      <Composition
        id="ContextAd6"
        component={ContextAd6}
        durationInFrames={660}
        fps={30}
        width={1080}
        height={1920}
      />
      {/* Ad #7 — "Before You Google It": punchy comparison, 1:1. */}
      <Composition
        id="ContextAd7"
        component={ContextAd7}
        durationInFrames={420}
        fps={30}
        width={1080}
        height={1080}
      />
    </>
  );
};
