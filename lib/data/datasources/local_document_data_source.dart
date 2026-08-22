import 'dart:convert';

import '../../domain/entities/app_document.dart';
import '../local/isar/isar_collection_extensions.dart';
import '../local/isar/isar_database.dart';
import '../local/isar/isar_records.dart';
import '../mappers/document_mapper.dart';

class LocalDocumentDataSource {
  const LocalDocumentDataSource(this._database, this._mapper);

  final IsarDatabase _database;
  final DocumentMapper _mapper;

  Future<List<AppDocument>> getAll() async {
    final records = await _database.documents.findAllRecords();
    final documents = records.map(_toDomain).toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return documents;
  }

  Future<AppDocument?> getById(String id) async {
    final record = await _database.documents.findFirstByProperty(
      'documentId',
      id,
    );
    return record == null ? null : _toDomain(record);
  }

  Future<void> save(AppDocument document) async {
    final record = DocumentRecord()
      ..documentId = document.id
      ..updatedAt = document.updatedAt
      ..payload = jsonEncode(_mapper.toMap(document));

    await _database.documents.upsertByProperty(
      property: 'documentId',
      value: document.id,
      object: record,
      readId: (value) => value.id,
      writeId: (value, id) => value.id = id,
    );
  }

  Future<void> delete(String id) async {
    await _database.documents.deleteFirstByProperty(
      'documentId',
      id,
      readId: (value) => value.id,
    );
  }

  Future<void> clear() async {
    await _database.instance.writeTxn(_database.documents.clear);
  }

  Stream<List<AppDocument>> watchAll() {
    return _database.documents
        .watchLazy(fireImmediately: true)
        .asyncMap((_) => getAll());
  }

  AppDocument _toDomain(DocumentRecord record) {
    final decoded = jsonDecode(record.payload);
    if (decoded is! Map) {
      throw const FormatException('Invalid local document payload.');
    }
    return _mapper.fromMap(Map<String, dynamic>.from(decoded));
  }
}
