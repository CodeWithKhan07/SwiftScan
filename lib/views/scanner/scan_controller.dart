import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:swiftscan/core/routes/app_routes.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../core/utils/app_utils.dart';

class ScannerController extends GetxController {
  VoidCallback? onCaptureStarted;

  PhotoCameraState? _cameraState;
  final RxBool isCapturing = false.obs;

  void updateCameraState(PhotoCameraState state) => _cameraState = state;

  Future<void> takePicture() async {
    if (isCapturing.value) return;

    if (_cameraState == null) {
      AppUtils.showError(msg: 'Camera is not ready yet');
      return;
    }

    isCapturing.value = true;

    try {
      onCaptureStarted?.call();
      HapticFeedback.mediumImpact();
      final capture = await _cameraState!.takePhoto();
      if (capture.path != null) {
        Get.toNamed(RouteNames.preview, arguments: capture.path);
      }
    } catch (e) {
      AppUtils.showError(msg: 'Capture failed: $e');
    } finally {
      isCapturing.value = false;
    }
  }

  Future<void> pickFromGallery(BuildContext context) async {
    try {
      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          // pageSize: 50,
          // gridCount: 4,
          maxAssets: 1,
          requestType: RequestType.image,
          themeColor: Color(0xFF6366F1),
        ),
      );

      if (assets == null || assets.isEmpty) return;
      final file = await assets.first.originFile;
      if (file == null) return;

      Get.toNamed(RouteNames.preview, arguments: file.path);
    } catch (e) {
      AppUtils.showError(msg: 'Gallery selection failed');
    }
  }
}
