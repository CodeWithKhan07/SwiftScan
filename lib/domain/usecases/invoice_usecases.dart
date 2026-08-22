import '../entities/invoice_data.dart';
import '../entities/zatca_qr_data.dart';
import '../repositories/invoice_intelligence_repository.dart';

class InvoiceUseCases {
  const InvoiceUseCases(this._repository);

  final InvoiceIntelligenceRepository _repository;

  Future<InvoiceData> extract(String imagePath, String fallbackText) =>
      _repository.extractInvoice(imagePath, fallbackText);

  ZatcaQrData parseQr(String raw) => _repository.parseZatcaQr(raw);
}
