import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../domain/usecases/preference_usecases.dart';
import '../../domain/usecases/security_usecases.dart';

class AppLockController extends GetxController with WidgetsBindingObserver {
  AppLockController(this._preferences, this._security);

  final PreferenceUseCases _preferences;
  final SecurityUseCases _security;

  final locked = false.obs;
  final authenticating = false.obs;
  bool _enabled = false;

  bool get enabled => _enabled;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  Future<void> _loadState() async {
    _enabled = await _preferences.isBiometricLockEnabled();
    if (_enabled) {
      locked.value = true;
      await unlock();
    }
  }

  Future<void> refreshPreference() async {
    _enabled = await _preferences.isBiometricLockEnabled();
    if (!_enabled) locked.value = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      locked.value = true;
      return;
    }

    if (state == AppLifecycleState.resumed && locked.value) {
      unlock();
    }
  }

  Future<void> unlock() async {
    if (!_enabled) {
      locked.value = false;
      return;
    }
    if (authenticating.value) return;

    authenticating.value = true;
    try {
      if (await _security.authenticate()) locked.value = false;
    } finally {
      authenticating.value = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
