import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../core/services/app_lock_service.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/ocr_language_model.dart';
import '../../data/repository/ocr_language_repository.dart';
import '../../data/repository/scan_repository.dart';
import '../../data/repository/translation_repository.dart';
import '../widgets/settings_screen_widgets.dart';

class SettingsController extends GetxController {
  final OcrLanguageRepository _ocrLangRepo;
  final AppLockService _lockService;
  final TranslationRepository _translationRepo;
  final ScanRepository _scanRepo;

  SettingsController(
    this._ocrLangRepo,
    this._lockService,
    this._translationRepo,
    this._scanRepo,
  );

  final RxList<OcrLanguageModel> allLanguages = <OcrLanguageModel>[].obs;
  final RxString targetLanguageCode = 'es'.obs;
  final RxBool isDownloadingModel = false.obs;
  final RxString downloadStatus = ''.obs;

  final Rx<ThemeMode> currentTheme = ThemeMode.system.obs;

  final _storage = GetStorage();
  final String _themeKey = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    _initTheme();
    _loadLanguages();

    // Sync translation settings
    targetLanguageCode.value = _translationRepo.getTargetLanguageCode();

    // Watch for OCR language changes
    _ocrLangRepo.watch().listen((_) => _loadLanguages());
  }

  // --- Theme Management ---

  void _initTheme() {
    // Read saved preference from GetStorage (null check defaults to false/light)
    final bool? isDark = _storage.read<bool>(_themeKey);

    if (isDark == null) {
      currentTheme.value = ThemeMode.system;
    } else {
      currentTheme.value = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    // Apply theme mode to the app instance
    Get.changeThemeMode(currentTheme.value);
  }

  void toggleTheme(bool isDark) async {
    // 1. Update the reactive variable
    currentTheme.value = isDark ? ThemeMode.dark : ThemeMode.light;

    // 2. Persist the change
    await _storage.write(_themeKey, isDark);

    // 3. Trigger the global theme change
    Get.changeThemeMode(currentTheme.value);

    // 4. BRIEF DELAY (Critical)
    // We wait for the next frame so Get.context has the updated Theme data
    await Future.delayed(const Duration(milliseconds: 100));

    // 5. Show the snackbar (AppUtils now pulls the correct theme colors)
    if (isDark) {
      AppUtils.showSuccess(msg: 'Dark Mode Enabled');
    } else {
      AppUtils.showSuccess(msg: 'Light Mode Enabled');
    }
  }

  bool get isDarkMode => currentTheme.value == ThemeMode.dark;

  void _loadLanguages() {
    allLanguages.assignAll(_ocrLangRepo.getAll());
  }

  Future<void> toggleLanguage(String code) async {
    await _ocrLangRepo.toggle(code);
    _loadLanguages();
  }

  // --- Security / Biometrics ---

  RxBool get isLockEnabled => _lockService.isLockEnabled;

  Future<void> toggleBiometricLock() async {
    log("Toggling Biometric Lock");
    final supported = await _lockService.isDeviceSupported;
    if (!supported) {
      AppUtils.showError(
        msg: 'Biometric authentication not available on this device',
      );
      return;
    }

    await _lockService.toggleLock();
  }

  // --- Translation Logic ---

  Future<void> setTargetLanguage(String code) async {
    targetLanguageCode.value = code;
    await _translationRepo.setTargetLanguageCode(code);
    await _ensureModelDownloaded(code);
  }

  Future<void> _ensureModelDownloaded(String bcpCode) async {
    final manager = OnDeviceTranslatorModelManager();
    final isDownloaded = await manager.isModelDownloaded(bcpCode);
    if (isDownloaded) return;

    isDownloadingModel.value = true;
    downloadStatus.value = 'Downloading language model…';

    try {
      await manager.downloadModel(bcpCode);
      downloadStatus.value = 'Model ready';
    } catch (e) {
      log("Model download error: $e");
      downloadStatus.value = 'Download failed — check connection';
    } finally {
      isDownloadingModel.value = false;
      // Clear status message after a brief delay
      await Future.delayed(const Duration(seconds: 3));
      downloadStatus.value = '';
    }
  }

  // --- Data Management ---

  Future<void> clearAllData() async {
    try {
      await _scanRepo.clearAll();
      AppUtils.showSuccess(msg: 'All scan data cleared');
    } catch (e) {
      AppUtils.showError(msg: 'Failed to clear data');
    }
  }

  // --- Bottom Sheet UI Helpers ---

  void showOcrLanguageSheet() {
    Get.bottomSheet(
      const OcrLanguageSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showTranslationPicker() {
    Get.bottomSheet(
      const TranslationLanguagePicker(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
