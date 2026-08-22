import 'dart:convert';

import '../../domain/entities/zatca_qr_data.dart';

class ZatcaQrParser {
  const ZatcaQrParser();

  ZatcaQrData parse(String raw) {
    try {
      final bytes = base64Decode(raw.trim());
      final fields = <int, String>{};
      var index = 0;
      while (index + 2 <= bytes.length) {
        final tag = bytes[index++];
        final length = bytes[index++];
        if (index + length > bytes.length) break;
        final valueBytes = bytes.sublist(index, index + length);
        index += length;
        fields[tag] = _decode(valueBytes);
      }
      return ZatcaQrData(
        sellerName: fields[1] ?? '',
        vatNumber: fields[2] ?? '',
        timestamp: fields[3] ?? '',
        totalWithVat: fields[4] ?? '',
        vatTotal: fields[5] ?? '',
        invoiceHash: fields[6] ?? '',
        signature: fields[7] ?? '',
        publicKey: fields[8] ?? '',
        caSignature: fields[9] ?? '',
        raw: raw,
        isValidTlv: fields.keys.any((e) => e >= 1 && e <= 5),
      );
    } catch (_) {
      return ZatcaQrData(raw: raw, isValidTlv: false);
    }
  }

  String _decode(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return base64Encode(bytes);
    }
  }
}
