import 'dart:async';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  static const fadeInDuration = Duration(milliseconds: 700);
  static const loaderFadeDuration = Duration(milliseconds: 220);
  static const fadeOutDuration = Duration(milliseconds: 440);
  static const exitDelay = Duration(milliseconds: 1700);
  static const navigationDelay = Duration(milliseconds: 2140);

  final showLoader = false.obs;
  final isExiting = false.obs;

  Timer? _loaderTimer;
  Timer? _exitTimer;
  Timer? _navigationTimer;

  @override
  void onReady() {
    super.onReady();

    // Reveal progress only after the main splash content finishes fading in.
    _loaderTimer = Timer(fadeInDuration, () => showLoader.value = true);

    // Fade out the complete splash before replacing it with the application.
    _exitTimer = Timer(exitDelay, () => isExiting.value = true);
    _navigationTimer = Timer(navigationDelay, () {
      if (Get.currentRoute == AppRoutes.splash) {
        Get.offAllNamed<void>(AppRoutes.shell);
      }
    });
  }

  @override
  void onClose() {
    // Route disposal must cancel pending work so another screen is not replaced.
    _loaderTimer?.cancel();
    _exitTimer?.cancel();
    _navigationTimer?.cancel();
    super.onClose();
  }
}
