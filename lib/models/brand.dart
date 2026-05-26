class Brand {
  final String id;
  final String name;
  final String logoUrl;

  Brand({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
    };
  }
}