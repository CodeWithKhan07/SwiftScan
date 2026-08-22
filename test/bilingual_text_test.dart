import 'package:fatoralens/app/config/app_config.dart';
import 'package:fatoralens/core/localization/app_language.dart';
import 'package:fatoralens/domain/repositories/preferences_repository.dart';
import 'package:fatoralens/domain/usecases/preference_usecases.dart';
import 'package:fatoralens/presentation/controllers/app_locale_controller.dart';
import 'package:fatoralens/presentation/widgets/app_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    AppConfig.configureCountry('SA');
  });
  tearDown(() {
    AppConfig.configureCountry(null);
    Get.reset();
  });

  testWidgets('KSA dual mode renders the selected global language pair', (
    tester,
  ) async {
    // Runtime Saudi selection activates the ordered bilingual presentation.
    final controller = AppLocaleController(
      PreferenceUseCases(_MemoryPreferencesRepository()),
    );

    // Set the observable state directly so this widget-only test does not
    // trigger GetX application locale updates outside a mounted application.
    controller.primaryLanguage.value = AppLanguage.spanish;
    controller.secondaryLanguage.value = AppLanguage.french;
    controller.secondaryLanguageEnabled.value = true;
    controller.language.value = AppLanguage.bilingual;
    Get.put<AppLocaleController>(controller);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BilingualText('الرئيسية', 'Home')),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);
    expect(find.text('Home'), findsNothing);
  });
}

class _MemoryPreferencesRepository implements PreferencesRepository {
  @override
  Future<String?> appCountryCode() async => null;

  @override
  Future<String?> appLanguage() async => null;

  @override
  Future<bool> isOnboardingCompleted() async => false;

  @override
  Future<void> setAppLanguage(String language) async {}

  @override
  Future<void> setAppCountryCode(String countryCode) async {}

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}

  @override
  Future<bool> isBiometricLockEnabled() async => false;

  @override
  Future<bool> isDarkMode() async => false;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}

  @override
  Future<void> setDarkMode(bool enabled) async {}
}
