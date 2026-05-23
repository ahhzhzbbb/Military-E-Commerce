class Category {
  final String id;
  final String name;
  final String? image;
  final String? parentId;
  final int? productCount;
  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    this.image,
    this.parentId,
    this.productCount,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      parentId: json['parent_id']?.toString(),
      productCount: json['product_count'],
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'parent_id': parentId,
      'product_count': productCount,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

class Brand {
  final String id;
  final String name;
  final String? logo;
  final int? productCount;

  Brand({
    required this.id,
    required this.name,
    this.logo,
    this.productCount,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      productCount: json['product_count'],
    );
  }
}