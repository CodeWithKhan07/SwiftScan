import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/utils/app_formatters.dart';
import '../../core/utils/app_snackbar.dart';
import '../../domain/entities/invoice_data.dart';
import '../../domain/entities/zatca_qr_data.dart';
import '../../domain/usecases/invoice_usecases.dart';

class QrComparison {
  const QrComparison({
    required this.ar,
    required this.en,
    required this.expected,
    required this.actual,
    required this.matches,
  });

  final String ar;
  final String en;
  final String expected;
  final String actual;
  final bool matches;
}

class QrController extends GetxController {
  QrController(this._invoices);

  final InvoiceUseCases _invoices;

  final scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  final result = Rxn<ZatcaQrData>();
  final comparisons = <QrComparison>[].obs;
  final isScanning = true.obs;

  InvoiceData? expected;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['invoice'] is InvoiceData) {
      expected = args['invoice'] as InvoiceData;
    }
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (!isScanning.value) return;

    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        raw = value;
        break;
      }
    }

    if (raw == null) return;

    isScanning.value = false;
    try {
      // Stop first so duplicate camera frames cannot process the same QR twice.
      await scanner.stop();
      final parsed = _invoices.parseQr(raw);
      result.value = parsed;
      comparisons.assignAll(_compare(parsed));
    } catch (error) {
      isScanning.value = true;
      AppSnackbar.error('Could not read QR code / تعذرت قراءة الرمز: $error');
      try {
        await scanner.start();
      } catch (_) {
        // The view remains usable through its explicit rescan action.
      }
    }
  }

  List<QrComparison> _compare(ZatcaQrData qr) {
    final invoice = expected;
    if (invoice == null) return const [];

    return [
      QrComparison(
        ar: 'الرقم الضريبي',
        en: 'VAT Number',
        expected: invoice.vatNumber,
        actual: qr.vatNumber,
        matches: _same(invoice.vatNumber, qr.vatNumber),
      ),
      QrComparison(
        ar: 'الإجمالي',
        en: 'Total',
        expected: AppFormatters.decimal(invoice.total),
        actual: qr.totalWithVat,
        matches: _money(invoice.total, qr.totalWithVat),
      ),
      QrComparison(
        ar: 'الضريبة',
        en: 'VAT',
        expected: AppFormatters.decimal(invoice.vatAmount),
        actual: qr.vatTotal,
        matches: _money(invoice.vatAmount, qr.vatTotal),
      ),
      QrComparison(
        ar: 'التاريخ',
        en: 'Timestamp',
        expected: '${invoice.issueDate} ${invoice.issueTime}'.trim(),
        actual: qr.timestamp,
        matches: _timestamp(invoice, qr.timestamp),
      ),
    ];
  }

  bool _same(String first, String second) {
    String normalize(String value) =>
        value.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    return normalize(first) == normalize(second);
  }

  bool _money(double expectedValue, String actual) {
    final parsed =
        double.tryParse(actual.replaceAll(',', '').trim()) ?? -999999;
    return (expectedValue - parsed).abs() < 0.02;
  }

  bool _timestamp(InvoiceData invoice, String actual) {
    if (invoice.issueDate.trim().isEmpty) return true;
    final normalized = invoice.issueDate.replaceAll('/', '-');
    return actual.contains(normalized) || actual.contains(invoice.issueDate);
  }

  Future<void> rescan() async {
    if (isScanning.value) return;
    final previousResult = result.value;
    final previousComparisons = comparisons.toList(growable: false);
    result.value = null;
    comparisons.clear();
    try {
      await scanner.start();
      isScanning.value = true;
    } catch (error) {
      isScanning.value = false;
      // Restore the decoded result so retry remains reachable after failure.
      result.value = previousResult;
      comparisons.assignAll(previousComparisons);
      AppSnackbar.error('Camera is unavailable / الكاميرا غير متاحة: $error');
    }
  }

  @override
  void onClose() {
    scanner.dispose();
    super.onClose();
  }
}
