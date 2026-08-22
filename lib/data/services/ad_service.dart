import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';

class AdService {
  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initializeIfConfigured() async {
    const enabled = bool.fromEnvironment('ADMOB_ENABLED', defaultValue: false);
    if (!enabled) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  String get bannerId => kDebugMode
      ? AppConstants.debugAdmobBannerAndroid
      : const String.fromEnvironment('ADMOB_BANNER_ANDROID');

  String get rewardedId => kDebugMode
      ? AppConstants.debugAdmobRewardedAndroid
      : const String.fromEnvironment('ADMOB_REWARDED_ANDROID');

  Future<void> showRewarded({required void Function() onReward}) async {
    if (!_initialized || rewardedId.isEmpty) return;
    await RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) async {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (value) => value.dispose(),
            onAdFailedToShowFullScreenContent: (value, _) => value.dispose(),
          );
          await ad.show(onUserEarnedReward: (_, _) => onReward());
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }
}
