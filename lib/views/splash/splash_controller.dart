import 'package:get/get.dart';
import 'package:swiftscan/core/routes/app_routes.dart';
import 'package:swiftscan/core/services/app_lock_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startApp();
  }

  void _startApp() async {
    await Future.delayed(const Duration(seconds: 3));

    final lockService = Get.find<AppLockService>();
    if (lockService.isLockEnabled.value) {
      Get.offNamed(RouteNames.authGate, arguments: {'fromSplash': true});
    } else {
      lockService.isAuthenticated.value = true;
      Get.offAllNamed(RouteNames.main);
    }
  }
}
