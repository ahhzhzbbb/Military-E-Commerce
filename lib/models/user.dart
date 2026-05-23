class User {
  final String id;
  final String? email;
  final String? phone;
  final String? username;
  final String? avatar;
  final String? coverImage;
  final String? address;
  final int? followerCount;
  final int? followingCount;
  final int? listingCount;
  final double? balance;
  final DateTime? createdAt;

  User({
    required this.id,
    this.email,
    this.phone,
    this.username,
    this.avatar,
    this.coverImage,
    this.address,
    this.followerCount,
    this.followingCount,
    this.listingCount,
    this.balance,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'],
      phone: json['phone'],
      username: json['username'],
      avatar: json['avatar'],
      coverImage: json['cover_image'],
      address: json['address'],
      followerCount: json['follower_count'],
      followingCount: json['following_count'],
      listingCount: json['listing_count'],
      balance: (json['balance'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'username': username,
      'avatar': avatar,
      'cover_image': coverImage,
      'address': address,
      'follower_count': followerCount,
      'following_count': followingCount,
      'listing_count': listingCount,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? username,
    String? avatar,
    String? coverImage,
    String? address,
    int? followerCount,
    int? followingCount,
    int? listingCount,
    double? balance,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
      address: address ?? this.address,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      listingCount: listingCount ?? this.listingCount,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}