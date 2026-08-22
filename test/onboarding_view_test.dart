import 'package:fatoralens/app/config/app_config.dart';
import 'package:fatoralens/domain/repositories/preferences_repository.dart';
import 'package:fatoralens/domain/usecases/preference_usecases.dart';
import 'package:fatoralens/presentation/controllers/app_locale_controller.dart';
import 'package:fatoralens/presentation/controllers/app_setup_controller.dart';
import 'package:fatoralens/presentation/controllers/onboarding_controller.dart';
import 'package:fatoralens/presentation/views/onboarding_view.dart';
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

  testWidgets('slides reach setup and Saudi selection reveals KSA options', (
    tester,
  ) async {
    // The onboarding owner exposes features first and configuration last.
    final preferences = PreferenceUseCases(_MemoryPreferencesRepository());
    final locale = AppLocaleController(preferences);
    final setup = AppSetupController(preferences);
    final controller = OnboardingController(setup, locale);
    Get.put<OnboardingController>(controller);

    await tester.pumpWidget(const GetMaterialApp(home: OnboardingView()));
    expect(find.text('Scan smarter, anywhere'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Everything documents need'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Make it yours'), findsOneWidget);
    expect(find.text('Choose your country'), findsOneWidget);

    controller.selectCountry(AppCountries.byCode('SA'));
    await tester.pump();

    expect(find.text('Saudi features enabled'), findsOneWidget);
    expect(find.text('Show a second language'), findsOneWidget);
    expect(controller.primaryLanguage.value.name, 'arabic');
    expect(controller.secondaryLanguage.value.name, 'english');
    expect(controller.secondaryLanguageEnabled.value, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class _MemoryPreferencesRepository implements PreferencesRepository {
  @override
  Future<String?> appCountryCode() async => null;

  @override
  Future<String?> appLanguage() async => null;

  @override
  Future<bool> isBiometricLockEnabled() async => false;

  @override
  Future<bool> isDarkMode() async => false;

  @override
  Future<bool> isOnboardingCompleted() async => false;

  @override
  Future<void> setAppCountryCode(String countryCode) async {}

  @override
  Future<void> setAppLanguage(String language) async {}

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}

  @override
  Future<void> setDarkMode(bool enabled) async {}

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}
}
