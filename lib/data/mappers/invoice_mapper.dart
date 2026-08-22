import '../../domain/entities/invoice_data.dart';
import 'map_value.dart';

abstract final class InvoiceMapper {
  static InvoiceData fromMap(Map<String, dynamic> map) {
    return InvoiceData(
      sellerName: MapValue.string(map['sellerName']),
      sellerNameAr: MapValue.string(map['sellerNameAr']),
      vatNumber: MapValue.string(map['vatNumber']),
      commercialRegistration: MapValue.string(map['commercialRegistration']),
      invoiceNumber: MapValue.string(map['invoiceNumber']),
      invoiceType: MapValue.string(map['invoiceType']),
      issueDate: MapValue.string(map['issueDate']),
      issueTime: MapValue.string(map['issueTime']),
      buyerName: MapValue.string(map['buyerName']),
      buyerVatNumber: MapValue.string(map['buyerVatNumber']),
      subtotal: MapValue.number(map['subtotal']),
      discount: MapValue.number(map['discount']),
      taxableAmount: MapValue.number(map['taxableAmount']),
      vatRate: MapValue.number(map['vatRate'], fallback: 15),
      vatAmount: MapValue.number(map['vatAmount']),
      total: MapValue.number(map['total']),
      currency: MapValue.string(map['currency'], fallback: 'SAR'),
      paymentMethod: MapValue.string(map['paymentMethod']),
      qrRaw: MapValue.string(map['qrRaw']),
      lineItems: _lineItems(map['lineItems']),
      needsReview: map['needsReview'] == true,
    );
  }

  static Map<String, dynamic> toMap(InvoiceData invoice) {
    return {
      'sellerName': invoice.sellerName,
      'sellerNameAr': invoice.sellerNameAr,
      'vatNumber': invoice.vatNumber,
      'commercialRegistration': invoice.commercialRegistration,
      'invoiceNumber': invoice.invoiceNumber,
      'invoiceType': invoice.invoiceType,
      'issueDate': invoice.issueDate,
      'issueTime': invoice.issueTime,
      'buyerName': invoice.buyerName,
      'buyerVatNumber': invoice.buyerVatNumber,
      'subtotal': invoice.subtotal,
      'discount': invoice.discount,
      'taxableAmount': invoice.taxableAmount,
      'vatRate': invoice.vatRate,
      'vatAmount': invoice.vatAmount,
      'total': invoice.total,
      'currency': invoice.currency,
      'paymentMethod': invoice.paymentMethod,
      'qrRaw': invoice.qrRaw,
      'lineItems': invoice.lineItems
          .map(_lineItemToMap)
          .toList(growable: false),
      'needsReview': invoice.needsReview,
    };
  }

  static List<InvoiceLineItem> _lineItems(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => _lineItemFromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  static InvoiceLineItem _lineItemFromMap(Map<String, dynamic> map) {
    return InvoiceLineItem(
      description: MapValue.string(map['description']),
      quantity: MapValue.number(map['quantity'], fallback: 1),
      unitPrice: MapValue.number(map['unitPrice']),
      vat: MapValue.number(map['vat']),
      total: MapValue.number(map['total']),
    );
  }

  static Map<String, dynamic> _lineItemToMap(InvoiceLineItem item) {
    return {
      'description': item.description,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'vat': item.vat,
      'total': item.total,
    };
  }
}
