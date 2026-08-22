import '../entities/app_document.dart';
import '../repositories/document_repository.dart';

class DocumentUseCases {
  const DocumentUseCases(this._repository);

  final DocumentRepository _repository;

  Future<List<AppDocument>> getAll() => _repository.getAll();
  Future<AppDocument?> getById(String id) => _repository.getById(id);
  Stream<List<AppDocument>> watchAll() => _repository.watchAll();
  Future<void> save(AppDocument document) => _repository.save(document);
  Future<void> delete(String id) => _repository.delete(id);
  Future<void> clear() => _repository.clear();
  Future<void> sync(AppDocument document) => _repository.sync(document);
  Future<void> syncAll() => _repository.syncAll();
  Future<List<AppDocument>> restoreFromCloud() =>
      _repository.restoreFromCloud();
}
