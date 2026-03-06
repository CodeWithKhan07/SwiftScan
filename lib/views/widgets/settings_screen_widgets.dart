import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/resources/theme/app_theme.dart';
import '../settings/settings_controller.dart';
import '../translation/translation_controller.dart';
import 'common_widgets.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomAppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Settings',
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 17,
          color: isDark ? AppColors.darkTextHeader : AppColors.textHeader,
        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                letterSpacing: 1.2,
              ),
            ),
          ),
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
                      color: theme.dividerColor.withValues(alpha: 0.1),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        style: theme.textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextHeader : AppColors.textHeader,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: isDark ? AppColors.darkTextBody : AppColors.textBody,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: (isDark ? AppColors.darkTextBody : AppColors.textBody)
                .withValues(alpha: 0.3),
            size: 20,
          ),
    );
  }
}

class AppearanceGroup extends GetView<SettingsController> {
  const AppearanceGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Section(
      title: 'APPEARANCE',
      children: [
        Obx(
          () => ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                controller.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: Colors.amber,
                size: 18,
              ),
            ),
            title: Text(
              'Dark Mode',
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextHeader : AppColors.textHeader,
              ),
            ),
            subtitle: Text(
              controller.isDarkMode
                  ? 'Deep navy theme active'
                  : 'Classic light theme active',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                color: isDark ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
            trailing: Switch.adaptive(
              value: controller.isDarkMode,
              onChanged: (val) => controller.toggleTheme(val),
              activeColor: AppColors.primary,
            ),
          ),
        ),
      ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.2),
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextHeader
                              : AppColors.textHeader,
                        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
              color: theme.dividerColor.withValues(alpha: 0.2),
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextHeader
                            : AppColors.textHeader,
                      ),
                    ),
                    Text(
                      'Select target language for OCR text',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.dividerColor.withValues(alpha: 0.05),
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
                  color: theme.dividerColor.withValues(alpha: 0.05),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : theme.dividerColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                lang.code.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? AppColors.darkTextBody
                                            : AppColors.textBody),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              lang.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.darkTextHeader
                                          : AppColors.textHeader),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 14,
                color: isDark ? AppColors.darkTextHeader : AppColors.textHeader,
              ),
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
