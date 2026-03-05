import 'package:hive/hive.dart';

part 'ocr_language_model.g.dart';

@HiveType(typeId: 1)
class OcrLanguageModel extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String label;

  @HiveField(2)
  final String scriptName;

  @HiveField(3)
  final bool isEnabled;

  OcrLanguageModel({
    required this.code,
    required this.label,
    required this.scriptName,
    this.isEnabled = false,
  });

  OcrLanguageModel copyWith({
    String? code,
    String? label,
    String? scriptName,
    bool? isEnabled,
  }) {
    return OcrLanguageModel(
      code: code ?? this.code,
      label: label ?? this.label,
      scriptName: scriptName ?? this.scriptName,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
