import 'package:flutter/foundation.dart' show Uint8List;
import 'package:get/get.dart';
import 'package:swiftscan/core/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums/request_state.dart';
import '../../core/services/file_storage_service.dart';
import '../../core/services/image_processing_service.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/scan_model.dart';
import '../../data/repository/scan_repository.dart';
import '../../data/services/ocr_service.dart';

class PreviewController extends GetxController {
  final OcrService _ocrService;
  final ScanRepository _scanRepo;
  final FileStorageService _storageService;
  final ImageProcessingService _imageProcessingService;

  PreviewController(
    this._ocrService,
    this._scanRepo,
    this._storageService,
    this._imageProcessingService,
  );

  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);

  final Rx<Uint8List?> croppedBytes = Rx<Uint8List?>(null);
  String originalPath = '';

  final Rx<RequestState> processState = RequestState.initial.obs;
  final RxBool isCropping = false.obs;
  final RxBool isCropReady = false.obs;
  final RxBool canUndo = false.obs;
  final RxBool canRedo = false.obs;
  final RxBool isCancelled = false.obs;

  @override
  void onInit() {
    super.onInit();
    originalPath = Get.arguments as String;
    _loadImage();
  }

  Future<void> _loadImage() async {
    imageBytes.value = await _imageProcessingService.compressForCrop(
      originalPath,
    );
  }

  void onCropped(Uint8List result) {
    croppedBytes.value = result;
    isCropping.value = false;
  }

  void onCropError(Object error) {
    AppUtils.showError(msg: 'Crop failed: $error');
    isCropping.value = false;
  }

  void onCropStatusChanged(dynamic status) {
    isCropReady.value = true;
  }

  void onHistoryChanged(dynamic history) {
    canUndo.value = (history.undoCount ?? 0) > 0;
    canRedo.value = (history.redoCount ?? 0) > 0;
  }

  void enterCropMode() {
    isCropReady.value = false;
    isCropping.value = true;
  }

  void cancelCrop() => isCropping.value = false;

  void retake() => Get.back();

  void cancelProcessing() {
    isCancelled.value = true;
    processState.value = RequestState.initial;
  }

  Future<void> finalizeAndProcess() async {
    if (processState.value == RequestState.loading) return;

    try {
      processState.value = RequestState.loading;
      isCancelled.value = false;
      final permanentPath = await _storageService.saveScanImage(
        originalPath: originalPath,
        croppedBytes: croppedBytes.value,
      );

      if (isCancelled.value) {
        await _storageService.deleteFile(permanentPath);
        processState.value = RequestState.initial;
        return;
      }
      final text = await _ocrService.extractText(permanentPath);
      if (isCancelled.value) {
        await _storageService.deleteFile(permanentPath);
        processState.value = RequestState.initial;
        return;
      }

      if (text.trim().isEmpty) {
        processState.value = RequestState.error;
        await _storageService.deleteFile(permanentPath);
        AppUtils.showError(
          msg: 'No text detected. Please try again with a clearer image.',
        );
        return;
      }

      final scan = ScanModel(
        id: const Uuid().v4(),
        title:
            'Scan ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        rawText: text,
        imagePath: permanentPath,
        dateTime: DateTime.now(),
      );

      await _scanRepo.save(scan);
      processState.value = RequestState.success;
      Get.offNamed(
        RouteNames.scanDetail,
        arguments: {'scan': scan, 'isNewScan': true},
      );
      AppUtils.showSuccess(msg: "Image Scanned Successfully");
    } catch (e) {
      processState.value = RequestState.error;
      AppUtils.showError(msg: 'OCR failed: $e');
    }
  }
}
