import '../models/scan_model.dart';

abstract class ILocalDataSource {
  Future<void> put(ScanModel scan);
  Future<void> delete(String id);
  Future<void> clearAll();

  ScanModel? get(String id);
  List<ScanModel> getAll();

  Future<void> togglePin(ScanModel scan);
  Future<void> pin(ScanModel scan);
  Future<void> unpin(ScanModel scan);

  List<ScanModel> getPinned();
  List<ScanModel> getUnpinned();

  Stream<dynamic> watch();
}
