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

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static String? _mediaUrl(dynamic value) {
    if (value is Map) {
      for (final key in ['url', 'avatar', 'image', 'image_url']) {
        final text = _stringValue(value[key]);
        if (text != null) return text;
      }
      return null;
    }
    return _stringValue(value);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: _stringValue(json['email']),
      phone:
          _stringValue(json['phone']) ??
          _stringValue(json['phone_number']) ??
          _stringValue(json['phonenumber']),
      username: _stringValue(json['username']) ?? _stringValue(json['name']),
      avatar:
          _mediaUrl(json['avatar']) ??
          _mediaUrl(json['avatar_url']) ??
          _mediaUrl(json['image']),
      coverImage:
          _mediaUrl(json['cover_image']) ?? _mediaUrl(json['cover_image_web']),
      address: _stringValue(json['address']),
      city: _stringValue(json['city']),
      status: _stringValue(json['status']),
      fullname: _stringValue(json['fullname']) ?? _stringValue(json['full_name']),
      firstname:
          _stringValue(json['firstname']) ?? _stringValue(json['first_name']),
      lastname:
          _stringValue(json['lastname']) ?? _stringValue(json['last_name']),
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
    final firstLastName = [
      firstname,
      lastname,
    ].where((part) => part != null && part.isNotEmpty).join(' ');
    if (firstLastName.isNotEmpty) return firstLastName;
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
