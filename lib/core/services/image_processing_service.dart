import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List;
import '../constants/app_constants.dart';

class ImageProcessingService {
  Future<Uint8List> compressForCrop(String path) async {
    final result = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: AppConstants.minImageWidth,
      minHeight: AppConstants.minImageHeight,
      quality: AppConstants.imageQuality,
      keepExif: false,
    );
    if (result == null) {
      return File(path).readAsBytes();
    }
    return result;
  }
}
