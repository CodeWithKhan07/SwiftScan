import '../models/scan_model.dart';
import 'local_data_source.dart';

class ScanRepository {
  final ILocalDataSource _dataSource;

  ScanRepository(this._dataSource);

  Future<void> save(ScanModel scan) async => _dataSource.put(scan);

  Future<void> delete(String id) async => _dataSource.delete(id);

  Future<void> clearAll() async => _dataSource.clearAll();

  ScanModel? getById(String id) => _dataSource.get(id);

  List<ScanModel> getAllSorted() {
    final scans = _dataSource.getAll()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return scans;
  }

  List<ScanModel> search(String query) {
    if (query.isEmpty) return getAllSorted();

    final q = query.toLowerCase();
    return _dataSource
        .getAll()
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.rawText.toLowerCase().contains(q),
        )
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> togglePin(ScanModel scan) => _dataSource.togglePin(scan);

  Future<void> pin(ScanModel scan) => _dataSource.pin(scan);

  Future<void> unpin(ScanModel scan) => _dataSource.unpin(scan);

  List<ScanModel> getPinned() =>
      _dataSource.getPinned()..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<ScanModel> getUnpinned() =>
      _dataSource.getUnpinned()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  Stream watchChanges() => _dataSource.watch();
}
