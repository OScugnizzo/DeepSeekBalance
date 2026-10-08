import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/balance_response.dart';
import '../services/api_service.dart';
import '../services/peak_hours_service.dart';
import '../services/secure_storage_service.dart';

/// Single source of truth for the balance screen.
///
/// Owns the API key, the fetched balance, loading/error state and the current
/// peak-traffic window. Deliberately dependency-light (plain [ChangeNotifier]
/// surfaced through `provider`).
class BalanceProvider extends ChangeNotifier {
  BalanceProvider({
    required ApiService apiService,
    required ApiKeyStorage storageService,
    PeakHoursService peakHoursService = const PeakHoursService(),
  }) : _api = apiService,
       _storage = storageService,
       _peakHours = peakHoursService {
    _traffic = _peakHours.statusNow();
  }

  final ApiService _api;
  final ApiKeyStorage _storage;
  final PeakHoursService _peakHours;

  Timer? _trafficTimer;

  String? _apiKey;
  BalanceResponse? _balance;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isAuthError = false;
  DateTime? _lastUpdated;
  late TrafficStatus _traffic;

  String? get apiKey => _apiKey;
  bool get hasApiKey => _apiKey != null;
  BalanceResponse? get balance => _balance;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isAuthError => _isAuthError;
  DateTime? get lastUpdated => _lastUpdated;
  TrafficStatus get traffic => _traffic;

  /// Loads any persisted key and immediately refreshes the balance.
  Future<void> initialize() async {
    _startTrafficTimer();
    final stored = await _storage.read();
    if (stored != null && stored.isNotEmpty) {
      _apiKey = stored;
      notifyListeners();
      await refresh();
    } else {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Persists [rawKey], then fetches the balance. Returns `true` when the
  /// key was accepted by DeepSeek.
  Future<bool> saveKeyAndRefresh(String rawKey) async {
    final key = rawKey.trim();
    if (key.isEmpty) {
      _fail('Please enter your DeepSeek API key.', authError: true);
      return false;
    }

    _apiKey = key;
    try {
      await _storage.save(key);
    } catch (_) {
      // Non-fatal: we can still attempt the request for this session.
    }
    return _fetch();
  }

  /// Re-fetches the balance using the currently stored key.
  Future<bool> refresh() {
    if (_apiKey == null || _apiKey!.isEmpty) {
      _fail('Add your DeepSeek API key to see your balance.', authError: true);
      return Future<bool>.value(false);
    }
    return _fetch();
  }

  /// Removes the persisted key and resets the screen.
  Future<void> clearKey() async {
    try {
      await _storage.clear();
    } catch (_) {
      // Ignore storage failures; clear in-memory state regardless.
    }
    _apiKey = null;
    _balance = null;
    _errorMessage = null;
    _isAuthError = false;
    _lastUpdated = null;
    notifyListeners();
  }

  Future<bool> _fetch() async {
    _isLoading = true;
    _isInitializing = false;
    _errorMessage = null;
    _isAuthError = false;
    notifyListeners();

    try {
      final result = await _api.fetchBalance(_apiKey!);
      _balance = result;
      _lastUpdated = DateTime.now();
      _errorMessage = null;
      _isAuthError = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _balance = null;
      _isLoading = false;
      _errorMessage = error.message;
      _isAuthError = error.isAuthError;
      notifyListeners();
      return false;
    } catch (_) {
      _balance = null;
      _isLoading = false;
      _errorMessage = 'Something went wrong while fetching your balance.';
      _isAuthError = false;
      notifyListeners();
      return false;
    }
  }

  void _fail(String message, {required bool authError}) {
    _isLoading = false;
    _errorMessage = message;
    _isAuthError = authError;
    notifyListeners();
  }

  void _startTrafficTimer() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final next = _peakHours.statusNow();
      if (next.isPeak != _traffic.isPeak) {
        _traffic = next;
        notifyListeners();
      } else {
        _traffic = next;
      }
    });
  }

  @override
  void dispose() {
    _trafficTimer?.cancel();
    _api.dispose();
    super.dispose();
  }
}
