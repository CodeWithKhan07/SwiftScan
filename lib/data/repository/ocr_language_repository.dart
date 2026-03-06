import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/ocr_language_model.dart';

class OcrLanguageRepository extends GetxService {
  @override
  void onInit() {
    super.onInit();
    seedDefaults();
  }

  // Use constant for box name
  Box<OcrLanguageModel> get _box =>
      Hive.box<OcrLanguageModel>(AppConstants.ocrLanguagesBox);

  Future<void> seedDefaults() async {
    if (_box.isNotEmpty) return;
    for (final lang in AppConstants.defaultOcrLanguages) {
      await _box.put(lang.code, lang);
    }
  }

  List<OcrLanguageModel> getAll() => _box.values.toList();

  List<OcrLanguageModel> getEnabled() =>
      _box.values.where((l) => l.isEnabled).toList();

  OcrLanguageModel? get(String code) => _box.get(code);

  bool isEnabled(String code) => _box.get(code)?.isEnabled ?? false;

  Stream<BoxEvent> watch() => _box.watch();

  Future<void> setEnabled(String code, {required bool enabled}) async {
    final lang = _box.get(code);
    if (lang == null) return;
    await _box.put(code, lang.copyWith(isEnabled: enabled));
  }

  Future<void> toggle(String code) async {
    final lang = _box.get(code);
    if (lang == null) return;
    if (lang.isEnabled && getEnabled().length == 1) return;

    await _box.put(code, lang.copyWith(isEnabled: !lang.isEnabled));
  }

  Future<void> enableOnly(String code) async {
    for (final lang in _box.values) {
      await _box.put(lang.code, lang.copyWith(isEnabled: lang.code == code));
    }
  }

  static TextRecognitionScript scriptFromCode(String scriptName) {
    switch (scriptName) {
      case 'chinese':
        return TextRecognitionScript.chinese;
      case 'devanagari':
        return TextRecognitionScript.devanagiri;
      case 'japanese':
        return TextRecognitionScript.japanese;
      case 'korean':
        return TextRecognitionScript.korean;
      case 'latin':
      default:
        return TextRecognitionScript.latin;
    }
  }
}
