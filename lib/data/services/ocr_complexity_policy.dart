/// Classifies OCR that benefits from the higher-accuracy cloud vision path.
class OcrComplexityPolicy {
  const OcrComplexityPolicy();

  bool requiresCloud(String localText, {bool preferHighAccuracy = false}) {
    if (preferHighAccuracy) return true;

    final text = localText.trim();
    if (text.isEmpty || text.length < 40) return true;
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return true;

    final visibleCharacters = text.replaceAll(RegExp(r'\s'), '');
    if (visibleCharacters.isEmpty) return true;

    // A high symbol ratio commonly indicates noisy, low-confidence local OCR.
    final suspiciousCharacters = RegExp(
      r'[^A-Za-z0-9\u0600-\u06FF.,:/%+()\-]',
    ).allMatches(visibleCharacters).length;
    if (suspiciousCharacters / visibleCharacters.length > 0.08) return true;

    // Dense numeric multi-line layouts are usually invoices, forms, or tables.
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (lines.length >= 4) {
      final numericLines = lines
          .where((line) => RegExp(r'\d').hasMatch(line))
          .length;
      if (numericLines * 2 >= lines.length) return true;
    }

    return false;
  }
}
