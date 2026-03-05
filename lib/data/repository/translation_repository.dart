import 'package:hive_flutter/hive_flutter.dart';

class TranslationRepository {
  static const String _boxName = 'app_settings';
  static const String _sourceKey = 'translation_source_language';
  static const String _targetKey = 'translation_target_language';

  Box get _box => Hive.box(_boxName);

  String getSourceLanguageCode() =>
      _box.get(_sourceKey, defaultValue: 'en') as String;

  Future<void> setSourceLanguageCode(String code) => _box.put(_sourceKey, code);

  String getTargetLanguageCode() =>
      _box.get(_targetKey, defaultValue: 'es') as String;

  Future<void> setTargetLanguageCode(String code) => _box.put(_targetKey, code);
}
