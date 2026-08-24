import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, String symbol) {
    final fmt = NumberFormat("#,##0.00", "en_US");
    return '$symbol${fmt.format(amount)}';
  }

  static String date(DateTime d) => DateFormat('d MMM yyyy').format(d);
  static String dateShort(DateTime d) => DateFormat('d MMM').format(d);
}