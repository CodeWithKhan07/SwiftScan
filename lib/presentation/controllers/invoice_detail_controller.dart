import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/app_snackbar.dart';
import '../../domain/entities/app_document.dart';
import '../../domain/entities/invoice_data.dart';
import 'base/document_action_controller.dart';

class InvoiceDetailController extends DocumentActionController {
  InvoiceDetailController(super.documents, super.tools, super.device);

  final editMode = false.obs;

  final sellerName = TextEditingController();
  final sellerNameAr = TextEditingController();
  final vatNumber = TextEditingController();
  final commercialRegistration = TextEditingController();
  final invoiceNumber = TextEditingController();
  final issueDate = TextEditingController();
  final issueTime = TextEditingController();
  final buyerName = TextEditingController();
  final buyerVatNumber = TextEditingController();
  final subtotal = TextEditingController();
  final discount = TextEditingController();
  final taxableAmount = TextEditingController();
  final vatRate = TextEditingController();
  final vatAmount = TextEditingController();
  final total = TextEditingController();
  final paymentMethod = TextEditingController();
  final currency = TextEditingController();

  List<TextEditingController> get _fields => <TextEditingController>[
    sellerName,
    sellerNameAr,
    vatNumber,
    commercialRegistration,
    invoiceNumber,
    issueDate,
    issueTime,
    buyerName,
    buyerVatNumber,
    subtotal,
    discount,
    taxableAmount,
    vatRate,
    vatAmount,
    total,
    paymentMethod,
    currency,
  ];

  @override
  Future<void> onDocumentLoaded(AppDocument? value) async {
    _hydrate(value?.invoice ?? const InvoiceData());
  }

  void _hydrate(InvoiceData invoice) {
    sellerName.text = invoice.sellerName;
    sellerNameAr.text = invoice.sellerNameAr;
    vatNumber.text = invoice.vatNumber;
    commercialRegistration.text = invoice.commercialRegistration;
    invoiceNumber.text = invoice.invoiceNumber;
    issueDate.text = invoice.issueDate;
    issueTime.text = invoice.issueTime;
    buyerName.text = invoice.buyerName;
    buyerVatNumber.text = invoice.buyerVatNumber;
    subtotal.text = AppFormatters.decimal(invoice.subtotal);
    discount.text = AppFormatters.decimal(invoice.discount);
    taxableAmount.text = AppFormatters.decimal(invoice.taxableAmount);
    vatRate.text = AppFormatters.decimal(invoice.vatRate);
    vatAmount.text = AppFormatters.decimal(invoice.vatAmount);
    total.text = AppFormatters.decimal(invoice.total);
    paymentMethod.text = invoice.paymentMethod;
    currency.text = invoice.currency;
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;

  InvoiceData get editedInvoice {
    final original = document.value?.invoice ?? const InvoiceData();
    final normalizedCurrency = currency.text.trim();
    return original.copyWith(
      sellerName: sellerName.text.trim(),
      sellerNameAr: sellerNameAr.text.trim(),
      vatNumber: vatNumber.text.trim(),
      commercialRegistration: commercialRegistration.text.trim(),
      invoiceNumber: invoiceNumber.text.trim(),
      issueDate: issueDate.text.trim(),
      issueTime: issueTime.text.trim(),
      buyerName: buyerName.text.trim(),
      buyerVatNumber: buyerVatNumber.text.trim(),
      subtotal: _number(subtotal),
      discount: _number(discount),
      taxableAmount: _number(taxableAmount),
      vatRate: _number(vatRate),
      vatAmount: _number(vatAmount),
      total: _number(total),
      paymentMethod: paymentMethod.text.trim(),
      currency: normalizedCurrency.isEmpty ? 'SAR' : normalizedCurrency,
      needsReview: false,
    );
  }

  void toggleEdit() => editMode.toggle();

  Future<void> saveEdits() async {
    final current = document.value;
    if (current == null) return;

    final updated = current.copyWith(
      invoice: editedInvoice,
      updatedAt: DateTime.now(),
    );
    await documents.save(updated);
    document.value = updated;
    editMode.value = false;
    AppSnackbar.success('Invoice updated / تم تحديث الفاتورة');
  }

  void verifyQr() =>
      Get.toNamed(AppRoutes.qr, arguments: {'invoice': editedInvoice});

  void openDocument() =>
      Get.toNamed(AppRoutes.document, arguments: document.value?.id);

  Future<void> shareInvoiceText() =>
      shareText(document.value?.extractedText ?? '');

  @override
  void onClose() {
    for (final controller in _fields) {
      controller.dispose();
    }
    super.onClose();
  }
}
