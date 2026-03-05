import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/utils/app_utils.dart';
import '../../data/models/scan_model.dart';
import '../../data/repository/scan_repository.dart';

class HistoryController extends GetxController {
  final ScanRepository _repository;

  HistoryController(this._repository);

  final RxString searchQuery = ''.obs;
  final RxMap<String, List<ScanModel>> groupedScans =
      <String, List<ScanModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAndGroupScans();
    _repository.watchChanges().listen((_) => _loadAndGroupScans());
    debounce(searchQuery, (_) => _loadAndGroupScans(), time: 300.milliseconds);
  }

  void _loadAndGroupScans() {
    final allScans = _repository.getAllSorted();
    final query = searchQuery.value.toLowerCase();
    final filteredScans = allScans.where((s) {
      if (query.isEmpty) return true;
      return s.title.toLowerCase().contains(query) ||
          s.rawText.toLowerCase().contains(query);
    }).toList();

    final pinned = filteredScans.where((s) => s.isPinned).toList();
    final unpinned = filteredScans.where((s) => !s.isPinned).toList();

    final Map<String, List<ScanModel>> groups = {};

    if (pinned.isNotEmpty) {
      groups['PINNED'] = pinned;
    }

    for (final scan in unpinned) {
      final label = _getDateLabel(scan.dateTime);
      if (groups.containsKey(label)) {
        groups[label]!.add(scan);
      } else {
        groups[label] = [scan];
      }
    }

    groupedScans.assignAll(groups);
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final scanDate = DateTime(date.year, date.month, date.day);
    if (scanDate == today) return 'TODAY';
    if (scanDate == yesterday) return 'YESTERDAY';
    if (scanDate.year == now.year) {
      return DateFormat('MMMM d').format(date).toUpperCase();
    }
    return DateFormat('MMM d, yyyy').format(date).toUpperCase();
  }

  Future<void> togglePin(ScanModel scan) async {
    try {
      await _repository.togglePin(scan);

      final isNowPinned = !scan.isPinned;
      AppUtils.showMsg(
        title: isNowPinned ? "Pinned" : "Unpinned",
        msg:
            "${scan.title} ${isNowPinned ? "pinned to top" : "removed from pinned"}",
      );
    } catch (e) {
      AppUtils.showError(msg: "Failed to update pin: $e");
    }
  }

  Future<void> deleteScan(String id) async {
    try {
      await _repository.delete(id);
      _loadAndGroupScans();
      AppUtils.showSuccess(msg: "Scan deleted successfully");
    } catch (e) {
      AppUtils.showError(msg: "Failed to delete the scan");
      _loadAndGroupScans();
    }
  }
}
