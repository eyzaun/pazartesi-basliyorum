import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for monitoring network connectivity changes.
class ConnectivityService {
  
  ConnectivityService(this._connectivity);
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  /// Check if device is currently connected.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }
  
  /// Get connectivity type.
  Future<ConnectivityResult> get connectivityType async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return ConnectivityResult.none;
    return results.first;
  }
  
  /// Stream of connectivity changes.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }
  
  /// Start listening to connectivity changes.
  void startMonitoring(void Function({required bool isConnected}) onChanged) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      onChanged(isConnected: _hasConnection(results));
    });
  }
  
  /// Stop listening to connectivity changes.
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }
  
  bool _hasConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
  
  void dispose() {
    stopMonitoring();
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for connectivity service.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(Connectivity());
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for current connectivity status.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});