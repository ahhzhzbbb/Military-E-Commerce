import 'product.dart';

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
    return CartItem(
      id: json['id']?.toString() ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
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
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      provinceId: json['province_id']?.toString(),
      provinceName: json['province_name'],
      districtId: json['district_id']?.toString(),
      districtName: json['district_name'],
      wardId: json['ward_id']?.toString(),
      wardName: json['ward_name'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
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
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (wardName != null) parts.add(wardName!);
    if (districtName != null) parts.add(districtName!);
    if (provinceName != null) parts.add(provinceName!);
    parts.add(address);
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
    this.trackingNumber,
    this.createdAt,
    this.updatedAt,
    this.timeline,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString(),
      sellerId: json['seller_id']?.toString(),
      sellerName: json['seller_name'],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingAddress: json['shipping_address'] != null
          ? OrderAddress.fromJson(json['shipping_address'])
          : null,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
      statusName: json['status_name'],
      notes: json['notes'],
      trackingNumber: json['tracking_number'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      timeline: (json['timeline'] as List<dynamic>?)
          ?.map((e) => OrderTimeline.fromJson(e as Map<String, dynamic>))
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
    return OrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString(),
      productTitle: json['product_title'],
      productImage: json['product_image'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 1,
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
      statusName: json['status_name'],
      description: json['description'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }
}