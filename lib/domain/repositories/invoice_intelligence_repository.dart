import '../entities/invoice_data.dart';
import '../entities/zatca_qr_data.dart';

abstract interface class InvoiceIntelligenceRepository {
  Future<InvoiceData> extractInvoice(String imagePath, String fallbackText);
  ZatcaQrData parseZatcaQr(String raw);
}
