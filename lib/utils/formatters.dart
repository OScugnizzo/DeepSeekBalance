import 'package:intl/intl.dart';

/// Maps an ISO currency code to its glyph for display.
String currencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'USD':
      return r'$';
    case 'CNY':
    case 'RMB':
      return '¥';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
      return '¥';
    default:
      return '';
  }
}

/// Formats [amount] for the balance card, e.g. `$ 12.34` or `¥ 50.00`.
String formatCurrency(double amount, String currency) {
  final digits = NumberFormat('#,##0.00', 'en_US');
  final symbol = currencySymbol(currency);
  final value = digits.format(amount);
  return symbol.isEmpty ? '$value ${currency.toUpperCase()}' : '$symbol $value';
}

/// Compact two-decimal formatting used in the details rows.
String formatAmount(double amount) =>
    NumberFormat('#,##0.00', 'en_US').format(amount);
