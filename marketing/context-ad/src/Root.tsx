import { Composition } from "remotion";
import { ContextAd } from "./ContextAd";
import { ContextAd2 } from "./ContextAd2";
import { ContextAd3 } from "./ContextAd3";

// 9:16 vertical — TikTok / IG Reels / X. 21s at 30fps = 630 frames.
export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* Ad #1 — the social-slang angle ("you nodded, no idea") */}
      <Composition
        id="ContextAd"
        component={ContextAd}
        durationInFrames={630}
        fps={30}
        width={1080}
        height={1920}
      />
      {/* Ad #2 — the everyday plain-English angle */}
      <Composition
        id="ContextAd2"
        component={ContextAd2}
        durationInFrames={630}
        fps={30}
        width={1080}
        height={1920}
      />
      {/* Ad #3 — dark neon "25 ways" angle, 16:9 landscape */}
      <Composition
        id="ContextAd3"
        component={ContextAd3}
        durationInFrames={630}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};
