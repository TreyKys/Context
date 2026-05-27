import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quota_service.dart';

final adServiceProvider = Provider<AdService>((ref) {
  final quotaService = ref.watch(quotaServiceProvider);
  return AdService(quotaService);
});

class AdService {
  final QuotaService _quotaService;

  // TODO: Replace with your real AdMob Rewarded Ad Unit ID from the Play Console before publishing.
  // Current value is Google's standard test ID — real ads will NOT load with this in production.
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  AdService(this._quotaService);

  Future<void> watchOneAd({
    required VoidCallback onCompleted,
    required VoidCallback onFailed,
  }) async {
    await _loadRewardedAd(
      onAdLoaded: (ad) {
        bool earnedReward = false;
        ad.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            _quotaService.addBonusSearches(1);
            earnedReward = true;
          },
        );
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            if (earnedReward) {
              onCompleted();
            } else {
              onFailed();
            }
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            onFailed();
          },
        );
      },
      onAdFailedToLoad: (error) {
        onFailed();
      },
    );
  }

  Future<void> watchTwoAdsForThree({
    required VoidCallback onCompleted,
    required VoidCallback onFailed,
    required VoidCallback onFallback,
  }) async {
    await _loadRewardedAd(
      onAdLoaded: (ad1) {
        bool earnedReward1 = false;
        ad1.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            // First ad watched. Load second ad immediately.
            earnedReward1 = true;
          },
        );
        ad1.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            if (earnedReward1) {
              _loadSecondAd(onCompleted, onFallback, onFailed);
            } else {
              onFailed();
            }
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            onFailed();
          },
        );
      },
      onAdFailedToLoad: (error) {
        onFailed();
      },
    );
  }

  Future<void> _loadSecondAd(
    VoidCallback onCompleted,
    VoidCallback onFallback,
    VoidCallback onFailed,
  ) async {
    await _loadRewardedAd(
      onAdLoaded: (ad2) {
        bool earnedReward2 = false;
        ad2.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            _quotaService.addBonusSearches(3);
            earnedReward2 = true;
          },
        );
        ad2.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            if (earnedReward2) {
              onCompleted();
            } else {
              // If user skips the second ad, still give them 1 for the first ad.
              _quotaService.addBonusSearches(1);
              onFallback();
              onCompleted();
            }
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _quotaService.addBonusSearches(1);
            onFallback();
            onCompleted();
          },
        );
      },
      onAdFailedToLoad: (error) {
        // Fallback if Ad 2 fails to load
        _quotaService.addBonusSearches(1);
        onFallback();
        onCompleted();
      },
    );
  }

  Future<void> _loadRewardedAd({
    required Function(RewardedAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
