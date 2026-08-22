import '../entities/invoice_data.dart';
import '../repositories/ai_repository.dart';
import '../repositories/entitlement_repository.dart';

class AiUseCases {
  const AiUseCases(this._ai, this._entitlements);

  final AiRepository _ai;
  final EntitlementRepository _entitlements;

  bool get available => _ai.available;

  Future<InvoiceData?> extractInvoice(String imagePath, String fallbackText) =>
      _withCredit(() => _ai.extractInvoice(imagePath, fallbackText));

  Future<String?> cleanText(String text, String instruction) =>
      _withCredit(() => _ai.cleanText(text, instruction: instruction));

  Future<String?> askDocument(String text, String question) =>
      _withCredit(() => _ai.askDocument(text, question));

  Future<String?> summarize(String text) =>
      _withCredit(() => _ai.summarize(text));

  Future<String?> translate(String text, String targetLanguage) =>
      _withCredit(() => _ai.translate(text, targetLanguage: targetLanguage));

  Future<T?> _withCredit<T>(Future<T> Function() action) async {
    if (!_ai.available) return null;
    // Keep offline attempts local and preserve the user's limited AI credits.
    if (!await _ai.canUseAi()) throw const AiOfflineException();
    if (!await _entitlements.consumeAiCredit()) return null;
    try {
      return await action();
    } catch (_) {
      // Network, App Check, model, and server failures restore the spent credit.
      await _entitlements.refundAiCredit();
      rethrow;
    }
  }
}
