import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../core/utils/app_utils.dart';
import '../../data/repository/translation_repository.dart';

/// Every language ML Kit on-device translation supports.
const List<({String code, String label})> kTranslationLanguages = [
  (code: 'af', label: 'Afrikaans'),
  (code: 'ar', label: 'Arabic'),
  (code: 'be', label: 'Belarusian'),
  (code: 'bg', label: 'Bulgarian'),
  (code: 'bn', label: 'Bengali'),
  (code: 'ca', label: 'Catalan'),
  (code: 'cs', label: 'Czech'),
  (code: 'cy', label: 'Welsh'),
  (code: 'da', label: 'Danish'),
  (code: 'de', label: 'German'),
  (code: 'el', label: 'Greek'),
  (code: 'en', label: 'English'),
  (code: 'eo', label: 'Esperanto'),
  (code: 'es', label: 'Spanish'),
  (code: 'et', label: 'Estonian'),
  (code: 'fi', label: 'Finnish'),
  (code: 'fr', label: 'French'),
  (code: 'ga', label: 'Irish'),
  (code: 'gl', label: 'Galician'),
  (code: 'gu', label: 'Gujarati'),
  (code: 'hi', label: 'Hindi'),
  (code: 'hr', label: 'Croatian'),
  (code: 'ht', label: 'Haitian Creole'),
  (code: 'hu', label: 'Hungarian'),
  (code: 'id', label: 'Indonesian'),
  (code: 'is', label: 'Icelandic'),
  (code: 'it', label: 'Italian'),
  (code: 'ja', label: 'Japanese'),
  (code: 'ka', label: 'Georgian'),
  (code: 'kn', label: 'Kannada'),
  (code: 'ko', label: 'Korean'),
  (code: 'lt', label: 'Lithuanian'),
  (code: 'lv', label: 'Latvian'),
  (code: 'mk', label: 'Macedonian'),
  (code: 'mr', label: 'Marathi'),
  (code: 'ms', label: 'Malay'),
  (code: 'mt', label: 'Maltese'),
  (code: 'nl', label: 'Dutch'),
  (code: 'no', label: 'Norwegian'),
  (code: 'pl', label: 'Polish'),
  (code: 'pt', label: 'Portuguese'),
  (code: 'ro', label: 'Romanian'),
  (code: 'ru', label: 'Russian'),
  (code: 'sk', label: 'Slovak'),
  (code: 'sl', label: 'Slovenian'),
  (code: 'sq', label: 'Albanian'),
  (code: 'sv', label: 'Swedish'),
  (code: 'sw', label: 'Swahili'),
  (code: 'ta', label: 'Tamil'),
  (code: 'te', label: 'Telugu'),
  (code: 'th', label: 'Thai'),
  (code: 'tl', label: 'Filipino'),
  (code: 'tr', label: 'Turkish'),
  (code: 'uk', label: 'Ukrainian'),
  (code: 'ur', label: 'Urdu'),
  (code: 'vi', label: 'Vietnamese'),
  (code: 'zh', label: 'Chinese'),
];

// ─── Model download status ────────────────────────────────────────────────────

enum ModelStatus { unknown, downloading, ready, failed }

class TranslationController extends GetxController {
  final TranslationRepository _repo = Get.find<TranslationRepository>();
  final _modelManager = OnDeviceTranslatorModelManager();

  OnDeviceTranslator? _translator;

  // ── Language selection ────────────────────────────────────────────────────

  final RxString sourceCode = 'en'.obs;
  final RxString targetCode = 'es'.obs;

  // ── Input / output ────────────────────────────────────────────────────────

  /// Text passed in via Get.arguments (from result screen) or typed manually.
  final RxString inputText = ''.obs;
  final RxString translatedText = ''.obs;

  // ── States ────────────────────────────────────────────────────────────────

  final RxBool isTranslating = false.obs;
  final Rx<ModelStatus> modelStatus = ModelStatus.unknown.obs;
  final RxString statusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    sourceCode.value = _repo.getSourceLanguageCode();
    targetCode.value = _repo.getTargetLanguageCode();
    _checkModelStatus(targetCode.value);
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      inputText.value = args;
    }
  }

  @override
  void onClose() {
    _translator?.close();
    super.onClose();
  }

  Future<void> setSource(String code) async {
    if (code == targetCode.value) {
      AppUtils.showError(msg: 'Source and target must be different');
      return;
    }
    sourceCode.value = code;
    await _repo.setSourceLanguageCode(code);
    _clearOutput();
  }

  Future<void> setTarget(String code) async {
    if (code == sourceCode.value) {
      AppUtils.showError(msg: 'Source and target must be different');
      return;
    }
    targetCode.value = code;
    await _repo.setTargetLanguageCode(code);
    _clearOutput();
    await _checkModelStatus(code);
  }

  void swapLanguages() {
    final tmp = sourceCode.value;
    sourceCode.value = targetCode.value;
    targetCode.value = tmp;
    _repo.setSourceLanguageCode(sourceCode.value);
    _repo.setTargetLanguageCode(targetCode.value);
    if (translatedText.value.isNotEmpty) {
      final tmpText = inputText.value;
      inputText.value = translatedText.value;
      translatedText.value = tmpText;
    }

    _checkModelStatus(targetCode.value);
  }

  Future<void> _checkModelStatus(String code) async {
    final downloaded = await _modelManager.isModelDownloaded(code);
    modelStatus.value = downloaded ? ModelStatus.ready : ModelStatus.unknown;
    statusMessage.value = downloaded
        ? ''
        : 'Model not downloaded — will download on first use';
  }

  Future<void> downloadModel() async {
    modelStatus.value = ModelStatus.downloading;
    statusMessage.value = 'Downloading model…';
    try {
      await _modelManager.downloadModel(targetCode.value);
      modelStatus.value = ModelStatus.ready;
      statusMessage.value = '';
    } catch (_) {
      modelStatus.value = ModelStatus.failed;
      statusMessage.value = 'Download failed — check your connection';
    }
  }

  Future<void> deleteModel() async {
    await _modelManager.deleteModel(targetCode.value);
    modelStatus.value = ModelStatus.unknown;
    statusMessage.value = 'Model removed';
  }

  Future<void> translate() async {
    final text = inputText.value.trim();
    if (text.isEmpty) {
      AppUtils.showError(msg: 'Enter some text to translate');
      return;
    }

    if (isTranslating.value) return;

    // Download model on demand if not present
    if (modelStatus.value != ModelStatus.ready) {
      await downloadModel();
      if (modelStatus.value != ModelStatus.ready) return;
    }

    try {
      isTranslating.value = true;
      translatedText.value = '';

      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere(
          (l) => l.bcpCode == sourceCode.value,
          orElse: () => TranslateLanguage.english,
        ),
        targetLanguage: TranslateLanguage.values.firstWhere(
          (l) => l.bcpCode == targetCode.value,
          orElse: () => TranslateLanguage.spanish,
        ),
      );

      translatedText.value = await _translator!.translateText(text);
    } catch (e) {
      AppUtils.showError(msg: 'Translation failed: $e');
    } finally {
      isTranslating.value = false;
    }
  }

  void clearAll() {
    inputText.value = '';
    _clearOutput();
  }

  void _clearOutput() => translatedText.value = '';

  String labelFor(String code) => kTranslationLanguages
      .firstWhere(
        (l) => l.code == code,
        orElse: () => (code: code, label: code.toUpperCase()),
      )
      .label;
}
