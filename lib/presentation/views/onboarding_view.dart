import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/config/app_config.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/app_animations.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingHeader(controller: controller),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                physics: const ClampingScrollPhysics(),
                children: [
                  const _FeatureSlide(
                    icon: Icons.document_scanner_rounded,
                    eyebrow: 'SMART CAPTURE',
                    title: 'Scan smarter, anywhere',
                    description:
                        'Capture invoices and documents with automatic edge detection, accurate OCR, and AI assistance for complex pages.',
                    features: [
                      _FeatureItem(
                        Icons.auto_awesome_rounded,
                        'AI-enhanced OCR',
                      ),
                      _FeatureItem(Icons.offline_bolt_rounded, 'Works offline'),
                      _FeatureItem(Icons.lock_rounded, 'Private by design'),
                    ],
                  ),
                  const _FeatureSlide(
                    icon: Icons.dashboard_customize_rounded,
                    eyebrow: 'ONE TOOLKIT',
                    title: 'Everything documents need',
                    description:
                        'Create, enhance, search, convert, and organize files from one clean workspace built for speed.',
                    features: [
                      _FeatureItem(
                        Icons.picture_as_pdf_rounded,
                        'Powerful PDF tools',
                      ),
                      _FeatureItem(Icons.translate_rounded, 'Global languages'),
                      _FeatureItem(
                        Icons.cloud_done_rounded,
                        'Secure cloud sync',
                      ),
                    ],
                  ),
                  _SetupSlide(controller: controller),
                ],
              ),
            ),
            _OnboardingFooter(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/app_logo.png', width: 42, height: 42),
        ),
        const SizedBox(width: 12),
        Text(
          'FatoraLens',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentSurface(context),
            borderRadius: BorderRadius.circular(99),
          ),
          // Keep the visible model badge synchronized with the country choice.
          child: Obx(
            () => Text(
              controller.isKsaSelected ? 'KSA' : 'GLOBAL',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onAccentSurface(context),
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _FeatureItem {
  const _FeatureItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.features,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final List<_FeatureItem> features;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
    child: FadeSlideIn(
      child: Column(
        children: [
          _FeatureArtwork(icon: icon),
          const SizedBox(height: 34),
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.accent(context),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: features
                .map((feature) => _FeatureChip(feature: feature))
                .toList(growable: false),
          ),
        ],
      ),
    ),
  );
}

class _FeatureArtwork extends StatelessWidget {
  const _FeatureArtwork({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Feature illustration',
    child: Container(
      width: 174,
      height: 174,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B76E5), Color(0xFF174A9A)],
        ),
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .24),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(top: 24, right: 26, child: _Sparkle(size: 18)),
          const Positioned(left: 28, bottom: 30, child: _Sparkle(size: 12)),
          Icon(icon, size: 82, color: Colors.white),
        ],
      ),
    ),
  );
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Icon(
    Icons.auto_awesome_rounded,
    size: size,
    color: Colors.white.withValues(alpha: .72),
  );
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.feature});

  final _FeatureItem feature;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(feature.icon, size: 19, color: AppColors.accent(context)),
        const SizedBox(width: 7),
        Text(
          feature.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _SetupSlide extends StatelessWidget {
  const _SetupSlide({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Make it yours',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Your country controls regional features. Your language can be changed later in Account.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => DropdownButtonFormField<AppCountryOption>(
            initialValue: controller.country.value,
            isExpanded: true,
            menuMaxHeight: 360,
            decoration: const InputDecoration(
              labelText: 'Country or region',
              prefixIcon: Icon(Icons.public_rounded),
            ),
            hint: const Text('Choose your country'),
            items: AppCountries.options
                .map(
                  (country) => DropdownMenuItem(
                    value: country,
                    child: Text('${country.flag}  ${country.name}'),
                  ),
                )
                .toList(growable: false),
            onChanged: controller.selectCountry,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => DropdownButtonFormField<AppLanguage>(
            initialValue: controller.primaryLanguage.value,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'App language',
              prefixIcon: Icon(Icons.language_rounded),
            ),
            items: controller.languages
                .map(
                  (language) => DropdownMenuItem(
                    value: language,
                    child: Text(language.nativeLabel),
                  ),
                )
                .toList(growable: false),
            onChanged: controller.selectPrimaryLanguage,
          ),
        ),
        const SizedBox(height: 14),
        _RegionalOptions(controller: controller),
        Obx(() {
          final error = controller.errorMessage.value;
          if (error == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

class _RegionalOptions extends StatelessWidget {
  const _RegionalOptions({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    if (!controller.isKsaSelected) {
      return const _ModeNotice(
        icon: Icons.public_rounded,
        title: 'Global mode',
        message: 'Universal scanning, OCR, PDF, conversion, and AI tools.',
      );
    }
    return Column(
      children: [
        const _ModeNotice(
          icon: Icons.verified_rounded,
          title: 'Saudi features enabled',
          message: 'Includes ZATCA QR verification, SAR, and Saudi VAT rules.',
        ),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text(
            'Show a second language',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Use one language or an ordered bilingual pair.',
          ),
          value: controller.secondaryLanguageEnabled.value,
          onChanged: controller.toggleSecondaryLanguage,
        ),
        if (controller.secondaryLanguageEnabled.value)
          DropdownButtonFormField<AppLanguage>(
            key: ValueKey(controller.primaryLanguage.value),
            initialValue: controller.secondaryLanguage.value,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Second language',
              prefixIcon: Icon(Icons.translate_rounded),
            ),
            items: controller.languages
                .where(
                  (language) => language != controller.primaryLanguage.value,
                )
                .map(
                  (language) => DropdownMenuItem(
                    value: language,
                    child: Text(language.nativeLabel),
                  ),
                )
                .toList(growable: false),
            onChanged: controller.selectSecondaryLanguage,
          ),
      ],
    );
  });
}

class _ModeNotice extends StatelessWidget {
  const _ModeNotice({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.accentSurface(context),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.onAccentSurface(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(message),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
    child: Obx(() {
      final page = controller.currentPage.value;
      final isLast = page == OnboardingController.pageCount - 1;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              OnboardingController.pageCount,
              (index) => AnimatedContainer(
                duration: AppMotion.standard,
                width: index == page ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index == page
                      ? AppColors.accent(context)
                      : Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (page > 0) ...[
                OutlinedButton(
                  onPressed: controller.isSaving.value ? null : controller.back,
                  child: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton.icon(
                  // The final action validates an unselected country inline;
                  // only an active persistence operation disables retry taps.
                  onPressed: controller.isSaving.value ? null : controller.next,
                  icon: controller.isSaving.value
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                  label: Text(isLast ? 'Start scanning' : 'Continue'),
                ),
              ),
            ],
          ),
        ],
      );
    }),
  );
}
