import { Composition } from "remotion";
import { ContextAd } from "./ContextAd";
import { ContextAd2 } from "./ContextAd2";

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
    </>
  );
};
