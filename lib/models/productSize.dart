class ProductSize {
  // "id": "1",
  // "size": "M",
  // "color": "Đỏ",
  // "stock": "10"
  final String id;
  final String size;
  final String? color;
  final String stock;
  ProductSize({
    required this.id,
    required this.size,
    this.color,
    required this.stock,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      id: json['id']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString(),
      stock: json['stock']?.toString() ?? '0',
    );
  }

  @override
  String toString() {
    return 'ProductSize(id: $id, size: $size, color: $color, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductSize &&
        other.id == id &&
        other.size == size &&
        other.color == color &&
        other.stock == stock;
  }

  @override
  int get hashCode {
    return Object.hash(id, size, color, stock);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size,
      'color': color,
      'stock': stock,
    };
  }
}