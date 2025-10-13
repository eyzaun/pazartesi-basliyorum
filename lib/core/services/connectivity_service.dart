import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {

  ConnectivityService(this._connectivity) {
    _init();
  }
  final Connectivity _connectivity;
  final _connectivityController = StreamController<bool>.broadcast();

  bool _isOnline = true;

  Stream<bool> get onConnectivityChanged => _connectivityController.stream;
  bool get isOnline => _isOnline;

  void _init() {
    // Check initial connectivity
    _connectivity.checkConnectivity().then(_updateConnectivityStatus);

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty && 
                !results.every((result) => result == ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
    }
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectivityStatus(results);
    return _isOnline;
  }

  void dispose() {
    _connectivityController.close();
  }
}

// Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = Connectivity();
  return ConnectivityService(connectivity);
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.onConnectivityChanged;
});
