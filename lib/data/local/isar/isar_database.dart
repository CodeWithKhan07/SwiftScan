import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import 'isar_records.dart';

class IsarDatabase {
  IsarDatabase._(this.instance);

  final Isar instance;

  static Future<IsarDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    await Directory(directory.path).create(recursive: true);
    final isar = await Isar.open(
      [DocumentRecordSchema, KeyValueRecordSchema],
      directory: directory.path,
      name: AppConstants.databaseName,
    );
    return IsarDatabase._(isar);
  }

  IsarCollection<DocumentRecord> get documents =>
      instance.collection<DocumentRecord>();
  IsarCollection<KeyValueRecord> get keyValues =>
      instance.collection<KeyValueRecord>();

  Future<void> close() async {
    await instance.close();
  }
}
