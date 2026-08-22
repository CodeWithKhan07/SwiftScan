import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../controllers/home_controller.dart';
import '../widgets/app_animations.dart';
import '../widgets/app_components.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Obx(
      // Home uses one ordinary list; AppShellView exclusively owns bottom nav.
      () => ListView(
        key: const PageStorageKey('homeList'),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          const FadeSlideIn(child: _HomeHeader()),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 70),
            child: _PrimaryScanCard(
              invoiceMode: AppConfig.isKsa,
              onTap: controller.primaryScan,
            ),
          ),
          const SizedBox(height: 16),
          _QuickActions(controller: controller),
          if (AppConfig.isKsa &&
              controller.currentMonthInvoices.isNotEmpty) ...[
            const SizedBox(height: 26),
            const AppSectionTitle(ar: 'ملخص هذا الشهر', en: 'This Month'),
            const SizedBox(height: 12),
            _MonthlySummary(controller: controller),
          ],
          const SizedBox(height: 28),
          const AppSectionTitle(
            ar: 'المستندات الأخيرة',
            en: 'Recent Documents',
          ),
          const SizedBox(height: 12),
          if (controller.recent.isEmpty)
            SizedBox(
              height: 250,
              child: AppEmptyState(
                icon: Icons.description_outlined,
                ar: 'لا توجد مستندات بعد',
                en: 'No documents yet',
                actionAr: AppConfig.isKsa ? 'مسح فاتورة' : 'مسح مستند',
                actionEn: AppConfig.isKsa ? 'Scan Invoice' : 'Scan Document',
                onAction: controller.primaryScan,
              ),
            )
          else
            ...controller.recent.map(
              (document) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DocumentListTile(
                  document: document,
                  onTap: () => controller.openDocument(document),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: BilingualText(
          'فاتورة لينس',
          'FatoraLens',
          arStyle: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          enStyle: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.accentSurface(context),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.notifications_none_rounded,
          color: AppColors.onAccentSurface(context),
          size: 25,
        ),
      ),
    ],
  );
}

class _PrimaryScanCard extends StatelessWidget {
  const _PrimaryScanCard({required this.invoiceMode, required this.onTap});

  final bool invoiceMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppPressScale(
    child: Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 168,
          child: Stack(
            children: [
              PositionedDirectional(
                end: -18,
                top: -18,
                child: Icon(
                  Icons.document_scanner_outlined,
                  color: Colors.white.withValues(alpha: .10),
                  size: 148,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        invoiceMode
                            ? Icons.receipt_long_rounded
                            : Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BilingualText(
                        invoiceMode ? 'مسح فاتورة' : 'مسح مستند',
                        invoiceMode ? 'Scan Invoice' : 'Scan Document',
                        arStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                        enStyle: TextStyle(
                          color: Colors.white.withValues(alpha: .9),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                start: 94,
                end: 22,
                bottom: 22,
                child: Text(
                  invoiceMode
                      ? 'Extract invoice and VAT details automatically'
                      : 'scan_description'.tr,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .84),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      QuickActionCard(
        icon: Icons.document_scanner_outlined,
        ar: 'مسح مستند',
        en: 'Scan Document',
        onTap: controller.scanDocument,
      ),
      if (AppConfig.supportsZatca)
        QuickActionCard(
          icon: Icons.qr_code_scanner_rounded,
          ar: 'فحص ZATCA QR',
          en: 'Verify ZATCA QR',
          onTap: controller.scanQr,
        ),
      QuickActionCard(
        icon: Icons.picture_as_pdf_outlined,
        ar: 'صورة إلى PDF',
        en: 'Image to PDF',
        onTap: controller.openImageToPdf,
      ),
      QuickActionCard(
        icon: Icons.auto_fix_high_rounded,
        ar: 'تحسين مستند',
        en: 'Enhance Document',
        onTap: controller.openEnhanceDocument,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      // A short stagger gives the first screen hierarchy without feeling busy.
      children: actions.indexed
          .map(
            (entry) => FadeSlideIn(
              delay: Duration(milliseconds: 120 + (entry.$1 * 45)),
              offset: 10,
              child: entry.$2,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: MetricCard(
          ar: 'المصروفات',
          en: 'Expenses',
          value: AppFormatters.money(controller.monthlyExpenses, digits: 0),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: MetricCard(
          ar: 'الضريبة',
          en: 'VAT',
          value: AppFormatters.money(controller.monthlyVat, digits: 0),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: MetricCard(
          ar: 'الفواتير',
          en: 'Invoices',
          value: '${controller.currentMonthInvoices.length}',
        ),
      ),
    ],
  );
}
