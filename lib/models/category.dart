class Category {
  final int id;
  final String name;
  final int parentId;

  final int sort;

  final bool hasChild;
  final bool hasBrand;
  final bool hasSize;
  final bool requireWeight;

  final String? description;
  final String? imageUrl;

  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.parentId,
    required this.sort,
    required this.hasChild,
    required this.hasBrand,
    required this.hasSize,
    required this.requireWeight,
    this.description,
    this.imageUrl,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      parentId: _toInt(json['parent_id']) ?? 0,

      sort: _toInt(json['sort']) ?? 0,

      hasChild: _toBool(json['has_child']),
      hasBrand: _toBool(json['has_brand']),
      hasSize: _toBool(json['has_size']),
      requireWeight: _toBool(json['require_weight']),

      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'sort': sort,
      'has_child': hasChild,
      'has_brand': hasBrand,
      'has_size': hasSize,
      'require_weight': requireWeight,
      'description': description,
      'image_url': imageUrl,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) return value == 1;

    final str = value.toString().toLowerCase();

    return str == '1' || str == 'true';
  }
}