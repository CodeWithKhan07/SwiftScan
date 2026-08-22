import '../../domain/entities/invoice_data.dart';
import '../../domain/repositories/ai_repository.dart';
import '../services/firebase_ai_service.dart';
import '../services/ai_prompt_builder.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._service);
  final FirebaseAiService _service;

  @override
  bool get available => _service.available;

  @override
  Future<bool> canUseAi() => _service.canUseAi();

  @override
  Future<String> extractBilingualText(String imagePath) => _service.image(
    imagePath,
    'Extract every visible Arabic and English word exactly. Preserve line breaks. Return only the extracted text.',
    action: AiAction.ocrExtraction,
  );

  @override
  Future<InvoiceData> extractInvoice(String imagePath, String fallbackText) =>
      _service.extractInvoice(imagePath, fallbackText);

  @override
  Future<String> cleanText(String text, {required String instruction}) =>
      _service.text('''
Clean OCR text. Preserve facts, numbers, invoice IDs, VAT numbers, dates and amounts exactly unless there is an obvious OCR character error.
Never invent missing text. Return only the cleaned text.
Instruction: $instruction
Text:
$text
''', action: AiAction.textCleanup);

  @override
  Future<String> askDocument(String documentText, String question) =>
      _service.text('''
Answer only from the document below. If the answer is not present, say that it is not found in the document.
Document:
$documentText
Question: $question
''', action: AiAction.documentQuestion);

  @override
  Future<String> summarize(String documentText) => _service.text(
    'Summarize this document clearly in Arabic and English:\n$documentText',
    action: AiAction.summary,
  );

  @override
  Future<String> translate(
    String text, {
    required String targetLanguage,
  }) => _service.text(
    'Translate the following text to $targetLanguage. Preserve formatting and numbers. Return only the translation:\n$text',
    action: AiAction.translation,
  );
}
