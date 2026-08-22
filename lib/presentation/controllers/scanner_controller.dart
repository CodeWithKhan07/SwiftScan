import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/config/app_config.dart';
import '../../app/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';

enum ScanMode { invoice, document, batch }

class ScannerController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final mode = (AppConfig.isKsa ? ScanMode.invoice : ScanMode.document).obs;
  final isCapturing = false.obs;
  final flashOn = false.obs;
  final batchPaths = <String>[].obs;
  PhotoCameraState? _cameraState;

  @override
  void onInit() {
    super.onInit();
    final raw = (Get.arguments is Map ? (Get.arguments as Map)['mode'] : null)
        ?.toString();
    mode.value = ScanMode.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AppConfig.isKsa ? ScanMode.invoice : ScanMode.document,
    );
  }

  void close() => Get.back();

  void attachCamera(PhotoCameraState state) => _cameraState = state;
  void setMode(ScanMode value) {
    if (!isCapturing.value) mode.value = value;
  }

  Future<void> toggleFlash() async {
    if (isCapturing.value) return;
    final state = _cameraState;
    if (state == null) {
      AppSnackbar.info('Camera is preparing / الكاميرا قيد التجهيز');
      return;
    }

    final nextValue = !flashOn.value;
    try {
      await state.sensorConfig.setFlashMode(
        nextValue ? FlashMode.always : FlashMode.none,
      );
      flashOn.value = nextValue;
    } catch (error) {
      flashOn.value = false;
      AppSnackbar.error('Flash is unavailable / الفلاش غير متاح: $error');
    }
  }

  Future<void> capture() async {
    if (isCapturing.value) return;
    // Reject an extra batch capture before creating an unused image file.
    if (mode.value == ScanMode.batch && batchPaths.length >= 30) {
      AppSnackbar.info('Maximum 30 pages / الحد الأقصى 30 صفحة');
      return;
    }
    final state = _cameraState;
    if (state == null) {
      AppSnackbar.info('Camera is preparing / الكاميرا قيد التجهيز');
      return;
    }
    isCapturing.value = true;
    try {
      HapticFeedback.mediumImpact();
      final capture = await state.takePhoto();
      final path = capture.path;
      if (path == null || path.isEmpty) return;
      if (mode.value == ScanMode.batch) {
        batchPaths.add(path);
        AppSnackbar.success(
          '${batchPaths.length} page(s) captured / تم التقاط ${batchPaths.length} صفحة',
        );
      } else {
        _openEditor([path], mode.value.name);
      }
    } catch (error) {
      AppSnackbar.error('Capture failed / تعذر الالتقاط: $error');
    } finally {
      isCapturing.value = false;
    }
  }

  Future<void> autoScan() async {
    if (isCapturing.value) return;
    isCapturing.value = true;
    DocumentScanner? scanner;
    try {
      // Create and dispose the native scanner inside the guarded lifecycle.
      scanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormats: const {DocumentFormat.jpeg},
          pageLimit: mode.value == ScanMode.batch ? 30 : 10,
          mode: ScannerMode.full,
          isGalleryImport: true,
        ),
      );
      final result = await scanner.scanDocument();
      final images = result.images ?? const <String>[];
      if (images.isNotEmpty) {
        _openEditor(
          images,
          mode.value == ScanMode.invoice ? 'invoice' : 'document',
        );
      }
    } catch (error) {
      AppSnackbar.error(
        'Auto scan unavailable / المسح التلقائي غير متاح: $error',
      );
    } finally {
      try {
        await scanner?.close();
      } finally {
        // Never leave the controls disabled when native cleanup fails.
        isCapturing.value = false;
      }
    }
  }

  Future<void> pickFromGallery() async {
    if (isCapturing.value) return;
    isCapturing.value = true;
    try {
      final images = await _picker.pickMultiImage(imageQuality: 100, limit: 30);
      if (images.isEmpty) return;
      _openEditor(
        images.map((e) => e.path).toList(),
        mode.value == ScanMode.invoice ? 'invoice' : 'document',
      );
    } catch (_) {
      AppSnackbar.error('Could not open gallery / تعذر فتح المعرض');
    } finally {
      isCapturing.value = false;
    }
  }

  void finishBatch() {
    if (batchPaths.isEmpty || isCapturing.value) return;
    _openEditor(batchPaths.toList(), 'document');
    batchPaths.clear();
  }

  void _openEditor(List<String> paths, String kind) {
    Get.toNamed(AppRoutes.editor, arguments: {'paths': paths, 'kind': kind});
  }
}
