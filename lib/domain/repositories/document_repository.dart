import '../entities/app_document.dart';

abstract interface class DocumentRepository {
  Future<List<AppDocument>> getAll();
  Future<AppDocument?> getById(String id);
  Stream<List<AppDocument>> watchAll();
  Future<void> save(AppDocument document);
  Future<void> delete(String id);
  Future<void> clear();
  Future<void> sync(AppDocument document);
  Future<void> syncAll();
  Future<List<AppDocument>> restoreFromCloud();
}
