import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import '../constants/app_constants.dart';

class FileStorageService {
  Future<String> saveScanImage({
    required String originalPath,
    Uint8List? croppedBytes,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final folderPath = Directory('${appDir.path}/${AppConstants.scanOutputFolder}');
    if (!await folderPath.exists()) {
      await folderPath.create(recursive: true);
    }

    final fileName = '${const Uuid().v4()}.jpg';
    final permanentPath = '${folderPath.path}/$fileName';

    if (croppedBytes != null) {
      await File(permanentPath).writeAsBytes(croppedBytes);
    } else {
      await File(originalPath).copy(permanentPath);
    }

    return permanentPath;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
