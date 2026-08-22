class InvoiceLineItem {
  const InvoiceLineItem({
    this.description = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.vat = 0,
    this.total = 0,
  });

  final String description;
  final double quantity;
  final double unitPrice;
  final double vat;
  final double total;

  InvoiceLineItem copyWith({
    String? description,
    double? quantity,
    double? unitPrice,
    double? vat,
    double? total,
  }) {
    return InvoiceLineItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      vat: vat ?? this.vat,
      total: total ?? this.total,
    );
  }
}

class InvoiceData {
  const InvoiceData({
    this.sellerName = '',
    this.sellerNameAr = '',
    this.vatNumber = '',
    this.commercialRegistration = '',
    this.invoiceNumber = '',
    this.invoiceType = '',
    this.issueDate = '',
    this.issueTime = '',
    this.buyerName = '',
    this.buyerVatNumber = '',
    this.subtotal = 0,
    this.discount = 0,
    this.taxableAmount = 0,
    this.vatRate = 15,
    this.vatAmount = 0,
    this.total = 0,
    this.currency = 'SAR',
    this.paymentMethod = '',
    this.qrRaw = '',
    this.lineItems = const [],
    this.needsReview = false,
  });

  final String sellerName;
  final String sellerNameAr;
  final String vatNumber;
  final String commercialRegistration;
  final String invoiceNumber;
  final String invoiceType;
  final String issueDate;
  final String issueTime;
  final String buyerName;
  final String buyerVatNumber;
  final double subtotal;
  final double discount;
  final double taxableAmount;
  final double vatRate;
  final double vatAmount;
  final double total;
  final String currency;
  final String paymentMethod;
  final String qrRaw;
  final List<InvoiceLineItem> lineItems;
  final bool needsReview;

  InvoiceData copyWith({
    String? sellerName,
    String? sellerNameAr,
    String? vatNumber,
    String? commercialRegistration,
    String? invoiceNumber,
    String? invoiceType,
    String? issueDate,
    String? issueTime,
    String? buyerName,
    String? buyerVatNumber,
    double? subtotal,
    double? discount,
    double? taxableAmount,
    double? vatRate,
    double? vatAmount,
    double? total,
    String? currency,
    String? paymentMethod,
    String? qrRaw,
    List<InvoiceLineItem>? lineItems,
    bool? needsReview,
  }) {
    return InvoiceData(
      sellerName: sellerName ?? this.sellerName,
      sellerNameAr: sellerNameAr ?? this.sellerNameAr,
      vatNumber: vatNumber ?? this.vatNumber,
      commercialRegistration:
          commercialRegistration ?? this.commercialRegistration,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceType: invoiceType ?? this.invoiceType,
      issueDate: issueDate ?? this.issueDate,
      issueTime: issueTime ?? this.issueTime,
      buyerName: buyerName ?? this.buyerName,
      buyerVatNumber: buyerVatNumber ?? this.buyerVatNumber,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      qrRaw: qrRaw ?? this.qrRaw,
      lineItems: lineItems ?? this.lineItems,
      needsReview: needsReview ?? this.needsReview,
    );
  }
}
