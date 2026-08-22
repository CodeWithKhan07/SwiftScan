import 'package:get/get.dart';

import '../../app/config/app_config.dart';
import '../../domain/usecases/preference_usecases.dart';

class AppSetupController extends GetxController {
  AppSetupController(this._preferences);

  final PreferenceUseCases _preferences;

  final onboardingCompleted = false.obs;
  final country = AppCountries.options.last.obs;
  bool _initialized = false;

  bool get needsOnboarding => !onboardingCompleted.value;

  Future<void> initialize() async {
    if (_initialized) return;
    final savedCountry = await _preferences.appCountryCode();
    country.value = AppCountries.byCode(savedCountry);
    AppConfig.configureCountry(country.value.code);
    onboardingCompleted.value = await _preferences.isOnboardingCompleted();
    _initialized = true;
  }

  Future<void> saveCountry(AppCountryOption selectedCountry) async {
    // Configure runtime behavior before locale settings are committed.
    country.value = selectedCountry;
    AppConfig.configureCountry(selectedCountry.code);
    await _preferences.setAppCountryCode(selectedCountry.code);
  }

  Future<void> markOnboardingCompleted() async {
    // Persist this flag last so an interrupted setup resumes on next launch.
    await _preferences.setOnboardingCompleted(true);
    onboardingCompleted.value = true;
  }
}
