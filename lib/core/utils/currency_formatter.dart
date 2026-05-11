import 'package:intl/intl.dart';

/// Currency formatter for Rupiah (Rp)
class CurrencyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format double to Rp format (e.g., "Rp 1.500.000")
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Parse Rp string to double
  static double parse(String rpString) {
    final cleanString = rpString.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanString) ?? 0.0;
  }
}
