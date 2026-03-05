import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../core/services/app_lock_service.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/ocr_language_model.dart';
import '../../data/repository/ocr_language_repository.dart';
import '../../data/repository/scan_repository.dart';
import '../../data/repository/translation_repository.dart';
import '../widgets/settings_screen_widgets.dart';

const List<({String code, String label})> kTranslationLanguages = [
  (code: 'af', label: 'Afrikaans'),
  (code: 'ar', label: 'Arabic'),
  (code: 'zh', label: 'Chinese'),
  (code: 'fr', label: 'French'),
  (code: 'de', label: 'German'),
  (code: 'hi', label: 'Hindi'),
  (code: 'id', label: 'Indonesian'),
  (code: 'it', label: 'Italian'),
  (code: 'ja', label: 'Japanese'),
  (code: 'ko', label: 'Korean'),
  (code: 'pt', label: 'Portuguese'),
  (code: 'ru', label: 'Russian'),
  (code: 'es', label: 'Spanish'),
  (code: 'tr', label: 'Turkish'),
  (code: 'uk', label: 'Ukrainian'),
];

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

  RxBool get isLockEnabled => _lockService.isLockEnabled;

  final RxString targetLanguageCode = 'es'.obs;
  final RxBool isDownloadingModel = false.obs;
  final RxString downloadStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguages();
    targetLanguageCode.value = _translationRepo.getTargetLanguageCode();
    _ocrLangRepo.watch().listen((_) => _loadLanguages());
  }

  void _loadLanguages() {
    allLanguages.assignAll(_ocrLangRepo.getAll());
  }

  Future<void> toggleLanguage(String code) async {
    await _ocrLangRepo.toggle(code);
    _loadLanguages();
  }

  Future<void> toggleBiometricLock() async {
    log("Tapped");
    final supported = await _lockService.isDeviceSupported;
    if (!supported) {
      AppUtils.showError(
        msg: 'Biometric authentication not available on this device',
      );
      return;
    }

    await _lockService.toggleLock();
  }

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
      downloadStatus.value = 'Download failed — check connection';
    } finally {
      isDownloadingModel.value = false;
      await Future.delayed(const Duration(seconds: 3));
      downloadStatus.value = '';
    }
  }

  Future<void> clearAllData() async {
    await _scanRepo.clearAll();
    AppUtils.showSuccess(msg: 'All scan data cleared');
  }

  void showOcrLanguageSheet() {
    Get.bottomSheet(
      const OcrLanguageSheet(),
      isScrollControlled: true,
    );
  }

  void showTranslationPicker() {
    Get.bottomSheet(
      const TranslationLanguagePicker(),
      isScrollControlled: true,
    );
  }
}
