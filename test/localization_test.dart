import 'package:fatoralens/app/config/app_config.dart';
import 'package:fatoralens/core/localization/app_language.dart';
import 'package:fatoralens/core/localization/app_translations.dart';
import 'package:fatoralens/domain/repositories/preferences_repository.dart';
import 'package:fatoralens/domain/usecases/preference_usecases.dart';
import 'package:fatoralens/presentation/controllers/app_locale_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    AppConfig.configureCountry(null);
  });
  tearDown(() {
    AppConfig.configureCountry(null);
    Get.reset();
  });

  test('every selectable international language has a GetX locale map', () {
    // Keep the language enum, Material locales, and GetX maps synchronized.
    final translations = AppTranslations().keys;
    for (final language in AppLanguage.values) {
      if (language == AppLanguage.bilingual) continue;
      final locale = language.locale;
      final key = '${locale.languageCode}_${locale.countryCode}';
      expect(AppTranslations.supportedLocales, contains(locale));
      expect(translations, contains(key));
      expect(translations[key], contains('Home'));
      expect(translations[key], contains('Scan Document'));
    }
  });

  test(
    'scope exposes the correct language choices and persists changes',
    () async {
      // KSA is bilingual by default, but both product scopes expose every
      // registered single locale instead of restricting KSA to Arabic/English.
      final repository = _MemoryPreferencesRepository();
      final controller = AppLocaleController(PreferenceUseCases(repository));
      await controller.initialize();

      if (AppConfig.isKsa) {
        expect(controller.language.value, AppLanguage.bilingual);
        expect(controller.primaryLanguage.value, AppLanguage.arabic);
        expect(controller.secondaryLanguage.value, AppLanguage.english);
        expect(controller.secondaryLanguageEnabled.value, isTrue);
        expect(
          controller.availableLanguages,
          hasLength(AppLanguage.values.length - 1),
        );
      } else {
        expect(controller.language.value, AppLanguage.english);
        expect(
          controller.availableLanguages,
          isNot(contains(AppLanguage.bilingual)),
        );
        expect(
          controller.availableLanguages,
          hasLength(AppLanguage.values.length - 1),
        );
      }

      await controller.setLanguage(AppLanguage.spanish);
      if (AppConfig.isKsa) {
        expect(controller.language.value, AppLanguage.bilingual);
        expect(controller.primaryLanguage.value, AppLanguage.spanish);
        expect(repository.savedLanguage, 'v2|spanish|english|1');
      } else {
        expect(controller.language.value, AppLanguage.spanish);
        expect(repository.savedLanguage, AppLanguage.spanish.name);
      }
    },
  );

  test(
    'KSA language order and optional second language are persisted',
    () async {
      // Runtime country selection activates the ordered bilingual contract.
      AppConfig.configureCountry('SA');
      final repository = _MemoryPreferencesRepository();
      final controller = AppLocaleController(PreferenceUseCases(repository));
      await controller.initialize();

      await controller.setPrimaryLanguage(AppLanguage.spanish);
      await controller.setSecondaryLanguage(AppLanguage.french);
      expect(controller.primaryLanguage.value, AppLanguage.spanish);
      expect(controller.secondaryLanguage.value, AppLanguage.french);
      expect(controller.languageSelectionLabel, 'Español + Français');

      await controller.setSecondaryLanguageEnabled(false);
      expect(controller.language.value, AppLanguage.spanish);
      expect(controller.languageSelectionLabel, 'Español');
      expect(repository.savedLanguage, 'v2|spanish|french|0');

      final restored = AppLocaleController(PreferenceUseCases(repository));
      await restored.initialize();
      expect(restored.primaryLanguage.value, AppLanguage.spanish);
      expect(restored.secondaryLanguage.value, AppLanguage.french);
      expect(restored.secondaryLanguageEnabled.value, isFalse);
    },
  );
}

class _MemoryPreferencesRepository implements PreferencesRepository {
  String? savedLanguage;
  String? savedCountryCode;
  bool onboardingCompleted = false;

  @override
  Future<String?> appLanguage() async => savedLanguage;

  @override
  Future<void> setAppLanguage(String language) async {
    savedLanguage = language;
  }

  @override
  Future<String?> appCountryCode() async => savedCountryCode;

  @override
  Future<void> setAppCountryCode(String countryCode) async {
    savedCountryCode = countryCode;
  }

  @override
  Future<bool> isOnboardingCompleted() async => onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    onboardingCompleted = completed;
  }

  @override
  Future<bool> isBiometricLockEnabled() async => false;

  @override
  Future<bool> isDarkMode() async => false;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}

  @override
  Future<void> setDarkMode(bool enabled) async {}
}
