import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface for checking network connectivity.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using connectivity_plus package.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this.connectivity);
  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}
