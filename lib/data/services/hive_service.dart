import 'package:hive_flutter/hive_flutter.dart';
import 'package:swiftscan/core/constants/app_constants.dart';

import '../../core/services/app_lock_service.dart';
import '../models/ocr_language_model.dart';
import '../models/scan_model.dart';

class HiveService {
  static const String scanBoxName = 'scans';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScanModelAdapter());
    Hive.registerAdapter(OcrLanguageModelAdapter());
    await Hive.openBox<ScanModel>(scanBoxName);
    await Hive.openBox<OcrLanguageModel>(AppConstants.ocrLanguagesBox);
    await Hive.openBox(AppLockService.boxName);
  }
}
