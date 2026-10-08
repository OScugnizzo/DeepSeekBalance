import 'package:meta/meta.dart';

/// A single currency entry returned by the DeepSeek balance endpoint.
@immutable
class BalanceInfo {
  const BalanceInfo({
    required this.currency,
    required this.totalBalance,
    required this.grantedBalance,
    required this.toppedUpBalance,
  });

  final String currency;
  final double totalBalance;
  final double grantedBalance;
  final double toppedUpBalance;

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      currency: (json['currency'] as String?)?.trim().toUpperCase() ?? 'USD',
      totalBalance: _toDouble(json['total_balance']),
      grantedBalance: _toDouble(json['granted_balance']),
      toppedUpBalance: _toDouble(json['topped_up_balance']),
    );
  }

  /// The API returns monetary values as strings (e.g. `"10.00"`); be defensive
  /// so a numeric JSON value never crashes the parser.
  static double _toDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'currency': currency,
    'total_balance': totalBalance.toStringAsFixed(2),
    'granted_balance': grantedBalance.toStringAsFixed(2),
    'topped_up_balance': toppedUpBalance.toStringAsFixed(2),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceInfo &&
          other.currency == currency &&
          other.totalBalance == totalBalance &&
          other.grantedBalance == grantedBalance &&
          other.toppedUpBalance == toppedUpBalance;

  @override
  int get hashCode =>
      Object.hash(currency, totalBalance, grantedBalance, toppedUpBalance);
}
