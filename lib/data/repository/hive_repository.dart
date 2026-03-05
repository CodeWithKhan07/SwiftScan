import 'package:hive_flutter/hive_flutter.dart';

import '../models/scan_model.dart';
import '../services/hive_service.dart';
import 'local_data_source.dart';

class HiveRepository implements ILocalDataSource {
  Box<ScanModel> get _box => Hive.box<ScanModel>(HiveService.scanBoxName);

  @override
  Future<void> put(ScanModel scan) async => _box.put(scan.id, scan);

  @override
  ScanModel? get(String id) => _box.get(id);

  @override
  List<ScanModel> getAll() => _box.values.toList();

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Future<void> clearAll() async => _box.clear();

  @override
  Stream<BoxEvent> watch() => _box.watch();

  @override
  Future<void> togglePin(ScanModel scan) async =>
      _box.put(scan.id, scan.copyWith(isPinned: !scan.isPinned));

  @override
  Future<void> pin(ScanModel scan) async =>
      _box.put(scan.id, scan.copyWith(isPinned: true));

  @override
  Future<void> unpin(ScanModel scan) async =>
      _box.put(scan.id, scan.copyWith(isPinned: false));

  @override
  List<ScanModel> getPinned() => _box.values.where((s) => s.isPinned).toList();

  @override
  List<ScanModel> getUnpinned() =>
      _box.values.where((s) => !s.isPinned).toList();
}
