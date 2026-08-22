import 'dart:convert';

import '../local/isar/isar_collection_extensions.dart';
import '../local/isar/isar_database.dart';
import '../local/isar/isar_records.dart';

class LocalKeyValueDataSource {
  const LocalKeyValueDataSource(this._database);

  final IsarDatabase _database;

  Future<T?> read<T>(String key) async {
    final record = await _database.keyValues.findFirstByProperty('key', key);
    if (record == null) return null;
    final value = jsonDecode(record.value);
    return value is T ? value : null;
  }

  Future<void> write(String key, Object? value) async {
    final record = KeyValueRecord()
      ..key = key
      ..value = jsonEncode(value);

    await _database.keyValues.upsertByProperty(
      property: 'key',
      value: key,
      object: record,
      readId: (value) => value.id,
      writeId: (value, id) => value.id = id,
    );
  }

  Future<void> remove(String key) async {
    await _database.keyValues.deleteFirstByProperty(
      'key',
      key,
      readId: (value) => value.id,
    );
  }
}
