class Seller {
  // "seller": {
  //     "id": "22",
  //     "username": "0900000002",
  //     "avatar": "",
  //     "fullname": ""
  //   },
  final String id;
  final String username;
  final String? avatar;
  final String? fullname;
  Seller({
    required this.id,
    required this.username,
    this.avatar,
    this.fullname,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      fullname: json['fullname']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'fullname': fullname,
    };
  }
}