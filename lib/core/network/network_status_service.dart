import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

enum NetworkStatus { unknown, online, offline }

class NetworkStatusService extends ChangeNotifier {
  NetworkStatusService._();

  static final NetworkStatusService instance = NetworkStatusService._();

  static const _checkInterval = Duration(seconds: 10);
  static const _timeout = Duration(seconds: 4);

  Timer? _timer;
  bool _isChecking = false;
  NetworkStatus _status = NetworkStatus.unknown;

  NetworkStatus get status => _status;
  bool get isOffline => _status == NetworkStatus.offline;

  void start() {
    if (_timer != null) return;
    checkNow();
    _timer = Timer.periodic(_checkInterval, (_) => checkNow());
  }

  Future<void> checkNow() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getCategories}',
      );
      await http
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: '{}',
          )
          .timeout(_timeout);
      markOnline();
    } catch (_) {
      markOffline();
    } finally {
      _isChecking = false;
    }
  }

  void markOnline() {
    _setStatus(NetworkStatus.online);
  }

  void markOffline() {
    _setStatus(NetworkStatus.offline);
  }

  void _setStatus(NetworkStatus nextStatus) {
    if (_status == nextStatus) return;
    _status = nextStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
