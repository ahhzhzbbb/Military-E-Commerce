import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;

  int get pendingCount => _orders.where((o) => o.status == 'pending').length;
  int get shippingCount => _orders.where((o) => o.status == 'shipping').length;
  int get deliveredCount => _orders.where((o) => o.status == 'delivered').length;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _orders = MockData.getMockOrders();
    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> createOrder({
    required List<CartItem> items,
    required OrderAddress shippingAddress,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final shippingFee = subtotal > 0 ? 5000.0 : 0.0;

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      buyerId: 'user_001',
      sellerId: items.first.product.sellerId,
      sellerName: items.first.product.sellerName,
      items: items.map((item) => OrderItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        productId: item.product.id,
        productTitle: item.product.title,
        productImage: item.product.images.isNotEmpty ? item.product.images.first : null,
        price: item.product.price,
        quantity: item.quantity,
        selectedSize: item.selectedSize,
      )).toList(),
      shippingAddress: shippingAddress,
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: subtotal + shippingFee,
      status: 'pending',
      statusName: 'Chờ xác nhận',
      notes: notes,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, order);
    _currentOrder = order;
    _isLoading = false;
    notifyListeners();

    return order;
  }

  Order? getOrder(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = Order(
        id: _orders[index].id,
        buyerId: _orders[index].buyerId,
        sellerId: _orders[index].sellerId,
        sellerName: _orders[index].sellerName,
        items: _orders[index].items,
        shippingAddress: _orders[index].shippingAddress,
        subtotal: _orders[index].subtotal,
        shippingFee: _orders[index].shippingFee,
        total: _orders[index].total,
        status: 'cancelled',
        statusName: 'Đã hủy',
        notes: _orders[index].notes,
        createdAt: _orders[index].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }
}