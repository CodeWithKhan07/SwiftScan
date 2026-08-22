import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/config/app_config.dart';
import '../../core/localization/app_language.dart';
import '../../domain/usecases/preference_usecases.dart';

class AppLocaleController extends GetxController {
  AppLocaleController(this._preferences);

  final PreferenceUseCases _preferences;
  final language =
      (AppConfig.isKsa ? AppLanguage.bilingual : AppLanguage.english).obs;
  final primaryLanguage =
      (AppConfig.isKsa ? AppLanguage.arabic : AppLanguage.english).obs;
  final secondaryLanguage = AppLanguage.english.obs;
  final secondaryLanguageEnabled = AppConfig.isKsa.obs;

  // KSA and international editions expose the same global language catalog;
  // KSA adds ordered dual-language presentation on top of those choices.
  List<AppLanguage> get availableLanguages => AppLanguage.values
      .where((value) => value != AppLanguage.bilingual)
      .toList(growable: false);

  Locale get locale => primaryLanguage.value.locale;
  bool get showsBothLanguages =>
      AppConfig.isKsa && secondaryLanguageEnabled.value;
  bool get usesArabic => primaryLanguage.value == AppLanguage.arabic;
  bool get isRtl => primaryLanguage.value.isRtl;
  String get languageSelectionLabel => showsBothLanguages
      ? '${primaryLanguage.value.nativeLabel} + ${secondaryLanguage.value.nativeLabel}'
      : primaryLanguage.value.nativeLabel;

  Future<void> initialize() async {
    final saved = await _preferences.appLanguage();
    if (AppConfig.isKsa) {
      _restoreKsaSelection(saved);
      Get.updateLocale(locale);
      return;
    }
    final match = AppLanguage.values.where((value) => value.name == saved);
    if (match.isNotEmpty && availableLanguages.contains(match.first)) {
      language.value = match.first;
      primaryLanguage.value = match.first;
    }
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (!availableLanguages.contains(value)) return;
    if (AppConfig.isKsa) {
      await setPrimaryLanguage(value);
      return;
    }
    primaryLanguage.value = value;
    language.value = value;
    Get.updateLocale(value.locale);
    await _preferences.setAppLanguage(value.preferenceValue);
  }

  // KSA stores any ordered global-language pair, with the second optional.
  Future<void> setPrimaryLanguage(AppLanguage value) async {
    if (!availableLanguages.contains(value)) return;
    primaryLanguage.value = value;
    if (secondaryLanguage.value == value) {
      secondaryLanguage.value = _fallbackSecondaryLanguage(value);
    }
    await _commitKsaSelection();
  }

  // The optional secondary language must remain distinct from the primary.
  Future<void> setSecondaryLanguage(AppLanguage value) async {
    if (!availableLanguages.contains(value) || value == primaryLanguage.value) {
      return;
    }
    secondaryLanguage.value = value;
    await _commitKsaSelection();
  }

  Future<void> setSecondaryLanguageEnabled(bool enabled) async {
    if (!AppConfig.isKsa) return;
    secondaryLanguageEnabled.value = enabled;
    await _commitKsaSelection();
  }

  Future<void> applyOnboardingSelection({
    required AppLanguage primary,
    AppLanguage? secondary,
    bool secondaryEnabled = false,
  }) async {
    // Apply the complete language setup only after country mode is known.
    if (!AppConfig.isKsa) {
      secondaryLanguageEnabled.value = false;
      await setLanguage(primary);
      return;
    }
    primaryLanguage.value = primary;
    secondaryLanguage.value = secondary == null || secondary == primary
        ? _fallbackSecondaryLanguage(primary)
        : secondary;
    secondaryLanguageEnabled.value = secondaryEnabled;
    await _commitKsaSelection();
  }

  void _restoreKsaSelection(String? saved) {
    final legacyLanguage = _selectableLanguage(saved);
    if (legacyLanguage != null) {
      primaryLanguage.value = legacyLanguage;
      secondaryLanguage.value = _fallbackSecondaryLanguage(legacyLanguage);
      secondaryLanguageEnabled.value = false;
    } else if (saved?.startsWith('v2|') == true) {
      final parts = saved!.split('|');
      if (parts.length == 4) {
        final primary = _selectableLanguage(parts[1]);
        final secondary = _selectableLanguage(parts[2]);
        if (primary != null && secondary != null && primary != secondary) {
          primaryLanguage.value = primary;
          secondaryLanguage.value = secondary;
          secondaryLanguageEnabled.value = parts[3] == '1';
        }
      }
    }
    _syncLegacyLanguage();
  }

  Future<void> _commitKsaSelection() async {
    _syncLegacyLanguage();
    Get.updateLocale(locale);
    await _preferences.setAppLanguage(
      'v2|${primaryLanguage.value.name}|${secondaryLanguage.value.name}|${secondaryLanguageEnabled.value ? 1 : 0}',
    );
  }

  void _syncLegacyLanguage() {
    language.value = secondaryLanguageEnabled.value
        ? AppLanguage.bilingual
        : primaryLanguage.value;
  }

  AppLanguage? _selectableLanguage(String? name) {
    if (name == null) return null;
    for (final value in availableLanguages) {
      if (value.name == name) return value;
    }
    return null;
  }

  AppLanguage _fallbackSecondaryLanguage(AppLanguage primary) =>
      primary == AppLanguage.english ? AppLanguage.arabic : AppLanguage.english;
}
