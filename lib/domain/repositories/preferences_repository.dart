abstract interface class PreferencesRepository {
  Future<bool> isDarkMode();
  Future<void> setDarkMode(bool enabled);
  Future<bool> isBiometricLockEnabled();
  Future<void> setBiometricLockEnabled(bool enabled);
  Future<String?> appLanguage();
  Future<void> setAppLanguage(String language);
  Future<String?> appCountryCode();
  Future<void> setAppCountryCode(String countryCode);
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
}
