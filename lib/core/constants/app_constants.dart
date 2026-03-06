import 'package:swiftscan/data/models/ocr_language_model.dart';

class AppConstants {
  static const String hiveBoxSettings = 'app_settings';
  static const String hiveBoxOcrLanguages = 'ocr_languages';
  static const String hiveBoxScans = 'swiftscan_box';
  static const String keyBiometricLock = 'biometric_lock_enabled';
  static const String ocrLanguagesBox = 'ocr_languages';
  static const int minImageWidth = 1080;
  static const int minImageHeight = 1080;
  static const int imageQuality = 85;
  static const String scanOutputFolder = 'scans';
  static List<({String code, String label})> kTranslationLanguages = [
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

  static final List<OcrLanguageModel> defaultOcrLanguages = [
    OcrLanguageModel(
      code: 'latin',
      label: 'Latin (English, French, German…)',
      scriptName: 'latin',
      isEnabled: true,
    ),
    OcrLanguageModel(
      code: 'chinese',
      label: 'Chinese (Simplified & Traditional)',
      scriptName: 'chinese',
      isEnabled: false,
    ),
    OcrLanguageModel(
      code: 'devanagari',
      label: 'Devanagari (Hindi, Sanskrit…)',
      scriptName: 'devanagari',
      isEnabled: false,
    ),
    OcrLanguageModel(
      code: 'japanese',
      label: 'Japanese',
      scriptName: 'japanese',
      isEnabled: false,
    ),
    OcrLanguageModel(
      code: 'korean',
      label: 'Korean',
      scriptName: 'korean',
      isEnabled: false,
    ),
  ];
}
