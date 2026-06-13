import 'package:military_e_commerce/models/brand.dart';
import 'package:military_e_commerce/models/category.dart';
import 'package:military_e_commerce/models/productSize.dart';
import 'package:military_e_commerce/models/seller.dart';
import 'package:military_e_commerce/core/utils/parse_utils.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final double? priceDiscount;
  final String? described;
  final DateTime? created;

  final int likeCount;
  final int commentCount;
  final int? ratingCount;

  final bool isLiked;
  final bool canEdit;

  final String? sellerId;

  final List<String> images;
  final List<String> videos;

  final List<ProductSize> sizes;

  final Brand? brand;
  final Seller? seller;
  final Category? category;

  final List<dynamic> bestOffers;
  final List<dynamic> messages;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.priceDiscount,
    this.described,
    this.created,
    required this.likeCount,
    required this.commentCount,
    this.ratingCount,
    required this.isLiked,
    required this.canEdit,
    this.sellerId,
    required this.images,
    required this.videos,
    required this.sizes,
    this.brand,
    this.seller,
    this.category,
    required this.bestOffers,
    required this.messages,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      price: toDouble(json['price']) ?? 0,
      priceDiscount: toDouble(json['price_discount']),
      described: json['described']?.toString() ?? json['description']?.toString(),
      created: json['created'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['created'] ?? json['created_at']).toString())
          : null,
      likeCount: toInt(json['like'] ?? json['like_count']) ?? 0,
      commentCount: toInt(json['comment'] ?? json['comment_count']) ?? 0,
      ratingCount: toInt(json['rating_count'] ?? json['rate_count']),
      isLiked: toBool(json['is_liked']),
      canEdit: toBool(json['can_edit']),
      sellerId: json['seller_id']?.toString(),
      images: (json['image'] is List)
          ? List<String>.from(json['image'])
          : (json['image_urls'] is List)
              ? List<String>.from(json['image_urls'])
              : <String>[],
      videos: (json['video'] is List)
          ? List<String>.from(json['video'])
          : (json['videos'] is List)
              ? (json['videos'] as List).map((v) => v is Map ? (v['url']?.toString() ?? '') : v.toString()).toList()
              : <String>[],
      sizes: (json['size'] as List<dynamic>? ?? [])
          .map((e) => ProductSize.fromJson(e))
          .toList(),
      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'])
          : null,
      seller: json['seller'] != null
          ? Seller.fromJson(json['seller'])
          : null,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      bestOffers: json['best_offers'] ?? [],
      messages: json['messages'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'price_discount': priceDiscount,
      'described': described,
      'created': created?.toIso8601String(),
      'like': likeCount,
      'comment': commentCount,
      'rating_count': ratingCount,
      'is_liked': isLiked,
      'can_edit': canEdit,
      'seller_id': sellerId,
      'image': images,
      'video': videos,
      'size': sizes.map((e) => e.toJson()).toList(),
      'brand': brand?.toJson(),
      'seller': seller?.toJson(),
      'category': category?.toJson(),
      'best_offers': bestOffers,
      'messages': messages,
    };
  }

  double get effectivePrice => priceDiscount != null && priceDiscount! > 0 ? priceDiscount! : price;

  bool get hasDiscount => priceDiscount != null && priceDiscount! > 0 && priceDiscount! < price;

  int get discountPercent {
    if (priceDiscount == null || priceDiscount! <= 0 || price <= 0) return 0;
    return ((1 - priceDiscount! / price) * 100).round();
  }
}

class ProductFilter {
  final String? keyword;
  final String? categoryId;
  final String? brandId;
  final String? size;

  final int? priceMin;
  final int? priceMax;

  final String? condition;
  final String? lastId;

  final int index;
  final int count;

  const ProductFilter({
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
