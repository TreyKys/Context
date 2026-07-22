import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quota_service.dart';
import 'consent_service.dart';

final adServiceProvider = Provider<AdService>((ref) {
  final quotaService = ref.watch(quotaServiceProvider);
  return AdService(quotaService);
});

class AdService {
  final QuotaService _quotaService;

  // Real rewarded ad unit in release; Google's official REWARDED *test* unit in
  // debug, so you never accidentally click a live ad while developing (which can
  // get an AdMob account flagged for invalid traffic). Ad-unit IDs are not
  // secret — they are visible in the shipped app either way.
  static const String _realRewardedAdUnitId =
      'ca-app-pub-6864344458492366/4992609826';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String rewardedAdUnitId =
      kDebugMode ? _testRewardedAdUnitId : _realRewardedAdUnitId;

  AdService(this._quotaService);

  Future<void> watchOneAd({
    required VoidCallback onCompleted,
    required VoidCallback onFailed,
  }) async {
    // UMP: don't request ads if consent hasn't been granted (EEA/UK).
    if (!await ConsentService.instance.canRequestAds()) {
      onFailed();
      return;
    }
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
    // UMP: don't request ads if consent hasn't been granted (EEA/UK).
    if (!await ConsentService.instance.canRequestAds()) {
      onFailed();
      return;
    }
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
