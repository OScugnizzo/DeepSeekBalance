import 'package:deepseekbalance/providers/balance_provider.dart';
import 'package:deepseekbalance/services/api_service.dart';
import 'package:deepseekbalance/services/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _validPayload =
    '{"is_available":true,"balance_infos":[{"currency":"USD",'
    '"total_balance":"10.00","granted_balance":"0.00",'
    '"topped_up_balance":"10.00"}]}';

ApiService _apiReturning(String body, {int status = 200}) {
  return ApiService(
    client: MockClient(
      (request) async => http.Response(
        body,
        status,
        headers: {'content-type': 'application/json'},
      ),
    ),
  );
}

class _FakeStorage implements ApiKeyStorage {
  _FakeStorage([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> save(String apiKey) async => value = apiKey;

  @override
  Future<void> clear() async => value = null;
}

void main() {
  group('BalanceProvider', () {
    test('saveKeyAndRefresh stores the key and loads the balance', () async {
      final storage = _FakeStorage();
      final provider = BalanceProvider(
        apiService: _apiReturning(_validPayload),
        storageService: storage,
      );
      addTearDown(provider.dispose);

      final ok = await provider.saveKeyAndRefresh(' sk-test ');

      expect(ok, isTrue);
      expect(storage.value, 'sk-test');
      expect(provider.balance!.primary!.totalBalance, 10);
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('an invalid key surfaces an auth error', () async {
      final provider = BalanceProvider(
        apiService: _apiReturning('{"error":"nope"}', status: 401),
        storageService: _FakeStorage(),
      );
      addTearDown(provider.dispose);

      final ok = await provider.saveKeyAndRefresh('bad-key');

      expect(ok, isFalse);
      expect(provider.isAuthError, isTrue);
      expect(provider.balance, isNull);
      expect(provider.errorMessage, contains('invalid'));
    });

    test('initialize loads a stored key and refreshes automatically', () async {
      final provider = BalanceProvider(
        apiService: _apiReturning(_validPayload),
        storageService: _FakeStorage('sk-stored'),
      );
      addTearDown(provider.dispose);

      await provider.initialize();

      expect(provider.isInitializing, isFalse);
      expect(provider.hasApiKey, isTrue);
      expect(provider.balance, isNotNull);
    });

    test('initialize without a stored key leaves the screen ready', () async {
      final provider = BalanceProvider(
        apiService: _apiReturning(_validPayload),
        storageService: _FakeStorage(),
      );
      addTearDown(provider.dispose);

      await provider.initialize();

      expect(provider.isInitializing, isFalse);
      expect(provider.hasApiKey, isFalse);
      expect(provider.balance, isNull);
    });

    test('clearKey wipes the stored key and resets state', () async {
      final storage = _FakeStorage('sk-stored');
      final provider = BalanceProvider(
        apiService: _apiReturning(_validPayload),
        storageService: storage,
      );
      addTearDown(provider.dispose);

      await provider.initialize();
      await provider.clearKey();

      expect(storage.value, isNull);
      expect(provider.hasApiKey, isFalse);
      expect(provider.balance, isNull);
    });
  });
}
