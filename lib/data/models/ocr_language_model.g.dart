// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_language_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OcrLanguageModelAdapter extends TypeAdapter<OcrLanguageModel> {
  @override
  final int typeId = 1;

  @override
  OcrLanguageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OcrLanguageModel(
      code: fields[0] as String,
      label: fields[1] as String,
      scriptName: fields[2] as String,
      isEnabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OcrLanguageModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.scriptName)
      ..writeByte(3)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrLanguageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
