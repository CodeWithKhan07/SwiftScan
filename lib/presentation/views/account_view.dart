import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../controllers/account_controller.dart';
import '../widgets/app_components.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          children: [
            const AppScreenTitle('الحساب', 'Account'),
            const SizedBox(height: 18),
            AppSurfaceCard(
              child: Row(
                children: [
                  const AppIconBox(
                    Icons.person_outline_rounded,
                    size: 52,
                    iconSize: 27,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: BilingualText(
                      controller.isAnonymous ? 'وضع الضيف' : 'الحساب متصل',
                      controller.isAnonymous
                          ? 'Guest mode'
                          : 'Account connected',
                    ),
                  ),
                  TextButton(
                    onPressed: controller.openAuth,
                    child: Text(controller.isAnonymous ? 'Sign in' : 'Manage'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppSurfaceCard(
              onTap: controller.openSubscription,
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: BilingualText('الاشتراك', 'Subscription')),
                  Text(
                    controller.entitlement.value.tier.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionTitle(
              ar: 'السحابة والتخزين',
              en: 'Cloud & Storage',
            ),
            const SizedBox(height: 10),
            _SettingTile(
              icon: Icons.cloud_sync_outlined,
              ar: 'مزامنة الآن',
              en: 'Sync now',
              trailing: controller.isSyncing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: controller.syncAll,
            ),
            _SettingTile(
              icon: Icons.cloud_download_outlined,
              ar: 'استعادة من السحابة',
              en: 'Restore from cloud',
              onTap: controller.restoreCloud,
            ),
            const SizedBox(height: 20),
            const AppSectionTitle(
              ar: 'الأمان والمظهر واللغة',
              en: 'Security, Appearance & Language',
            ),
            const SizedBox(height: 10),
            _SettingTile(
              icon: Icons.fingerprint_rounded,
              ar: 'القفل البيومتري',
              en: 'Biometric lock',
              trailing: Switch(
                value: controller.biometricEnabled.value,
                onChanged: controller.toggleBiometric,
              ),
            ),
            _SettingTile(
              icon: Icons.dark_mode_outlined,
              ar: 'الوضع الداكن',
              en: 'Dark mode',
              trailing: Switch(
                value: controller.isDarkMode.value,
                onChanged: controller.toggleTheme,
              ),
            ),
            _SettingTile(
              icon: Icons.language_rounded,
              ar: 'لغة التطبيق',
              en: 'App language',
              trailing: Text(
                controller.languageSelectionLabel,
                style: TextStyle(
                  color: AppColors.accent(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () => _showLanguagePicker(context),
            ),
            const SizedBox(height: 20),
            const AppSectionTitle(ar: 'البيانات', en: 'Data'),
            const SizedBox(height: 10),
            _SettingTile(
              icon: Icons.delete_sweep_outlined,
              ar: 'مسح البيانات المحلية',
              en: 'Clear local data',
              destructive: true,
              onTap: controller.clearLocalData,
            ),
            if (!controller.isAnonymous)
              _SettingTile(
                icon: Icons.logout_rounded,
                ar: 'تسجيل الخروج',
                en: 'Sign out',
                onTap: controller.signOut,
              ),
            if (!controller.isAnonymous)
              _SettingTile(
                icon: Icons.person_remove_outlined,
                ar: 'حذف الحساب',
                en: 'Delete account',
                destructive: true,
                onTap: controller.deleteAccount,
              ),
            const SizedBox(height: 22),
            Text(
              controller.firebaseAvailable.value
                  ? 'Firebase connected • Firebase متصل'
                  : 'Local mode • Firebase config not found / الوضع المحلي',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KSA exposes an ordered primary language and an optional second language.
  Future<void> _showLanguagePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppScreenTitle('لغة التطبيق', 'App Language'),
                const SizedBox(height: 12),
                if (AppConfig.isKsa) ...[
                  _LanguageDropdown(
                    label: 'اللغة الأولى / Primary language',
                    value: controller.primaryLanguage.value,
                    values: controller.availableLanguages,
                    onChanged: controller.setPrimaryLanguage,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const BilingualText(
                      'إظهار لغة ثانية',
                      'Show second language',
                    ),
                    value: controller.secondaryLanguageEnabled.value,
                    onChanged: controller.setSecondaryLanguageEnabled,
                  ),
                  if (controller.secondaryLanguageEnabled.value)
                    _LanguageDropdown(
                      label: 'اللغة الثانية / Secondary language',
                      value: controller.secondaryLanguage.value,
                      values: controller.availableLanguages
                          .where(
                            (value) =>
                                value != controller.primaryLanguage.value,
                          )
                          .toList(growable: false),
                      onChanged: controller.setSecondaryLanguage,
                    ),
                ] else
                  ...controller.availableLanguages.map((language) {
                    final selected = controller.language.value == language;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected
                            ? AppColors.accent(context)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(language.nativeLabel),
                      onTap: () async {
                        await controller.setLanguage(language);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final AppLanguage value;
  final List<AppLanguage> values;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<AppLanguage>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map(
          (language) => DropdownMenuItem(
            value: language,
            child: Text(language.nativeLabel),
          ),
        )
        .toList(growable: false),
    onChanged: (language) {
      if (language != null) onChanged(language);
    },
  );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.ar,
    required this.en,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });
  final IconData icon;
  final String ar, en;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: destructive
                ? Theme.of(context).colorScheme.error
                : AppColors.accent(context),
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BilingualText(
              ar,
              en,
              arStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: destructive ? AppColors.error : null,
              ),
              enStyle: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          trailing ??
              Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ],
      ),
    ),
  );
}
