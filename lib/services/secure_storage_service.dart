import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistence contract for the DeepSeek API key.
///
/// Kept abstract so the presentation layer can be tested without touching
/// platform channels.
abstract class ApiKeyStorage {
  Future<String?> read();
  Future<void> save(String apiKey);
  Future<void> clear();
}

/// [ApiKeyStorage] backed by the OS keychain / keystore via
/// `flutter_secure_storage`.
class SecureStorageService implements ApiKeyStorage {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  static const String _apiKeyKey = 'deepseek_api_key';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      final value = await _storage.read(key: _apiKeyKey);
      final trimmed = value?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String apiKey) =>
      _storage.write(key: _apiKeyKey, value: apiKey.trim());

  @override
  Future<void> clear() => _storage.delete(key: _apiKeyKey);
}
