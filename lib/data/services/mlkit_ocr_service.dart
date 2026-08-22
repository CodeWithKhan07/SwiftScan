import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MlKitOcrService {
  Future<String> extractLatinText(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      final blocks = [...result.blocks]
        ..sort((a, b) {
          final dy = a.boundingBox.top.compareTo(b.boundingBox.top);
          if (dy != 0) return dy;
          return a.boundingBox.left.compareTo(b.boundingBox.left);
        });
      return blocks
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .join('\n\n');
    } finally {
      await recognizer.close();
    }
  }
}
