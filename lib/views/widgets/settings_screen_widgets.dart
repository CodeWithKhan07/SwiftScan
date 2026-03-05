import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/resources/theme/app_theme.dart';
import '../settings/settings_controller.dart';
import 'common_widgets.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomAppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Settings',
        style: textTheme.titleMedium?.copyWith(fontSize: 17),
      ),
    );
  }
}

class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: AppColors.textBody,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textBody.withValues(alpha: 0.3),
            size: 20,
          ),
    );
  }
}

class OcrLanguagesGroup extends GetView<SettingsController> {
  const OcrLanguagesGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'AI & OCR',
      children: [
        Tile(
          icon: Icons.translate_rounded,
          title: 'OCR Languages',
          subtitle: 'Choose recognition scripts',
          onTap: () => controller.showOcrLanguageSheet(),
        ),
      ],
    );
  }
}

class OcrLanguageSheet extends GetView<SettingsController> {
  const OcrLanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + Get.context!.mediaQueryPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Column(
              children: controller.allLanguages
                  .map(
                    (lang) => ListTile(
                      title: Text(
                        lang.label,
                        style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                      ),
                      trailing: Switch.adaptive(
                        value: lang.isEnabled,
                        onChanged: (_) => controller.toggleLanguage(lang.code),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class TranslationGroup extends GetView<SettingsController> {
  const TranslationGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'TRANSLATION',
      children: [
        Obx(() {
          final lang = kTranslationLanguages.firstWhere(
            (l) => l.code == controller.targetLanguageCode.value,
          );
          return Tile(
            icon: Icons.g_translate_rounded,
            title: 'Target Language',
            subtitle: controller.isDownloadingModel.value
                ? controller.downloadStatus.value
                : lang.label,
            onTap: () => controller.showTranslationPicker(),
            trailing: controller.isDownloadingModel.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          );
        }),
      ],
    );
  }
}

class TranslationLanguagePicker extends GetView<SettingsController> {
  const TranslationLanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Translation Language',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Select target language for OCR text',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kTranslationLanguages.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 64),
                child: Divider(
                  height: 1,
                  color: Colors.black.withValues(alpha: 0.04),
                ),
              ),
              itemBuilder: (context, index) {
                final lang = kTranslationLanguages[index];
                return Obx(() {
                  final isSelected =
                      controller.targetLanguageCode.value == lang.code;

                  return InkWell(
                    onTap: () {
                      controller.setTargetLanguage(lang.code);
                      Get.back();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                lang.code.toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textBody,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              lang.label,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textHeader,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 24,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: Colors.black.withValues(alpha: 0.1),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyGroup extends GetView<SettingsController> {
  const PrivacyGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      title: 'PRIVACY',
      children: [
        Obx(
          () => ListTile(
            leading: const Icon(
              Icons.fingerprint_rounded,
              color: AppColors.primary,
            ),
            title: Text(
              'Biometric Lock',
              style: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
            trailing: Switch.adaptive(
              value: controller.isLockEnabled.value,
              onChanged: (_) => controller.toggleBiometricLock(),
            ),
          ),
        ),
      ],
    );
  }
}

class DangerGroup extends GetView<SettingsController> {
  const DangerGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'LOCAL DATA',
      children: [
        Tile(
          icon: Icons.delete_sweep_outlined,
          title: 'Clear All Data',
          subtitle: 'Permanently wipe all scans',
          iconColor: AppColors.error,
          onTap: () => controller.clearAllData(),
        ),
      ],
    );
  }
}
