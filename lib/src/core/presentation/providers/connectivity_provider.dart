import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    _init();
  }

  final Connectivity _connectivity = Connectivity();

  Future<void> _init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      state = !_hasNoConnection(result);

      _connectivity.onConnectivityChanged.listen((result) {
        state = !_hasNoConnection(result);
      });
    } catch (_) {
      state = true;
    }
  }

  bool _hasNoConnection(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.none);
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((
  ref,
) {
  return ConnectivityNotifier();
});
