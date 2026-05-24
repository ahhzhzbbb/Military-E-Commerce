class Product {
  final String id;
  final String title;
  final String? description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String? video;
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? brandName;
  final String? size;
  final String? condition;
  final String? shipFrom;
  final String? shipFromName;
  final int? stock;
  final int? soldCount;
  final int? likeCount;
  final int? commentCount;
  final int? ratingCount;
  final double? ratingAverage;
  final String? sellerId;
  final String? sellerName;
  final String? sellerAvatar;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.originalPrice,
    this.images = const [],
    this.video,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.size,
    this.condition,
    this.shipFrom,
    this.shipFromName,
    this.stock,
    this.soldCount,
    this.likeCount,
    this.commentCount,
    this.ratingCount,
    this.ratingAverage,
    this.sellerId,
    this.sellerName,
    this.sellerAvatar,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  static String? _toStringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((item) => item != null && item.toString().isNotEmpty)
          .map((item) => item.toString())
          .toList();
    }
    final text = value.toString();
    return text.isEmpty ? [] : [text];
  }

  static int? _stockFromVariants(dynamic value) {
    if (value is! List) return null;
    var total = 0;
    var hasStock = false;

    for (final item in value) {
      if (item is Map) {
        final stock = _toInt(item['stock']);
        if (stock != null) {
          total += stock;
          hasStock = true;
        }
      }
    }

    return hasStock ? total : null;
  }

  static String? _nestedString(
    Map<String, dynamic> json,
    String objectKey,
    List<String> keys,
  ) {
    final nested = json[objectKey];
    if (nested is! Map) return null;

    for (final key in keys) {
      final value = _toStringValue(nested[key]);
      if (value != null) return value;
    }

    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final regularPrice = _toDouble(json['price']);
    final discountPrice =
        _toDouble(json['price_new']) ?? _toDouble(json['price_discount']);
    final hasDiscountPrice = discountPrice != null && discountPrice > 0;
    final images = <String>[
      ..._toStringList(json['images']),
      ..._toStringList(json['image']),
      ..._toStringList(json['image_url']),
      ..._toStringList(json['image_urls']),
    ];
    final videoList = _toStringList(json['videos']);
    final isStock = _toBool(json['is_stock']);

    return Product(
      id: json['id']?.toString() ?? json['product_id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'],
      price: hasDiscountPrice ? discountPrice : regularPrice ?? 0.0,
      originalPrice:
          _toDouble(json['original_price']) ??
          (hasDiscountPrice ? regularPrice : null),
      images: images,
      video:
          _toStringValue(json['video']) ??
          (videoList.isNotEmpty ? videoList.first : null),
      categoryId: json['category_id']?.toString(),
      categoryName:
          json['category_name'] ?? _nestedString(json, 'category', ['name']),
      brandId: json['brand_id']?.toString(),
      brandName: json['brand_name'] ?? _nestedString(json, 'brand', ['name']),
      size: json['size'],
      condition: json['condition'],
      shipFrom:
          json['ship_from']?.toString() ?? json['ship_from_id']?.toString(),
      shipFromName:
          json['ship_from_name'] ?? _nestedString(json, 'ship_from', ['name']),
      stock:
          _toInt(json['stock']) ??
          _stockFromVariants(json['variants']) ??
          (isStock == true ? 1 : null),
      soldCount: _toInt(json['sold_count']) ?? _toInt(json['sold']),
      likeCount: _toInt(json['like_count']) ?? _toInt(json['like']),
      commentCount: _toInt(json['comment_count']) ?? _toInt(json['comment']),
      ratingCount: _toInt(json['rating_count']),
      ratingAverage: _toDouble(json['rating_average']),
      sellerId: json['seller_id']?.toString(),
      sellerName:
          json['seller_name'] ??
          _nestedString(json, 'seller', ['username', 'name']),
      sellerAvatar:
          json['seller_avatar'] ?? _nestedString(json, 'seller', ['avatar']),
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'images': images,
      'video': video,
      'category_id': categoryId,
      'category_name': categoryName,
      'brand_id': brandId,
      'brand_name': brandName,
      'size': size,
      'condition': condition,
      'ship_from': shipFrom,
      'ship_from_name': shipFromName,
      'stock': stock,
      'sold_count': soldCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'rating_count': ratingCount,
      'rating_average': ratingAverage,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_avatar': sellerAvatar,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  bool get isInStock => stock != null && stock! > 0;
}

class ProductFilter {
  final String? keyword;
  final String? categoryId;
  final String? brandId;
  final String? size;
  final double? priceMin;
  final double? priceMax;
  final String? condition;
  final String? lastId;
  final int index;
  final int count;

  ProductFilter({
    this.keyword,
    this.categoryId,
    this.brandId,
    this.size,
    this.priceMin,
    this.priceMax,
    this.condition,
    this.lastId,
    this.index = 0,
    this.count = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      if (keyword != null) 'keyword': keyword,
      if (categoryId != null) 'category_id': categoryId,
      if (brandId != null) 'brand_id': brandId,
      if (size != null) 'size': size,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (condition != null) 'condition': condition,
      if (lastId != null) 'last_id': lastId,
      'index': index,
      'count': count,
    };
  }
}
