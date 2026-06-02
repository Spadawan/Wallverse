import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/config/app_config.dart';

class AdsService {
  RewardedAd? _rewardedAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConfig.admobRewardedAndroid,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    final ad = _rewardedAd;
    if (ad == null) return false;

    var earnedReward = false;

    await ad.show(
      onUserEarnedReward: (_, __) {
        earnedReward = true;
      },
    );

    _rewardedAd = null;
    loadRewardedAd();
    return earnedReward;
  }
}
