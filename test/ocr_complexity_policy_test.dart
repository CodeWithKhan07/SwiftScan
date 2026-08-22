import 'package:fatoralens/data/services/ocr_complexity_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = OcrComplexityPolicy();

  test('keeps clear prose on the local OCR path', () {
    // Long, clean prose does not spend a cloud AI credit unnecessarily.
    expect(
      policy.requiresCloud(
        'This is a clearly recognized paragraph with ordinary words and punctuation.',
      ),
      isFalse,
    );
  });

  test('escalates empty, bilingual, noisy, and invoice-like OCR', () {
    // These inputs represent the complex OCR cases that need cloud vision.
    expect(policy.requiresCloud(''), isTrue);
    expect(
      policy.requiresCloud('Invoice فاتورة number 1234567890 and total'),
      isTrue,
    );
    expect(
      policy.requiresCloud(r'INV@@@ ### 12.00 ??? OCR result text here'),
      isTrue,
    );
    expect(policy.requiresCloud('Item 2\nRate 15\nTax 30\nTotal 230'), isTrue);
  });

  test('honors explicit high-accuracy routing', () {
    // Invoice mode can force cloud vision even when local text looks clean.
    expect(
      policy.requiresCloud(
        'A clean and otherwise simple recognized paragraph from the page.',
        preferHighAccuracy: true,
      ),
      isTrue,
    );
  });
}
