import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static final DateFormat _documentDate = DateFormat('dd MMM yyyy • HH:mm');

  static String documentDate(DateTime value) => _documentDate.format(value);

  static String decimal(num value, {int digits = 2}) =>
      value.toStringAsFixed(digits);

  static String money(num value, {String currency = 'SAR', int digits = 2}) =>
      '$currency ${decimal(value, digits: digits)}';

  static String quantity(num value) =>
      value % 1 == 0 ? value.toInt().toString() : decimal(value, digits: 2);
}
