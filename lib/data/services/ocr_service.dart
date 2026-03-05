import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractText(String imagePath) async {
    try {
      await compute(_processImageTask, imagePath);

      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (recognizedText.blocks.isEmpty) return "";
      final blocks = recognizedText.blocks
        ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

      final buffer = StringBuffer();
      for (final block in blocks) {
        final blockText = block.text.trim();
        if (blockText.isNotEmpty) {
          buffer.writeln(blockText);
          buffer.writeln();
        }
      }

      return buffer.toString().trim();
    } catch (e) {
      debugPrint('OCR Service Error: $e');
      return "";
    }
  }

  void dispose() => _textRecognizer.close();
}

Future<void> _processImageTask(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return;
  image = img.bakeOrientation(image);
  await file.writeAsBytes(img.encodeJpg(image, quality: 85));
}
