import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_data.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/models.dart';

class WalletProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  WalletBalance? _balance;
  List<BalanceTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  WalletBalance? get balance => _balance;
  List<BalanceTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BalanceTransaction> _parseTransactions(dynamic data) {
    return ApiData.asList(data, ['transactions', 'history', 'items', 'list'])
        .whereType<Map>()
        .map(
          (item) =>
              BalanceTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> loadBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getCurrentBalance,
      body: <String, dynamic>{},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final data = ApiData.mapFrom(response.data);
      _balance = data != null ? WalletBalance.fromJson(data) : null;
    } else {
      _balance = null;
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getBalanceHistory,
      body: const {'index': 0, 'count': 50},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _transactions = _parseTransactions(response.data);
    } else {
      _transactions = [];
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }
}
