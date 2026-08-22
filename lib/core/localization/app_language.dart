import 'package:flutter/widgets.dart';

enum AppLanguage {
  bilingual,
  english,
  arabic,
  french,
  urdu,
  spanish,
  german,
  italian,
  portuguese,
  turkish,
  hindi,
  indonesian,
  russian,
  chinese,
  japanese,
  korean,
}

extension AppLanguageX on AppLanguage {
  Locale get locale => switch (this) {
    AppLanguage.arabic || AppLanguage.bilingual => const Locale('ar', 'SA'),
    AppLanguage.english => const Locale('en', 'US'),
    AppLanguage.french => const Locale('fr', 'FR'),
    AppLanguage.urdu => const Locale('ur', 'PK'),
    AppLanguage.spanish => const Locale('es', 'ES'),
    AppLanguage.german => const Locale('de', 'DE'),
    AppLanguage.italian => const Locale('it', 'IT'),
    AppLanguage.portuguese => const Locale('pt', 'BR'),
    AppLanguage.turkish => const Locale('tr', 'TR'),
    AppLanguage.hindi => const Locale('hi', 'IN'),
    AppLanguage.indonesian => const Locale('id', 'ID'),
    AppLanguage.russian => const Locale('ru', 'RU'),
    AppLanguage.chinese => const Locale('zh', 'CN'),
    AppLanguage.japanese => const Locale('ja', 'JP'),
    AppLanguage.korean => const Locale('ko', 'KR'),
  };

  String get preferenceValue => name;

  bool get isRtl => switch (this) {
    AppLanguage.arabic || AppLanguage.bilingual || AppLanguage.urdu => true,
    _ => false,
  };

  String get nativeLabel => switch (this) {
    AppLanguage.bilingual => 'العربية + English',
    AppLanguage.english => 'English',
    AppLanguage.arabic => 'العربية',
    AppLanguage.french => 'Français',
    AppLanguage.urdu => 'اردو',
    AppLanguage.spanish => 'Español',
    AppLanguage.german => 'Deutsch',
    AppLanguage.italian => 'Italiano',
    AppLanguage.portuguese => 'Português',
    AppLanguage.turkish => 'Türkçe',
    AppLanguage.hindi => 'हिन्दी',
    AppLanguage.indonesian => 'Bahasa Indonesia',
    AppLanguage.russian => 'Русский',
    AppLanguage.chinese => '简体中文',
    AppLanguage.japanese => '日本語',
    AppLanguage.korean => '한국어',
  };
}
