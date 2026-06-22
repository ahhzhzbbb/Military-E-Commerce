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
    // The backend returns the address list directly as `data` (a List),
    // or nested under known keys. ApiData.asList handles both cases.
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

    // Backend endpoint is GET /order/get_list_order_address
    final response = await _apiClient.get(
      ApiConstants.getListOrderAddress,
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

    // Backend expects a single request with all items grouped together.
    // CreateOrderDto: { items: [{product_id, quantity}], address_id, order_source }
    // order_source: 0 = from cart, 1 = direct buy
    final orderItems = items
        .map((item) => {
              'product_id': _productIdParam(item.product.id.toString()),
              'quantity': item.quantity,
            })
        .toList();

    final addressId = int.tryParse(shippingAddress.id) ??
        (shippingAddress.id.isNotEmpty ? shippingAddress.id : null);

    if (addressId == null) {
      _error = 'Địa chỉ giao hàng không hợp lệ';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final response = await _apiClient.post(
      ApiConstants.createOrder,
      body: {
        'items': orderItems,
        'address_id': addressId,
        'order_source': 0, // 0 = from cart
      },
      requiresAuth: true,
    );

    _isLoading = false;

    if (!response.isSuccess) {
      _error = '${response.message} (Code: ${response.code})';
      notifyListeners();
      return null;
    }

    // Try to parse the order from the response data
    final createdOrder = _parseOrder(response.data);

    if (createdOrder != null) {
      _currentOrder = createdOrder;
      _orders.insert(0, createdOrder);
      notifyListeners();
      return createdOrder;
    }

    // If parsing fails, reload orders and return the latest
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
      body: {
        'id': orderId,
        'purchase_id': orderId,
        'order_id': orderId,
        'reason': 'Người dùng hủy đơn',
      },
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
        cancelReason: 'Người dùng hủy đơn',
        trackingNumber: _orders[index].trackingNumber,
        createdAt: _orders[index].createdAt,
        updatedAt: DateTime.now(),
        timeline: _orders[index].timeline,
      );
      notifyListeners();
      return true;
    }
    
    _error = 'Không tìm thấy đơn hàng trên máy để cập nhật trạng thái';
    notifyListeners();
    return false;
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  Future<void> loadOrderTimeline(String orderId) async {
    final response = await _apiClient.post(
      ApiConstants.getOrderTimeline,
      body: {'purchase_id': orderId}, // Backend GetOrderTimelineDto expects string 'purchase_id'
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final timelineList = ApiData.asList(response.data, ['timeline', 'items', 'list'])
          .whereType<Map>()
          .map((item) => OrderTimeline.fromJson(Map<String, dynamic>.from(item)))
          .toList();

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
          status: _orders[index].status,
          statusName: _orders[index].statusName,
          notes: _orders[index].notes,
          cancelReason: _orders[index].cancelReason,
          trackingNumber: _orders[index].trackingNumber,
          createdAt: _orders[index].createdAt,
          updatedAt: _orders[index].updatedAt,
          timeline: timelineList,
        );
        notifyListeners();
      }
    }
  }

  Future<bool> buyerConfirmReceived(String orderId) async {
    final response = await _apiClient.post(
      ApiConstants.buyerConfirmReceived,
      body: {'purchase_id': orderId}, // Backend BuyerConfirmReceivedDto expects string 'purchase_id'
      requiresAuth: true,
    );

    if (response.isSuccess) {
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
          status: 'delivered',
          statusName: 'Đã giao hàng',
          notes: _orders[index].notes,
          cancelReason: _orders[index].cancelReason,
          trackingNumber: _orders[index].trackingNumber,
          createdAt: _orders[index].createdAt,
          updatedAt: DateTime.now(),
          timeline: _orders[index].timeline,
        );
        notifyListeners();
      }
      return true;
    }
    _error = '${response.message} (Code: ${response.code})';
    notifyListeners();
    return false;
  }

  Future<bool> refundOrder(String orderId, {String? reason}) async {
    final body = <String, dynamic>{
      'purchase_id': orderId, // Backend RefundOrderDto expects string 'purchase_id'
    };
    if (reason != null) {
      body['reason'] = reason;
    }

    final response = await _apiClient.post(
      ApiConstants.refundOrder,
      body: body,
      requiresAuth: true,
    );

    if (response.isSuccess) {
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
          status: 'refunded',
          statusName: 'Đã hoàn tiền',
          notes: _orders[index].notes,
          cancelReason: reason ?? _orders[index].cancelReason,
          trackingNumber: _orders[index].trackingNumber,
          createdAt: _orders[index].createdAt,
          updatedAt: DateTime.now(),
          timeline: _orders[index].timeline,
        );
        notifyListeners();
      }
      return true;
    }
    _error = '${response.message} (Code: ${response.code})';
    notifyListeners();
    return false;
  }

  /// Add a new shipping address.
  /// Backend expects: POST /order/add_order_address with body:
  /// { address, is_default, address_id: [ward_id, province_id],
  ///   lat, lng, receiver_name, phone, full_address, address_detail }
  Future<void> addAddress({
    required String name,
    required String phone,
    required String address,
    bool isDefault = false,
    String? fullAddress,
    String? addressDetail,
    int wardId = 7,
    int provinceId = 1,
    double lat = 21.0285,
    double lng = 105.8542,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.addOrderAddress,
      body: {
        'receiver_name': name,
        'phone': phone,
        'address': address,
        'full_address': fullAddress ?? address,
        'address_detail': addressDetail ?? address,
        'is_default': isDefault,
        'address_id': [wardId, provinceId],
        'lat': lat,
        'lng': lng,
      },
      requiresAuth: true,
    );

    if (response.isSuccess) {
      await loadAddresses();
    } else {
      _error = '${response.message} (Code: ${response.code})';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing address.
  /// Backend expects: PATCH /order/update/:id
  Future<void> updateAddress({
    required String addressId,
    required String name,
    required String phone,
    required String address,
    bool isDefault = false,
    String? fullAddress,
    String? addressDetail,
  }) async {
    _isLoading = true;
    notifyListeners();

    final id = int.tryParse(addressId) ?? addressId;
    final response = await _apiClient.patch(
      '${ApiConstants.editOrderAddress}/$id',
      body: {
        'receiver_name': name,
        'phone': phone,
        'address': address,
        'full_address': fullAddress ?? address,
        'address_detail': addressDetail ?? address,
        'is_default': isDefault,
      },
      requiresAuth: true,
    );

    if (response.isSuccess) {
      await loadAddresses();
    } else {
      _error = '${response.message} (Code: ${response.code})';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an address.
  /// Backend expects: DELETE /order/delete/:id
  Future<void> deleteAddress(String addressId) async {
    _isLoading = true;
    notifyListeners();

    final id = int.tryParse(addressId) ?? addressId;
    final response = await _apiClient.delete(
      '${ApiConstants.deleteOrderAddress}/$id',
      requiresAuth: true,
    );

    if (response.isSuccess) {
      await loadAddresses();
    } else {
      _error = '${response.message} (Code: ${response.code})';
      _isLoading = false;
      notifyListeners();
    }
  }
}
