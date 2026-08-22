import '../entities/invoice_data.dart';

/// Signals that an AI action cannot safely start without confirmed internet.
class AiOfflineException implements Exception {
  const AiOfflineException();

  @override
  String toString() => 'AI requires internet / يتطلب الذكاء الاصطناعي الإنترنت';
}

abstract interface class AiRepository {
  bool get available;
  Future<bool> canUseAi();
  Future<String> extractBilingualText(String imagePath);
  Future<InvoiceData> extractInvoice(String imagePath, String fallbackText);
  Future<String> cleanText(String text, {required String instruction});
  Future<String> askDocument(String documentText, String question);
  Future<String> summarize(String documentText);
  Future<String> translate(String text, {required String targetLanguage});
}
