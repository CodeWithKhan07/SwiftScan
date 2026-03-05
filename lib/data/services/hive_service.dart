import 'package:hive_flutter/hive_flutter.dart';

import '../../core/services/app_lock_service.dart';
import '../models/ocr_language_model.dart';
import '../models/scan_model.dart';
import '../repository/ocr_language_repository.dart';

class HiveService {
  static const String scanBoxName = 'scans';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScanModelAdapter());
    Hive.registerAdapter(OcrLanguageModelAdapter());
    await Hive.openBox<ScanModel>(scanBoxName);
    await Hive.openBox<OcrLanguageModel>(OcrLanguageRepository.boxName);
    await Hive.openBox(AppLockService.boxName);
  }
}
