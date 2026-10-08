import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/balance_response.dart';

/// User-presentable error raised by [ApiService].
class ApiException implements Exception {
  const ApiException(this.message, {this.isAuthError = false});

  final String message;
  final bool isAuthError;

  @override
  String toString() => 'ApiException: $message';
}

/// Thin, dependency-light client for the DeepSeek REST API.
class ApiService {
  ApiService({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 15);

  static final Uri _balanceEndpoint = Uri.parse(
    'https://api.deepseek.com/user/balance',
  );

  final http.Client _client;
  final Duration _timeout;

  /// Fetches the account balance for the supplied [apiKey].
  ///
  /// Throws [ApiException] with a human friendly message on any failure.
  Future<BalanceResponse> fetchBalance(String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw const ApiException(
        'Please enter your DeepSeek API key.',
        isAuthError: true,
      );
    }

    try {
      final response = await _client
          .get(
            _balanceEndpoint,
            headers: <String, String>{
              'Authorization': 'Bearer $key',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      return _parse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'The request timed out. Please check your connection and try again.',
      );
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not reach DeepSeek. Please try again in a moment.',
      );
    } catch (_) {
      throw const ApiException(
        'Something went wrong while fetching your balance.',
      );
    }
  }

  BalanceResponse _parse(http.Response response) {
    final status = response.statusCode;

    if (status == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const ApiException(
            'Received an unexpected response from DeepSeek.',
          );
        }
        return BalanceResponse.fromJson(decoded);
      } on FormatException {
        throw const ApiException(
          'Received an unreadable response from DeepSeek.',
        );
      }
    }

    throw ApiException(_messageForStatus(status), isAuthError: status == 401);
  }

  String _messageForStatus(int status) {
    switch (status) {
      case 401:
        return 'Your API key is invalid or has expired.';
      case 402:
        return 'Your DeepSeek account has insufficient balance.';
      case 403:
        return 'This API key does not have permission to read the balance.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      default:
        if (status >= 500) {
          return 'DeepSeek is having trouble right now (error $status).';
        }
        return 'Unexpected error from DeepSeek (error $status).';
    }
  }

  void dispose() => _client.close();
}
