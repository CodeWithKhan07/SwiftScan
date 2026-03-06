import 'package:get/get.dart';
import 'package:swiftscan/data/repository/hive_repository.dart';
import 'package:swiftscan/data/repository/ocr_language_repository.dart';
import 'package:swiftscan/data/repository/scan_repository.dart';
import 'package:swiftscan/data/repository/translation_repository.dart';
import 'package:swiftscan/data/services/ocr_service.dart';
import 'package:swiftscan/views/history/history_controller.dart';
import 'package:swiftscan/views/main/main_controller.dart';
import 'package:swiftscan/views/preview/preview_controller.dart';
import 'package:swiftscan/views/scanner/scan_controller.dart';
import 'package:swiftscan/views/splash/splash_controller.dart';

import '../../views/scandetails/scandetail_controller.dart';
import '../../views/settings/settings_controller.dart';
import '../../views/translation/translation_controller.dart';
import '../services/app_lock_service.dart';
import '../services/file_storage_service.dart';
import '../services/image_processing_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final hiveRepo = Get.put(HiveRepository(), permanent: true);
    Get.put(ScanRepository(hiveRepo), permanent: true);
    Get.lazyPut(() => OcrLanguageRepository(), fenix: true);
    Get.lazyPut(() => TranslationRepository(), fenix: true);
    Get.lazyPut(() => OcrService(), fenix: true);

    if (!Get.isRegistered<AppLockService>()) {
      Get.put(AppLockService(), permanent: true);
    }
    Get.put(
      SettingsController(
        Get.find<OcrLanguageRepository>(),
        Get.find<AppLockService>(),
        Get.find<TranslationRepository>(),
        Get.find<ScanRepository>(),
      ),
      permanent: true,
    );
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    // Only View Controllers go here
    Get.lazyPut(() => MainController());
    Get.lazyPut(() => ScannerController());
    Get.lazyPut(() => HistoryController(Get.find<ScanRepository>()));
  }
}

class PreviewBindings extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => PreviewController(
      Get.find<OcrService>(),
      Get.find<ScanRepository>(),
      FileStorageService(),
      ImageProcessingService(),
    ),
  );
}

class ScanDetailBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => ScanDetailController(Get.find<ScanRepository>()));
}

class TranslationBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => TranslationController());
}
