import '../../domain/entities/app_document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/firebase_document_data_source.dart';
import '../datasources/local_document_data_source.dart';
import '../services/file_service.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._local, this._cloud, this._files);
  final LocalDocumentDataSource _local;
  final FirebaseDocumentDataSource _cloud;
  final FileService _files;

  @override
  Future<List<AppDocument>> getAll() => _local.getAll();
  @override
  Future<AppDocument?> getById(String id) => _local.getById(id);
  @override
  Stream<List<AppDocument>> watchAll() => _local.watchAll();

  @override
  Future<void> save(AppDocument document) => _local.save(document);

  @override
  Future<void> delete(String id) async {
    final document = await _local.getById(id);
    if (document != null) {
      for (final page in document.pages) {
        await _files.deleteIfExists(page.originalPath);
        if (page.processedPath != page.originalPath) {
          await _files.deleteIfExists(page.processedPath);
        }
      }
      await _files.deleteIfExists(document.exportedPdfPath);
    }
    await _local.delete(id);
    try {
      await _cloud.delete(id);
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    final documents = await _local.getAll();
    for (final doc in documents) {
      for (final page in doc.pages) {
        await _files.deleteIfExists(page.originalPath);
        if (page.processedPath != page.originalPath) {
          await _files.deleteIfExists(page.processedPath);
        }
      }
      await _files.deleteIfExists(doc.exportedPdfPath);
    }
    await _local.clear();
  }

  @override
  Future<void> sync(AppDocument document) async {
    final syncing = document.copyWith(
      cloudState: CloudState.syncing,
      updatedAt: DateTime.now(),
    );
    await _local.save(syncing);
    try {
      final synced = await _cloud.upload(syncing);
      await _local.save(synced);
    } catch (_) {
      await _local.save(syncing.copyWith(cloudState: CloudState.failed));
      rethrow;
    }
  }

  @override
  Future<void> syncAll() async {
    for (final document in await _local.getAll()) {
      await sync(document);
    }
  }

  @override
  Future<List<AppDocument>> restoreFromCloud() async {
    final remote = await _cloud.fetchAll();
    for (final document in remote) {
      if ((await _local.getById(document.id)) == null) {
        await _local.save(document.copyWith(cloudState: CloudState.synced));
      }
    }
    return _local.getAll();
  }
}
