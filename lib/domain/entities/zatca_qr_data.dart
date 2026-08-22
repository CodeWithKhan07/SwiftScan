class ZatcaQrData {
  const ZatcaQrData({
    this.sellerName = '',
    this.vatNumber = '',
    this.timestamp = '',
    this.totalWithVat = '',
    this.vatTotal = '',
    this.invoiceHash = '',
    this.signature = '',
    this.publicKey = '',
    this.caSignature = '',
    this.raw = '',
    this.isValidTlv = false,
  });

  final String sellerName;
  final String vatNumber;
  final String timestamp;
  final String totalWithVat;
  final String vatTotal;
  final String invoiceHash;
  final String signature;
  final String publicKey;
  final String caSignature;
  final String raw;
  final bool isValidTlv;
}
