import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/config/app_config.dart';
import '../../domain/usecases/preference_usecases.dart';

class AppShellController extends GetxController {
  AppShellController(this._preferences);

  final PreferenceUseCases _preferences;

  final currentIndex = 0.obs;
  final isDarkMode = false.obs;
  bool _initialized = false;

  // Load the saved theme before runApp so the first Flutter frame is correct.
  Future<void> initialize() async {
    if (_initialized) return;
    isDarkMode.value = await _preferences.isDarkMode();
    _initialized = true;
  }

  void openScanner() => Get.toNamed(
    AppRoutes.scanner,
    arguments: {'mode': AppConfig.isKsa ? 'invoice' : 'document'},
  );

  void selectTab(int index) {
    currentIndex.value = index.clamp(0, 3).toInt();
  }

  Future<void> toggleTheme(bool enabled) async {
    isDarkMode.value = enabled;
    await _preferences.setDarkMode(enabled);
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
