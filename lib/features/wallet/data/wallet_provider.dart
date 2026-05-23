import 'package:flutter/material.dart';
import '../../../core/utils/mock_data.dart';
import '../../../models/models.dart';

class WalletProvider extends ChangeNotifier {
  WalletBalance? _balance;
  List<BalanceTransaction> _transactions = [];
  bool _isLoading = false;

  WalletBalance? get balance => _balance;
  List<BalanceTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadBalance() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _balance = MockData.getMockBalance();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _transactions = [
      BalanceTransaction(
        id: 'tx1',
        type: 'income',
        typeName: 'Thu nhập',
        amount: 100000,
        description: 'Thưởng hoàn thành nhiệm vụ',
        balanceAfter: 500000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BalanceTransaction(
        id: 'tx2',
        type: 'expense',
        typeName: 'Chi tiêu',
        amount: -25000,
        description: 'Mua áo chống đạn Level IIIA',
        balanceAfter: 400000,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      BalanceTransaction(
        id: 'tx3',
        type: 'income',
        typeName: 'Thu nhập',
        amount: 50000,
        description: 'Quy đổi chiến tích tháng 5',
        balanceAfter: 425000,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }
}