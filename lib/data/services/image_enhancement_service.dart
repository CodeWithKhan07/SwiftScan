import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'file_service.dart';

enum EnhancementPreset {
  auto,
  clearText,
  removeShadows,
  blackAndWhite,
  document,
  invoice,
}

class ImageEnhancementService {
  const ImageEnhancementService(this._files);
  final FileService _files;

  Future<String> enhance(String inputPath, EnhancementPreset preset) async {
    final bytes = await File(inputPath).readAsBytes();
    final output = await compute(_enhanceTask, (bytes, preset.name));
    final path = await _files.createExportPath('enhanced', 'jpg');
    await File(path).writeAsBytes(output, flush: true);
    return path;
  }

  Future<String> rotateQuarterTurn(String inputPath) async {
    final bytes = await File(inputPath).readAsBytes();
    final output = await compute(_rotateTask, bytes);
    final path = await _files.createExportPath('rotated', 'jpg');
    await File(path).writeAsBytes(output, flush: true);
    return path;
  }
}

Uint8List _enhanceTask((Uint8List, String) payload) {
  final decoded = img.decodeImage(payload.$1);
  if (decoded == null) return payload.$1;
  var image = img.bakeOrientation(decoded);
  switch (payload.$2) {
    case 'clearText':
      image = img.adjustColor(
        image,
        contrast: 1.35,
        brightness: 1.06,
        saturation: 0.75,
      );
      image = img.convolution(
        image,
        filter: const [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );
      break;
    case 'removeShadows':
      image = img.adjustColor(
        image,
        contrast: 1.15,
        brightness: 1.12,
        saturation: 0.85,
      );
      break;
    case 'blackAndWhite':
      image = img.grayscale(image);
      image = img.adjustColor(image, contrast: 1.45, brightness: 1.08);
      break;
    case 'invoice':
      image = img.adjustColor(
        image,
        contrast: 1.25,
        brightness: 1.08,
        saturation: 0.6,
      );
      break;
    case 'document':
      image = img.adjustColor(
        image,
        contrast: 1.2,
        brightness: 1.05,
        saturation: 0.8,
      );
      break;
    default:
      image = img.adjustColor(
        image,
        contrast: 1.18,
        brightness: 1.05,
        saturation: 0.9,
      );
      break;
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 92));
}

Uint8List _rotateTask(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final rotated = img.copyRotate(img.bakeOrientation(decoded), angle: 90);
  return Uint8List.fromList(img.encodeJpg(rotated, quality: 94));
}
