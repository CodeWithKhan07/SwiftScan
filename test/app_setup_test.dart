import 'package:fatoralens/app/config/app_config.dart';
import 'package:fatoralens/domain/repositories/preferences_repository.dart';
import 'package:fatoralens/domain/usecases/preference_usecases.dart';
import 'package:fatoralens/presentation/controllers/app_setup_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppConfig.configureCountry(null));

  test('new and invalid country state safely uses global mode', () async {
    // Missing first-run data must never activate market-specific behavior.
    final repository = _MemoryPreferencesRepository(countryCode: 'invalid');
    final controller = AppSetupController(PreferenceUseCases(repository));

    await controller.initialize();

    expect(controller.needsOnboarding, isTrue);
    expect(AppConfig.scope, AppScope.global);
    expect(AppConfig.supportsZatca, isFalse);
    expect(AppConfig.usesSaudiInvoiceRules, isFalse);
  });

  test('persisted Saudi selection enables only KSA capabilities', () async {
    // A completed SA setup restores the regional feature model before UI load.
    final repository = _MemoryPreferencesRepository(
      countryCode: 'SA',
      onboardingCompleted: true,
    );
    final controller = AppSetupController(PreferenceUseCases(repository));

    await controller.initialize();

    expect(controller.needsOnboarding, isFalse);
    expect(controller.country.value.code, 'SA');
    expect(AppConfig.scope, AppScope.ksa);
    expect(AppConfig.supportsZatca, isTrue);
    expect(AppConfig.usesSaudiInvoiceRules, isTrue);
  });

  test('completion is stored independently after country selection', () async {
    // Country can be retried safely until onboarding completion is committed.
    final repository = _MemoryPreferencesRepository();
    final controller = AppSetupController(PreferenceUseCases(repository));
    await controller.initialize();

    await controller.saveCountry(AppCountries.byCode('SA'));
    expect(repository.countryCode, 'SA');
    expect(repository.onboardingCompleted, isFalse);

    await controller.markOnboardingCompleted();
    expect(repository.onboardingCompleted, isTrue);
    expect(controller.needsOnboarding, isFalse);
  });
}

class _MemoryPreferencesRepository implements PreferencesRepository {
  _MemoryPreferencesRepository({
    this.countryCode,
    this.onboardingCompleted = false,
  });

  String? countryCode;
  bool onboardingCompleted;

  @override
  Future<String?> appCountryCode() async => countryCode;

  @override
  Future<void> setAppCountryCode(String countryCode) async {
    this.countryCode = countryCode;
  }

  @override
  Future<bool> isOnboardingCompleted() async => onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    onboardingCompleted = completed;
  }

  @override
  Future<String?> appLanguage() async => null;

  @override
  Future<void> setAppLanguage(String language) async {}

  @override
  Future<bool> isBiometricLockEnabled() async => false;

  @override
  Future<bool> isDarkMode() async => false;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}

  @override
  Future<void> setDarkMode(bool enabled) async {}
}
