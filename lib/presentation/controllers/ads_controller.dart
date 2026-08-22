import 'dart:async';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/entities/entitlement.dart';
import '../../domain/usecases/ad_usecases.dart';
import '../../domain/usecases/entitlement_usecases.dart';

class AdsController extends GetxController {
  AdsController(this._ads, this._entitlements);

  final AdUseCases _ads;
  final EntitlementUseCases _entitlements;

  final banner = Rxn<BannerAd>();
  final ready = false.obs;
  StreamSubscription<Entitlement>? _entitlementSubscription;

  @override
  void onInit() {
    super.onInit();
    _load();
    _entitlementSubscription = _entitlements.watch().listen((_) => _load());
  }

  Future<void> _load() async {
    final shouldShow =
        _ads.initialized &&
        _entitlements.current.adsEnabled &&
        _ads.bannerId.isNotEmpty;

    if (!shouldShow) {
      await banner.value?.dispose();
      banner.value = null;
      ready.value = false;
      return;
    }

    if (banner.value != null) return;

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _ads.bannerId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loaded) {
          banner.value = loaded as BannerAd;
          ready.value = true;
        },
        onAdFailedToLoad: (failed, _) {
          failed.dispose();
          ready.value = false;
        },
      ),
    );

    banner.value = ad;
    await ad.load();
  }

  @override
  void onClose() {
    _entitlementSubscription?.cancel();
    banner.value?.dispose();
    super.onClose();
  }
}
