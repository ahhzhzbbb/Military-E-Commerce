class User {
  final String id;
  final String? email;
  final String? phone;
  final String? username;
  final String? avatar;
  final String? coverImage;
  final String? address;
  final String? city;
  final String? status;
  final String? fullname;
  final String? firstname;
  final String? lastname;
  final bool? followed;
  final bool? isBlocked;
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
    this.city,
    this.status,
    this.fullname,
    this.firstname,
    this.lastname,
    this.followed,
    this.isBlocked,
    this.followerCount,
    this.followingCount,
    this.listingCount,
    this.balance,
    this.createdAt,
  });

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'],
      phone: json['phone'] ?? json['phone_number'] ?? json['phonenumber'],
      username: json['username'] ?? json['name'],
      avatar: json['avatar'] ?? json['image'],
      coverImage: json['cover_image'] ?? json['cover_image_web'],
      address: json['address'],
      city: json['city'],
      status: json['status'],
      fullname: json['fullname'] ?? json['full_name'],
      firstname: json['firstname'] ?? json['first_name'],
      lastname: json['lastname'] ?? json['last_name'],
      followed: _toBool(json['followed']),
      isBlocked: _toBool(json['is_blocked']),
      followerCount: _toInt(json['follower_count']),
      followingCount: _toInt(json['following_count']),
      listingCount: _toInt(json['listing_count'] ?? json['listing']),
      balance:
          _toDouble(json['balance']) ??
          _toDouble(json['available_balance']) ??
          _toDouble(json['current_balance']),
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
      'city': city,
      'status': status,
      'fullname': fullname,
      'firstname': firstname,
      'lastname': lastname,
      'followed': followed,
      'is_blocked': isBlocked,
      'follower_count': followerCount,
      'following_count': followingCount,
      'listing_count': listingCount,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get displayName {
    if (fullname != null && fullname!.isNotEmpty) return fullname!;
    if (username != null && username!.isNotEmpty) return username!;
    return 'Người dùng';
  }

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? username,
    String? avatar,
    String? coverImage,
    String? address,
    String? city,
    String? status,
    String? fullname,
    String? firstname,
    String? lastname,
    bool? followed,
    bool? isBlocked,
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
      city: city ?? this.city,
      status: status ?? this.status,
      fullname: fullname ?? this.fullname,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      followed: followed ?? this.followed,
      isBlocked: isBlocked ?? this.isBlocked,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      listingCount: listingCount ?? this.listingCount,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
