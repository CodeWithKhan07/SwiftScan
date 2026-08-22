import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/entitlement.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/app_components.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) => Obx(
    () => Scaffold(
      appBar: AppBar(
        title: const BilingualAppBarTitle('اختر خطتك', 'Choose Your Plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const BilingualText(
            'أدوات أكثر، بدون إعلانات',
            'More tools. No ads.',
            arStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            enStyle: TextStyle(fontSize: 13, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          _PlanCard(
            titleAr: 'مجاني',
            titleEn: 'Free',
            selected:
                controller.entitlement.value.tier == SubscriptionTier.free,
            features: const [
              'مسح و OCR محلي • Local scan & OCR',
              'PDF أساسي • Basic PDF',
              'إعلانات عند تفعيلها • Ads when enabled',
              'AI محدود • Limited AI',
            ],
          ),
          const SizedBox(height: 12),
          _PlanCard(
            titleAr: 'احترافي',
            titleEn: 'Pro',
            highlighted: true,
            selected: controller.entitlement.value.tier == SubscriptionTier.pro,
            features: const [
              'بدون إعلانات • No ads',
              'تحسين المستند • Document enhancement',
              'تحويلات متقدمة • Advanced conversions',
              'AI أكثر • Higher AI allowance',
              'سحابة عند تفعيلها • Cloud when enabled',
            ],
            primaryAction: controller.buyProMonthly,
            secondaryAction: controller.buyProAnnual,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            titleAr: 'أعمال',
            titleEn: 'Business',
            selected:
                controller.entitlement.value.tier == SubscriptionTier.business,
            features: const [
              'كل ميزات Pro • Everything in Pro',
              'حد AI أعلى • Highest AI allowance',
              'سعة سحابية أعلى • Higher cloud allowance',
              'أدوات فواتير الأعمال • Business invoice tools',
            ],
            primaryAction: controller.buyBusinessMonthly,
            secondaryAction: controller.buyBusinessAnnual,
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: controller.restore,
            child: const Text('استعادة المشتريات   Restore Purchases'),
          ),
          const SizedBox(height: 12),
          Text(
            'Store prices are loaded by Google Play after you create the matching product IDs. No fake countdowns or forced annual plan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.titleAr,
    required this.titleEn,
    required this.features,
    this.highlighted = false,
    this.selected = false,
    this.primaryAction,
    this.secondaryAction,
  });
  final String titleAr, titleEn;
  final List<String> features;
  final bool highlighted, selected;
  final VoidCallback? primaryAction, secondaryAction;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      // Highlighted plans retain readable contrast in both brightness modes.
      color: highlighted
          ? (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceHigh
                : AppColors.primarySoft)
          : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: highlighted || selected
            ? AppColors.primary
            : Theme.of(context).dividerColor,
        width: highlighted ? 1.5 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: BilingualText(
                titleAr,
                titleEn,
                arStyle: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
                enStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.accent(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
          ],
        ),
        const SizedBox(height: 12),
        ...features.map(
          (f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 14))),
              ],
            ),
          ),
        ),
        if (primaryAction != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: primaryAction,
                  child: const Text('شهري  Monthly'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: secondaryAction,
                  child: const Text('سنوي  Annual'),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
