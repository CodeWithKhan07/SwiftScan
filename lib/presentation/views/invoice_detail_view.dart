import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../domain/entities/invoice_data.dart';
import '../controllers/invoice_detail_controller.dart';
import '../widgets/app_components.dart';

class InvoiceDetailView extends GetView<InvoiceDetailController> {
  const InvoiceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doc = controller.document.value;
      final invoice = doc?.invoice;
      return Scaffold(
        appBar: AppBar(
          title: const BilingualAppBarTitle(
            'بيانات الفاتورة',
            'Invoice Details',
          ),
          actions: [
            TextButton(
              onPressed: controller.editMode.value
                  ? controller.saveEdits
                  : controller.toggleEdit,
              child: Text(
                controller.editMode.value ? 'حفظ  Save' : 'تعديل  Edit',
              ),
            ),
          ],
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : invoice == null
            ? const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                ar: 'بيانات الفاتورة غير متاحة',
                en: 'Invoice data unavailable',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  _StatusBanner(needsReview: invoice.needsReview),
                  const SizedBox(height: 12),
                  _MerchantHeader(controller: controller, invoice: invoice),
                  const SizedBox(height: 12),
                  _FieldsCard(
                    titleAr: 'البائع',
                    titleEn: 'Seller',
                    edit: controller.editMode.value,
                    fields: [
                      _Field(
                        'اسم المنشأة',
                        'Business Name',
                        controller.sellerNameAr,
                        secondary: controller.sellerName,
                      ),
                      _Field(
                        'الرقم الضريبي',
                        'VAT Number',
                        controller.vatNumber,
                      ),
                      _Field(
                        'السجل التجاري',
                        'Commercial Registration',
                        controller.commercialRegistration,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FieldsCard(
                    titleAr: 'الفاتورة',
                    titleEn: 'Invoice',
                    edit: controller.editMode.value,
                    fields: [
                      _Field(
                        'رقم الفاتورة',
                        'Invoice Number',
                        controller.invoiceNumber,
                      ),
                      _Field('التاريخ', 'Date', controller.issueDate),
                      _Field('الوقت', 'Time', controller.issueTime),
                      _Field('المشتري', 'Buyer', controller.buyerName),
                      _Field(
                        'ضريبة المشتري',
                        'Buyer VAT',
                        controller.buyerVatNumber,
                      ),
                      _Field(
                        'طريقة الدفع',
                        'Payment Method',
                        controller.paymentMethod,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AmountCard(
                    controller: controller,
                    edit: controller.editMode.value,
                  ),
                  if (invoice.lineItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LineItems(items: invoice.lineItems),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (AppConfig.supportsZatca) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.verifyQr,
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: const BilingualButtonLabel(
                              'فحص QR',
                              'Verify QR',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.openDocument,
                          icon: const Icon(Icons.description_outlined),
                          label: const BilingualButtonLabel(
                            'المستند',
                            'Document',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: controller.exportPdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('PDF'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: controller.shareInvoiceText,
                          icon: const Icon(Icons.share_outlined),
                          label: const BilingualButtonLabel('مشاركة', 'Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.needsReview});
  final bool needsReview;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: needsReview
          ? AppColors.warning.withValues(alpha: .09)
          : AppColors.accentSurface(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: needsReview
            ? AppColors.warning.withValues(alpha: .25)
            : AppColors.primary.withValues(alpha: .18),
      ),
    ),
    child: Row(
      children: [
        Icon(
          needsReview
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: needsReview
              ? AppColors.warning
              : AppColors.onAccentSurface(context),
          size: 20,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: BilingualText(
            needsReview ? 'راجع بعض القيم' : 'تم استخراج البيانات',
            needsReview
                ? 'Please review extracted values'
                : 'Details extracted successfully',
            arStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            enStyle: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MerchantHeader extends StatelessWidget {
  const _MerchantHeader({required this.controller, required this.invoice});
  final InvoiceDetailController controller;
  final InvoiceData invoice;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accentSurface(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.storefront_outlined,
            color: AppColors.onAccentSurface(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BilingualText(
            invoice.sellerNameAr.isEmpty ? 'فاتورة' : invoice.sellerNameAr,
            invoice.sellerName.isEmpty ? 'Tax Invoice' : invoice.sellerName,
          ),
        ),
        Text(
          AppFormatters.money(invoice.total, currency: invoice.currency),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

class _Field {
  const _Field(this.ar, this.en, this.controller, {this.secondary});
  final String ar, en;
  final TextEditingController controller;
  final TextEditingController? secondary;
}

class _FieldsCard extends StatelessWidget {
  const _FieldsCard({
    required this.titleAr,
    required this.titleEn,
    required this.edit,
    required this.fields,
  });
  final String titleAr, titleEn;
  final bool edit;
  final List<_Field> fields;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualText(titleAr, titleEn),
        const SizedBox(height: 8),
        ...fields.map(
          (f) => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: edit
                ? Column(
                    children: [
                      TextField(
                        controller: f.controller,
                        decoration: InputDecoration(
                          labelText: '${f.ar}  •  ${f.en}',
                        ),
                      ),
                      if (f.secondary != null) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: f.secondary,
                          decoration: InputDecoration(
                            labelText: '${f.en} (English)',
                          ),
                        ),
                      ],
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: BilingualText(
                          f.ar,
                          f.en,
                          arStyle: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          enStyle: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 6,
                        child: Text(
                          f.controller.text.isEmpty ? '—' : f.controller.text,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    ),
  );
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.controller, required this.edit});
  final InvoiceDetailController controller;
  final bool edit;
  @override
  Widget build(BuildContext context) {
    if (edit) {
      return _FieldsCard(
        titleAr: 'المبالغ',
        titleEn: 'Amounts',
        edit: true,
        fields: [
          _Field('المجموع قبل الضريبة', 'Subtotal', controller.subtotal),
          _Field('الخصم', 'Discount', controller.discount),
          _Field('الخاضع للضريبة', 'Taxable Amount', controller.taxableAmount),
          _Field('نسبة الضريبة', 'VAT Rate', controller.vatRate),
          _Field('الضريبة', 'VAT Amount', controller.vatAmount),
          _Field('الإجمالي', 'Total', controller.total),
          _Field('العملة', 'Currency', controller.currency),
        ],
      );
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Theme-aware tint prevents white dark-theme text on a pale surface.
        color: dark ? AppColors.darkSurfaceHigh : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
      ),
      child: Column(
        children: [
          _amountRow(
            context,
            'المجموع قبل الضريبة',
            'Subtotal',
            '${controller.currency.text} ${controller.subtotal.text}',
          ),
          _amountRow(
            context,
            'الضريبة ${controller.vatRate.text}%',
            'VAT',
            '${controller.currency.text} ${controller.vatAmount.text}',
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(child: BilingualText('الإجمالي', 'Total')),
              Text(
                '${controller.currency.text} ${controller.total.text}',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountRow(BuildContext context, String ar, String en, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: BilingualText(
                ar,
                en,
                arStyle: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                enStyle: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _LineItems extends StatelessWidget {
  const _LineItems({required this.items});
  final List<InvoiceLineItem> items;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BilingualText('البنود', 'Line Items'),
        const SizedBox(height: 8),
        ...items
            .take(10)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.description.isEmpty ? 'Item' : item.description,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${AppFormatters.quantity(item.quantity)} × ${AppFormatters.decimal(item.unitPrice)}  =  ${AppFormatters.decimal(item.total)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
      ],
    ),
  );
}
