import 'package:military_e_commerce/models/brand.dart';
import 'package:military_e_commerce/models/category.dart';
import 'package:military_e_commerce/models/productSize.dart';
import 'package:military_e_commerce/models/seller.dart';

class Product {
  final int id;
  final String name;
  final int price;

  final String? described;
  final DateTime? created;

  final int likeCount;
  final int commentCount;

  final bool isLiked;
  final bool canEdit;

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
    this.described,
    this.created,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.canEdit,
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
      id: _toInt(json['id']) ?? 0,

      name: json['name']?.toString() ?? '',

      price: _toInt(json['price']) ?? 0,

      described: json['described']?.toString(),

      created: json['created'] != null
          ? DateTime.tryParse(json['created'].toString())
          : null,

      likeCount: _toInt(json['like']) ?? 0,

      commentCount: _toInt(json['comment']) ?? 0,

      isLiked: json['is_liked'] ?? false,

      canEdit: json['can_edit'] ?? false,

      images: List<String>.from(json['image'] ?? []),

      videos: List<String>.from(json['video'] ?? []),

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
      'described': described,
      'created': created?.toIso8601String(),
      'like': likeCount,
      'comment': commentCount,
      'is_liked': isLiked,
      'can_edit': canEdit,
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

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
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