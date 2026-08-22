import '../../domain/entities/invoice_data.dart';
import '../../app/config/app_config.dart';
import '../../domain/entities/zatca_qr_data.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/entitlement_repository.dart';
import '../../domain/repositories/invoice_intelligence_repository.dart';
import '../services/zatca_qr_parser.dart';

class InvoiceIntelligenceRepositoryImpl
    implements InvoiceIntelligenceRepository {
  InvoiceIntelligenceRepositoryImpl(
    this._ai,
    this._entitlements,
    this._qrParser,
  );
  final AiRepository _ai;
  final EntitlementRepository _entitlements;
  final ZatcaQrParser _qrParser;

  @override
  Future<InvoiceData> extractInvoice(
    String imagePath,
    String fallbackText,
  ) async {
    // Invoice extraction uses AI only after a live endpoint check succeeds.
    if (_ai.available &&
        await _ai.canUseAi() &&
        await _entitlements.consumeAiCredit()) {
      try {
        return await _ai.extractInvoice(imagePath, fallbackText);
      } catch (_) {
        // Fall back locally without charging for a failed cloud extraction.
        await _entitlements.refundAiCredit();
      }
    }
    return _heuristicInvoice(fallbackText);
  }

  InvoiceData _heuristicInvoice(String text) {
    final vatNumber = AppConfig.usesSaudiInvoiceRules
        ? RegExp(r'\b3\d{13}3\b').firstMatch(text)?.group(0) ?? ''
        : '';
    final amounts =
        RegExp(r'(?<!\d)(\d{1,6}(?:[,.]\d{1,3})*(?:\.\d{2})?)(?!\d)')
            .allMatches(text)
            .map(
              (e) =>
                  double.tryParse((e.group(1) ?? '').replaceAll(',', '')) ?? 0,
            )
            .where((e) => e > 0)
            .toList();
    final total = amounts.isEmpty
        ? 0.0
        : amounts.reduce((a, b) => a > b ? a : b);
    final vat = AppConfig.usesSaudiInvoiceRules && total != 0
        ? total * 15 / 115
        : 0.0;
    return InvoiceData(
      vatNumber: vatNumber,
      total: total,
      vatAmount: vat,
      subtotal: total - vat,
      taxableAmount: total - vat,
      vatRate: AppConfig.usesSaudiInvoiceRules ? 15 : 0,
      currency: AppConfig.usesSaudiInvoiceRules ? 'SAR' : '',
      needsReview: true,
    );
  }

  @override
  ZatcaQrData parseZatcaQr(String raw) => _qrParser.parse(raw);
}
