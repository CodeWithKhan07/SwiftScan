import '../../domain/repositories/preferences_repository.dart';
import '../datasources/local_key_value_data_source.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  const PreferencesRepositoryImpl(this._local);

  static const _darkModeKey = 'dark_mode';
  static const _biometricKey = 'biometric_enabled';
  static const _languageKey = 'app_language';
  static const _countryKey = 'app_country_code';
  static const _onboardingKey = 'onboarding_completed';

  final LocalKeyValueDataSource _local;

  @override
  Future<bool> isDarkMode() async =>
      await _local.read<bool>(_darkModeKey) ?? false;

  @override
  Future<void> setDarkMode(bool enabled) => _local.write(_darkModeKey, enabled);

  @override
  Future<bool> isBiometricLockEnabled() async =>
      await _local.read<bool>(_biometricKey) ?? false;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) =>
      _local.write(_biometricKey, enabled);

  @override
  Future<String?> appLanguage() => _local.read<String>(_languageKey);

  @override
  Future<void> setAppLanguage(String language) =>
      _local.write(_languageKey, language);

  @override
  Future<String?> appCountryCode() => _local.read<String>(_countryKey);

  @override
  Future<void> setAppCountryCode(String countryCode) =>
      _local.write(_countryKey, countryCode);

  @override
  Future<bool> isOnboardingCompleted() async =>
      await _local.read<bool>(_onboardingKey) ?? false;

  @override
  Future<void> setOnboardingCompleted(bool completed) =>
      _local.write(_onboardingKey, completed);
}
