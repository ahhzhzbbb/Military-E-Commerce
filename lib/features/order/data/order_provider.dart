import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_data.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/models.dart';

class OrderProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Order> _orders = [];
  List<OrderAddress> _addresses = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  List<OrderAddress> get addresses => _addresses;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount => _orders.where((o) => o.status == 'pending').length;
  int get shippingCount => _orders.where((o) => o.status == 'shipping').length;
  int get deliveredCount =>
      _orders.where((o) => o.status == 'delivered').length;

  List<Order> _parseOrders(dynamic data) {
    return ApiData.asList(data, ['purchases', 'orders', 'items', 'list'])
        .whereType<Map>()
        .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<OrderAddress> _parseAddresses(dynamic data) {
    return ApiData.asList(data, ['addresses', 'items', 'list'])
        .whereType<Map>()
        .map((item) => OrderAddress.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Order? _parseOrder(dynamic data) {
    final map = ApiData.mapFrom(data, ['order', 'purchase']);
    if (map != null) return Order.fromJson(map);

    final list = ApiData.asList(data, ['orders', 'purchases', 'items', 'list']);
    if (list.isEmpty || list.first is! Map) return null;
    return Order.fromJson(Map<String, dynamic>.from(list.first as Map));
  }

  dynamic _productIdParam(String productId) {
    return int.tryParse(productId) ?? productId;
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getListPurchases,
      body: const {'index': 0, 'count': 50},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _orders = _parseOrders(response.data);
    } else {
      _orders = [];
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getListOrderAddress,
      body: <String, dynamic>{},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _addresses = _parseAddresses(response.data);
    } else {
      _addresses = [];
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> createOrder({
    required List<CartItem> items,
    required OrderAddress shippingAddress,
    String? notes,
  }) async {
    if (items.isEmpty) {
      _error = 'Giỏ hàng trống';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    Order? createdOrder;

    for (final item in items) {
      final response = await _apiClient.post(
        ApiConstants.createOrder,
        body: {
          'product_id': _productIdParam(item.product.id.toString()),
          'quantity': item.quantity,
          'address_id': shippingAddress.id,
          'note': notes,
        },
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        _error = '${response.message} (Code: ${response.code})';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      createdOrder ??= _parseOrder(response.data);
    }

    _isLoading = false;

    if (createdOrder != null) {
      _currentOrder = createdOrder;
      _orders.insert(0, createdOrder);
      notifyListeners();
      return createdOrder;
    }

    notifyListeners();
    await loadOrders();
    _currentOrder = _orders.isNotEmpty ? _orders.first : null;
    return _currentOrder;
  }

  Order? getOrder(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    final response = await _apiClient.post(
      ApiConstants.cancelOrder,
      body: {'order_id': orderId},
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      _error = '${response.message} (Code: ${response.code})';
      notifyListeners();
      return false;
    }

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
