import 'product.dart';
import 'package:military_e_commerce/core/utils/parse_utils.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? notes;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.notes,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productMap = asMap(json['product']) ?? {};
    return CartItem(
      id: json['id']?.toString() ?? '',
      product: Product.fromJson(productMap),
      quantity: toInt(json['quantity']) ?? 1,
      selectedSize: json['selected_size'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'selected_size': selectedSize,
      'notes': notes,
    };
  }

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSize,
    String? notes,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      notes: notes ?? this.notes,
    );
  }
}

class OrderAddress {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? provinceId;
  final String? provinceName;
  final String? districtId;
  final String? districtName;
  final String? wardId;
  final String? wardName;
  final bool isDefault;
  final String? fullAddress;
  final String? addressDetail;
  final double? lat;
  final double? lng;

  OrderAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.provinceId,
    this.provinceName,
    this.districtId,
    this.districtName,
    this.wardId,
    this.wardName,
    this.isDefault = false,
    this.fullAddress,
    this.addressDetail,
    this.lat,
    this.lng,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: json['id']?.toString() ?? json['address_id']?.toString() ?? '',
      name: json['name'] ?? json['receiver_name'] ?? '',
      phone: json['phone'] ?? json['receiver_phone'] ?? '',
      address: json['address'] ?? json['detail'] ?? json['address_detail'] ?? '',
      provinceId: json['province_id']?.toString(),
      provinceName: json['province_name'] ?? json['province'],
      districtId: json['district_id']?.toString(),
      districtName: json['district_name'] ?? json['district'],
      wardId: json['ward_id']?.toString(),
      wardName: json['ward_name'] ?? json['ward'],
      isDefault: toBool(json['is_default']),
      fullAddress: json['full_address'],
      addressDetail: json['address_detail'],
      lat: toDouble(json['lat']),
      lng: toDouble(json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'province_id': provinceId,
      'province_name': provinceName,
      'district_id': districtId,
      'district_name': districtName,
      'ward_id': wardId,
      'ward_name': wardName,
      'is_default': isDefault,
      'full_address': fullAddress,
      'address_detail': addressDetail,
      'lat': lat,
      'lng': lng,
    };
  }

  String get displayAddress {
    if (fullAddress != null && fullAddress!.isNotEmpty) return fullAddress!;
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (wardName != null) parts.add(wardName!);
    if (districtName != null) parts.add(districtName!);
    if (provinceName != null) parts.add(provinceName!);
    return parts.join(', ');
  }
}

class Order {
  final String id;
  final String? buyerId;
  final String? sellerId;
  final String? sellerName;
  final List<OrderItem> items;
  final OrderAddress? shippingAddress;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String status;
  final String? statusName;
  final String? notes;
  final String? cancelReason;
  final String? trackingNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderTimeline>? timeline;

  Order({
    required this.id,
    this.buyerId,
    this.sellerId,
    this.sellerName,
    this.items = const [],
    this.shippingAddress,
    this.subtotal = 0,
    this.shippingFee = 0,
    this.total = 0,
    this.status = 'pending',
    this.statusName,
    this.notes,
    this.cancelReason,
    this.trackingNumber,
    this.createdAt,
    this.updatedAt,
    this.timeline,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemMaps =
        (json['items'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList() ??
        [];
    final items = itemMaps.map(OrderItem.fromJson).toList();
    final hasFlatProduct =
        json['product_id'] != null ||
        json['product_title'] != null ||
        json['name'] != null;
    final orderItems = items.isNotEmpty
        ? items
        : hasFlatProduct
        ? [OrderItem.fromJson(json)]
        : <OrderItem>[];
    final shippingAddressMap = asMap(json['shipping_address']);
    final shippingAddressText = asString(json['shipping_address']);
    OrderAddress? generatedAddress;
    if (json['recipient_name'] != null ||
        json['receiver_name'] != null ||
        json['phone'] != null ||
        shippingAddressText != null) {
      final addr = <String, dynamic>{...json};
      if (shippingAddressText != null) {
        addr['shipping_address'] = shippingAddressText;
      }
      generatedAddress = OrderAddress.fromJson(addr);
    }
    final subtotalFromItems = orderItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final subtotal = toDouble(json['subtotal']) ?? subtotalFromItems;
    final shippingFee = toDouble(json['shipping_fee']) ?? 0;

    return Order(
      id: json['id']?.toString() ??
          json['order_id']?.toString() ??
          json['purchase_id']?.toString() ??
          '',
      buyerId: json['buyer_id']?.toString(),
      sellerId: json['seller_id']?.toString(),
      sellerName: json['seller_name'],
      items: orderItems,
      shippingAddress: shippingAddressMap != null
          ? OrderAddress.fromJson(shippingAddressMap)
          : generatedAddress,
      subtotal: subtotal,
      shippingFee: shippingFee,
      total:
          toDouble(json['total']) ??
          toDouble(json['total_amount']) ??
          toDouble(json['total_price']) ??
          subtotal + shippingFee,
      status: json['status'] ?? json['state'] ?? 'pending',
      statusName: json['status_name'] ?? json['status_label'] ?? json['state'],
      notes: json['notes'] ?? json['note'],
      cancelReason: json['cancel_reason'] ?? json['refund_reason'],
      trackingNumber: json['tracking_number'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      timeline: (json['timeline'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) => OrderTimeline.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'items': items.map((e) => e.toJson()).toList(),
      'shipping_address': shippingAddress?.toJson(),
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'total': total,
      'status': status,
      'status_name': statusName,
      'notes': notes,
      'tracking_number': trackingNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String id;
  final String? productId;
  final String? productTitle;
  final String? productImage;
  final double price;
  final int quantity;
  final String? selectedSize;

  OrderItem({
    required this.id,
    this.productId,
    this.productTitle,
    this.productImage,
    required this.price,
    required this.quantity,
    this.selectedSize,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final productMap = asMap(json['product']);
    final product = productMap != null ? Product.fromJson(productMap) : null;
    final productImages = product?.images ?? [];

    return OrderItem(
      id: json['id']?.toString() ?? json['item_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? json['productId']?.toString(),
      productTitle: json['product_title'] ?? json['name'] ?? product?.name,
      productImage:
          json['product_image'] ??
          json['image'] ??
          (productImages.isNotEmpty ? productImages.first : null),
      price: toDouble(json['price']) ?? toDouble(json['total_price']) ?? 0,
      quantity: toInt(json['quantity']) ?? 1,
      selectedSize: json['selected_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_title': productTitle,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'selected_size': selectedSize,
    };
  }

  double get totalPrice => price * quantity;
}

class OrderTimeline {
  final String id;
  final String status;
  final String? statusName;
  final String? description;
  final DateTime? timestamp;

  OrderTimeline({
    required this.id,
    required this.status,
    this.statusName,
    this.description,
    this.timestamp,
  });

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? '',
      statusName: json['status_name'] ?? json['label'],
      description: json['description'] ?? json['note'],
      timestamp: json['timestamp'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['timestamp'] ?? json['created_at']).toString())
          : null,
    );
  }
}
