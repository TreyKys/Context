import { Composition } from "remotion";
import { ContextAd } from "./ContextAd";

// 9:16 vertical — TikTok / IG Reels / X.
// 21s at 30fps = 630 frames.
export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="ContextAd"
      component={ContextAd}
      durationInFrames={630}
      fps={30}
      width={1080}
      height={1920}
    />
  );
};
