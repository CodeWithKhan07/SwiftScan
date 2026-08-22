import '../repositories/preferences_repository.dart';

class PreferenceUseCases {
  const PreferenceUseCases(this._repository);

  final PreferencesRepository _repository;

  Future<bool> isDarkMode() => _repository.isDarkMode();
  Future<void> setDarkMode(bool enabled) => _repository.setDarkMode(enabled);
  Future<bool> isBiometricLockEnabled() => _repository.isBiometricLockEnabled();
  Future<void> setBiometricLockEnabled(bool enabled) =>
      _repository.setBiometricLockEnabled(enabled);
  Future<String?> appLanguage() => _repository.appLanguage();
  Future<void> setAppLanguage(String language) =>
      _repository.setAppLanguage(language);
  Future<String?> appCountryCode() => _repository.appCountryCode();
  Future<void> setAppCountryCode(String countryCode) =>
      _repository.setAppCountryCode(countryCode);
  Future<bool> isOnboardingCompleted() => _repository.isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed) =>
      _repository.setOnboardingCompleted(completed);
}
