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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      video: json['video'],
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'],
      brandId: json['brand_id']?.toString(),
      brandName: json['brand_name'],
      size: json['size'],
      condition: json['condition'],
      shipFrom: json['ship_from']?.toString(),
      shipFromName: json['ship_from_name'],
      stock: json['stock'],
      soldCount: json['sold_count'],
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
      ratingCount: json['rating_count'],
      ratingAverage: (json['rating_average'] as num?)?.toDouble(),
      sellerId: json['seller_id']?.toString(),
      sellerName: json['seller_name'],
      sellerAvatar: json['seller_avatar'],
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

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

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