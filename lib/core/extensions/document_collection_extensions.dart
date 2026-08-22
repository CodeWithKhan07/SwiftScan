import '../../domain/entities/app_document.dart';

extension DocumentCollectionExtensions on Iterable<AppDocument> {
  List<AppDocument> invoicesForMonth(DateTime month) => where(
    (document) =>
        document.invoice != null &&
        document.createdAt.year == month.year &&
        document.createdAt.month == month.month,
  ).toList(growable: false);

  double get invoiceTotal =>
      fold<double>(0, (sum, document) => sum + (document.invoice?.total ?? 0));

  double get vatTotal => fold<double>(
    0,
    (sum, document) => sum + (document.invoice?.vatAmount ?? 0),
  );
}
