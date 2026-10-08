import 'package:deepseekbalance/models/balance_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BalanceResponse', () {
    test('parses a typical successful payload', () {
      final response = BalanceResponse.fromJson(const {
        'is_available': true,
        'balance_infos': [
          {
            'currency': 'USD',
            'total_balance': '10.00',
            'granted_balance': '0.00',
            'topped_up_balance': '10.00',
          },
        ],
      });

      expect(response.isAvailable, isTrue);
      expect(response.balanceInfos, hasLength(1));
      expect(response.primary!.currency, 'USD');
      expect(response.primary!.totalBalance, 10);
      expect(response.primary!.toppedUpBalance, 10);
      expect(response.primary!.grantedBalance, 0);
    });

    test('handles an unavailable account with no balance entries', () {
      final response = BalanceResponse.fromJson(const {
        'is_available': false,
        'balance_infos': <Object>[],
      });

      expect(response.isAvailable, isFalse);
      expect(response.balanceInfos, isEmpty);
      expect(response.primary, isNull);
    });

    test('prefers the currency with a positive balance', () {
      final response = BalanceResponse.fromJson(const {
        'is_available': true,
        'balance_infos': [
          {
            'currency': 'CNY',
            'total_balance': '0.00',
            'granted_balance': '0.00',
            'topped_up_balance': '0.00',
          },
          {
            'currency': 'USD',
            'total_balance': '3.50',
            'granted_balance': '0.50',
            'topped_up_balance': '3.00',
          },
        ],
      });

      expect(response.primary!.currency, 'USD');
    });

    test('is resilient to numeric and missing values', () {
      final response = BalanceResponse.fromJson(const {
        'is_available': true,
        'balance_infos': [
          {'currency': 'usd', 'total_balance': 12.5},
        ],
      });

      expect(response.balanceInfos.single.currency, 'USD');
      expect(response.balanceInfos.single.totalBalance, 12.5);
      expect(response.balanceInfos.single.grantedBalance, 0);
    });
  });
}
