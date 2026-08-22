import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/qr_controller.dart';
import '../widgets/app_components.dart';

class QrView extends GetView<QrController> {
  const QrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const BilingualAppBarTitle(
            'فحص بيانات الفاتورة',
            'Invoice QR Check',
          ),
        ),
        body: controller.result.value == null
            ? _scanner(context)
            : _result(context),
      ),
    );
  }

  Widget _scanner(BuildContext context) => Column(
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller.scanner,
                  onDetect: controller.onDetect,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _QrFramePainter()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: BilingualText(
          'وجّه الكاميرا إلى رمز QR الموجود على الفاتورة',
          'Point the camera at the invoice QR code',
          align: TextAlign.center,
        ),
      ),
    ],
  );

  Widget _result(BuildContext context) {
    final qr = controller.result.value!;
    final checks = controller.comparisons;
    final allMatch = checks.isNotEmpty && checks.every((e) => e.matches);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (allMatch ? AppColors.success : AppColors.primary)
                .withValues(alpha: .09),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (allMatch ? AppColors.success : AppColors.primary)
                  .withValues(alpha: .22),
            ),
          ),
          child: Row(
            children: [
              Icon(
                allMatch ? Icons.verified_outlined : Icons.qr_code_2_rounded,
                color: allMatch ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BilingualText(
                  checks.isEmpty
                      ? 'تمت قراءة رمز QR'
                      : allMatch
                      ? 'بيانات الفاتورة متطابقة'
                      : 'بعض القيم تحتاج مراجعة',
                  checks.isEmpty
                      ? 'QR data decoded'
                      : allMatch
                      ? 'Invoice details match'
                      : 'Some values need review',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppSurfaceCard(
          child: Column(
            children: [
              _row(context, 'البائع', 'Seller', qr.sellerName),
              _row(context, 'الرقم الضريبي', 'VAT Number', qr.vatNumber),
              _row(context, 'الوقت', 'Timestamp', qr.timestamp),
              _row(context, 'الإجمالي', 'Total', qr.totalWithVat),
              _row(context, 'الضريبة', 'VAT', qr.vatTotal),
            ],
          ),
        ),
        if (checks.isNotEmpty) ...[
          const SizedBox(height: 20),
          const AppSectionTitle(ar: 'المقارنة', en: 'Comparison'),
          const SizedBox(height: 10),
          ...checks.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppSurfaceCard(
                padding: const EdgeInsets.all(13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      c.matches
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      color: c.matches ? AppColors.success : AppColors.warning,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BilingualText(
                            c.ar,
                            c.en,
                            arStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            enStyle: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Invoice: ${c.expected}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'QR: ${c.actual}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      c.matches ? 'Matches' : 'Review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: c.matches
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: controller.rescan,
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('إعادة المسح   Scan Again'),
        ),
        const SizedBox(height: 10),
        Text(
          'This screen checks consistency only and does not represent official government certification.\nهذه الأداة لفحص تطابق البيانات ولا تمثل اعتماداً حكومياً رسمياً.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String ar, String en, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}

class _QrFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * .68;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
