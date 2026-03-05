import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/app_utils.dart';

class AppLockService extends GetxService {
  static const String boxName = 'app_settings';
  static const String _lockKey = 'biometric_lock_enabled';

  final LocalAuthentication _auth = LocalAuthentication();
  late Box _box;

  final RxBool isLockEnabled = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _box = await Hive.openBox(boxName);
    isLockEnabled.value = _box.get(_lockKey, defaultValue: false) as bool;
  }

  Future<bool> get isDeviceSupported => _auth.isDeviceSupported();

  Future<bool> get canCheckBiometrics => _auth.canCheckBiometrics;

  Future<void> toggleLock() async {
    if (!isLockEnabled.value) {
      final ok = await authenticate(
        reason: 'Confirm your identity to enable app lock',
      );
      if (!ok) return;
    }
    isLockEnabled.value = !isLockEnabled.value;
    await _box.put(_lockKey, isLockEnabled.value);
    if (isLockEnabled.value) {
      AppUtils.showSuccess(msg: "Biometric Lock Enabled");
    } else {
      AppUtils.showSuccess(msg: "Biometric Lock Disabled");
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to access SwiftScan',
  }) async {
    if (!isLockEnabled.value) {
      isAuthenticated.value = true;
      return true;
    }
    try {
      final result = await _auth.authenticate(localizedReason: reason);
      isAuthenticated.value = result;
      return result;
    } catch (_) {
      isAuthenticated.value = false;
      return false;
    }
  }

  void lockApp() => isAuthenticated.value = false;
}
