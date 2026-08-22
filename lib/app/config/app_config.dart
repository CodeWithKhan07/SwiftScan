enum AppScope { global, ksa }

class AppCountryOption {
  const AppCountryOption({
    required this.code,
    required this.name,
    required this.flag,
  });

  final String code;
  final String name;
  final String flag;
}

/// Runtime product configuration loaded from the first-run country selection.
abstract final class AppConfig {
  static const globalCountryCode = 'GLOBAL';
  static String _countryCode = globalCountryCode;

  static String get countryCode => _countryCode;
  static AppScope get scope => isKsa ? AppScope.ksa : AppScope.global;
  static bool get isKsa => _countryCode == 'SA';
  static bool get supportsZatca => isKsa;
  static bool get usesSaudiInvoiceRules => isKsa;

  // Unknown, empty, and malformed values safely remain in the global model.
  static void configureCountry(String? countryCode) {
    final normalized = countryCode?.trim().toUpperCase();
    _countryCode = normalized == 'SA' ? 'SA' : globalCountryCode;
  }
}

/// A concise country picker with a global fallback for every unlisted country.
abstract final class AppCountries {
  static const options = <AppCountryOption>[
    AppCountryOption(code: 'SA', name: 'Saudi Arabia', flag: '🇸🇦'),
    AppCountryOption(code: 'AE', name: 'United Arab Emirates', flag: '🇦🇪'),
    AppCountryOption(code: 'BH', name: 'Bahrain', flag: '🇧🇭'),
    AppCountryOption(code: 'KW', name: 'Kuwait', flag: '🇰🇼'),
    AppCountryOption(code: 'OM', name: 'Oman', flag: '🇴🇲'),
    AppCountryOption(code: 'QA', name: 'Qatar', flag: '🇶🇦'),
    AppCountryOption(code: 'EG', name: 'Egypt', flag: '🇪🇬'),
    AppCountryOption(code: 'PK', name: 'Pakistan', flag: '🇵🇰'),
    AppCountryOption(code: 'IN', name: 'India', flag: '🇮🇳'),
    AppCountryOption(code: 'US', name: 'United States', flag: '🇺🇸'),
    AppCountryOption(code: 'GB', name: 'United Kingdom', flag: '🇬🇧'),
    AppCountryOption(code: 'FR', name: 'France', flag: '🇫🇷'),
    AppCountryOption(code: 'DE', name: 'Germany', flag: '🇩🇪'),
    AppCountryOption(code: 'ES', name: 'Spain', flag: '🇪🇸'),
    AppCountryOption(code: 'IT', name: 'Italy', flag: '🇮🇹'),
    AppCountryOption(code: 'BR', name: 'Brazil', flag: '🇧🇷'),
    AppCountryOption(code: 'TR', name: 'Türkiye', flag: '🇹🇷'),
    AppCountryOption(code: 'ID', name: 'Indonesia', flag: '🇮🇩'),
    AppCountryOption(code: 'RU', name: 'Russia', flag: '🇷🇺'),
    AppCountryOption(code: 'CN', name: 'China', flag: '🇨🇳'),
    AppCountryOption(code: 'JP', name: 'Japan', flag: '🇯🇵'),
    AppCountryOption(code: 'KR', name: 'South Korea', flag: '🇰🇷'),
    AppCountryOption(
      code: AppConfig.globalCountryCode,
      name: 'Other country (Global)',
      flag: '🌍',
    ),
  ];

  static AppCountryOption byCode(String? code) => options.firstWhere(
    (country) => country.code == code,
    orElse: () => options.last,
  );
}
