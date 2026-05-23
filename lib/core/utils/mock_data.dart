import 'dart:math';
import '../../models/models.dart';

class MockData {
  static final Random _random = Random();

  static final List<String> _militaryCategories = [
    'Vũ khí cá nhân',
    'Thiết bị связи',
    'Phương tiện di chuyển',
    'Đồ y tế quân sự',
    'Bảo hộ cá nhân',
    'Dụng cụ huấn luyện',
    'Vật tư chiến đấu',
    'Thiết bị trinh sát',
  ];

  static final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'title': 'Súng AK-47',
      'description': 'Súng trường tấn công AK-47, hiệu năng cao, độ tin cậy tuyệt đối trong mọi điều kiện thời tiết.',
      'price': 50000.0,
      'original_price': 65000.0,
      'images': [
        'https://picsum.photos/seed/ak47/400/400',
        'https://picsum.photos/seed/ak47b/400/400',
      ],
      'category_id': '1',
      'category_name': 'Vũ khí cá nhân',
      'brand_id': '1',
      'brand_name': 'Kalashnikov',
      'stock': 50,
      'sold_count': 234,
      'like_count': 567,
      'rating_average': 4.8,
      'rating_count': 89,
      'seller_id': '1',
      'seller_name': 'Hải quân Việt Nam',
      'seller_avatar': 'https://i.pravatar.cc/150?img=1',
      'condition': 'new',
      'ship_from': '1',
      'ship_from_name': 'Hà Nội',
    },
    {
      'id': '2',
      'title': 'Kính夜视仪 NV-7000',
      'description': 'Kính夜视仪 hồng ngoại thế hệ mới, tầm nhìn đêm lên đến 500m.',
      'price': 35000.0,
      'images': [
        'https://picsum.photos/seed/nv7000/400/400',
      ],
      'category_id': '8',
      'category_name': 'Thiết bị trinh sát',
      'brand_id': '2',
      'brand_name': 'ATN Corp',
      'stock': 30,
      'sold_count': 156,
      'like_count': 345,
      'rating_average': 4.6,
      'rating_count': 67,
      'seller_id': '2',
      'seller_name': 'Công ty TNHH Thiết bị Quân sự ABC',
      'seller_avatar': 'https://i.pravatar.cc/150?img=2',
      'condition': 'new',
      'ship_from': '2',
      'ship_from_name': 'TP. Hồ Chí Minh',
    },
    {
      'id': '3',
      'title': 'Áo chống đạn Level IIIA',
      'description': 'Áo chống đạn đạt chuẩn quân đội, chống được đạn 9mm và .44 Magnum.',
      'price': 25000.0,
      'original_price': 30000.0,
      'images': [
        'https://picsum.photos/seed/armor/400/400',
      ],
      'category_id': '5',
      'category_name': 'Bảo hộ cá nhân',
      'brand_id': '3',
      'brand_name': ' ballistic Protection',
      'stock': 100,
      'sold_count': 456,
      'like_count': 890,
      'rating_average': 4.9,
      'rating_count': 234,
      'seller_id': '3',
      'seller_name': 'Công ty Bảo hộ Quốc phòng XYZ',
      'seller_avatar': 'https://i.pravatar.cc/150?img=3',
      'condition': 'new',
      'ship_from': '1',
      'ship_from_name': 'Hà Nội',
    },
    {
      'id': '4',
      'title': 'Máy связи Motorola GP-338',
      'description': 'Máy联系 đa tần số, bán kính liên lạc lên đến 10km.',
      'price': 12000.0,
      'images': [
        'https://picsum.photos/seed/gp338/400/400',
      ],
      'category_id': '2',
      'category_name': 'Thiết bị связи',
      'brand_id': '4',
      'brand_name': 'Motorola',
      'stock': 200,
      'sold_count': 789,
      'like_count': 1234,
      'rating_average': 4.7,
      'rating_count': 456,
      'seller_id': '4',
      'seller_name': 'Công ty Điện tử Viễn thông Quân đội',
      'seller_avatar': 'https://i.pravatar.cc/150?img=4',
      'condition': 'new',
      'ship_from': '3',
      'ship_from_name': 'Đà Nẵng',
    },
    {
      'id': '5',
      'title': 'Ô tô tuần tra Toyota Hilux',
      'description': 'Xe ô tô tuần tra bọc thép, chống đạn cấp B4.',
      'price': 150000.0,
      'original_price': 180000.0,
      'images': [
        'https://picsum.photos/seed/hilux/400/400',
      ],
      'category_id': '3',
      'category_name': 'Phương tiện di chuyển',
      'brand_id': '5',
      'brand_name': 'Toyota',
      'stock': 10,
      'sold_count': 45,
      'like_count': 234,
      'rating_average': 4.5,
      'rating_count': 23,
      'seller_id': '5',
      'seller_name': 'Công ty Ô tô Quân đội',
      'seller_avatar': 'https://i.pravatar.cc/150?img=5',
      'condition': 'new',
      'ship_from': '1',
      'ship_from_name': 'Hà Nội',
    },
    {
      'id': '6',
      'title': 'Bộ sơ cứu ban đầu Quân y',
      'description': 'Bộ sơ cứu y tế quân đội, bao gồm băng, thuốc, dụng cụ cầm máu.',
      'price': 3000.0,
      'images': [
        'https://picsum.photos/seed/medkit/400/400',
      ],
      'category_id': '4',
      'category_name': 'Đồ y tế quân sự',
      'brand_id': '6',
      'brand_name': 'Quân y Việt Nam',
      'stock': 500,
      'sold_count': 2345,
      'like_count': 5678,
      'rating_average': 4.9,
      'rating_count': 1234,
      'seller_id': '1',
      'seller_name': 'Hải quân Việt Nam',
      'seller_avatar': 'https://i.pravatar.cc/150?img=1',
      'condition': 'new',
      'ship_from': '1',
      'ship_from_name': 'Hà Nội',
    },
    {
      'id': '7',
      'title': 'Kíp nổ bắn tốc độ cao',
      'description': 'Kíp nổ chính xác cao, sử dụng trong các thiết bị взрыв.',
      'price': 8000.0,
      'images': [
        'https://picsum.photos/seed/detonator/400/400',
      ],
      'category_id': '7',
      'category_name': 'Vật tư chiến đấu',
      'brand_id': '7',
      'brand_name': 'Vật liệu взрывчатые',
      'stock': 1000,
      'sold_count': 567,
      'like_count': 890,
      'rating_average': 4.8,
      'rating_count': 234,
      'seller_id': '6',
      'seller_name': 'Công ty Vật liệu взрывчатые Quốc phòng',
      'seller_avatar': 'https://i.pravatar.cc/150?img=6',
      'condition': 'new',
      'ship_from': '4',
      'ship_from_name': 'Hải Phòng',
    },
    {
      'id': '8',
      'title': 'Bia móc phục vụ huấn luyện',
      'description': 'Bia móc phục vụ huấn luyện bắn súng, nhiều loại kích thước.',
      'price': 500.0,
      'images': [
        'https://picsum.photos/seed/target/400/400',
      ],
      'category_id': '6',
      'category_name': 'Dụng cụ huấn luyện',
      'brand_id': '8',
      'brand_name': 'Training Pro',
      'stock': 2000,
      'sold_count': 7890,
      'like_count': 12345,
      'rating_average': 4.4,
      'rating_count': 3456,
      'seller_id': '7',
      'seller_name': 'Công ty Dụng cụ Huấn luyện',
      'seller_avatar': 'https://i.pravatar.cc/150?img=7',
      'condition': 'new',
      'ship_from': '2',
      'ship_from_name': 'TP. Hồ Chí Minh',
    },
  ];

  static List<Category> getCategories() {
    return List.generate(_militaryCategories.length, (index) {
      return Category(
        id: '${index + 1}',
        name: _militaryCategories[index],
        image: 'https://picsum.photos/seed/cat${index + 1}/200/200',
        productCount: _random.nextInt(500) + 100,
      );
    });
  }

  static List<Product> getProducts({
    String? categoryId,
    String? keyword,
    int page = 0,
    int limit = 20,
  }) {
    var products = _mockProducts.map((p) => Product.fromJson(p)).toList();

    if (categoryId != null) {
      products = products.where((p) => p.categoryId == categoryId).toList();
    }

    if (keyword != null && keyword.isNotEmpty) {
      products = products.where((p) =>
          p.title.toLowerCase().contains(keyword.toLowerCase()) ||
          (p.description?.toLowerCase().contains(keyword.toLowerCase()) ?? false)).toList();
    }

    final start = page * limit;
    if (start >= products.length) return [];
    final end = (start + limit > products.length) ? products.length : start + limit;

    return products.sublist(start, end);
  }

  static Product? getProduct(String id) {
    try {
      final productData = _mockProducts.firstWhere((p) => p['id'] == id);
      return Product.fromJson(productData);
    } catch (e) {
      return null;
    }
  }

  static User getMockUser() {
    return User(
      id: 'user_001',
      username: 'Nguyễn Văn A',
      email: 'nguyenvana@mil.gov.vn',
      phone: '0123456789',
      avatar: 'https://i.pravatar.cc/150?img=10',
      address: 'Hà Nội, Việt Nam',
      followerCount: 1234,
      followingCount: 567,
      listingCount: 45,
      balance: 500000,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  static WalletBalance getMockBalance() {
    return WalletBalance(
      availableBalance: 450000,
      pendingBalance: 50000,
    );
  }

  static List<Order> getMockOrders() {
    return [
      Order(
        id: 'order_001',
        buyerId: 'user_001',
        sellerId: '1',
        sellerName: 'Hải quân Việt Nam',
        items: [
          OrderItem(
            id: 'item_001',
            productId: '1',
            productTitle: 'Súng AK-47',
            productImage: 'https://picsum.photos/seed/ak47/400/400',
            price: 50000,
            quantity: 2,
          ),
        ],
        shippingAddress: OrderAddress(
          id: 'addr_001',
          name: 'Nguyễn Văn A',
          phone: '0123456789',
          address: 'Số 10, Đường Trần Hưng Đạo',
          provinceName: 'Hà Nội',
          districtName: 'Quận Hoàn Kiếm',
          wardName: 'Phường Cửa Nam',
        ),
        subtotal: 100000,
        shippingFee: 5000,
        total: 105000,
        status: 'delivered',
        statusName: 'Đã giao hàng',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Order(
        id: 'order_002',
        buyerId: 'user_001',
        sellerId: '2',
        sellerName: 'Công ty TNHH Thiết bị Quân sự ABC',
        items: [
          OrderItem(
            id: 'item_002',
            productId: '2',
            productTitle: 'Kính夜视仪 NV-7000',
            productImage: 'https://picsum.photos/seed/nv7000/400/400',
            price: 35000,
            quantity: 1,
          ),
        ],
        shippingAddress: OrderAddress(
          id: 'addr_001',
          name: 'Nguyễn Văn A',
          phone: '0123456789',
          address: 'Số 10, Đường Trần Hưng Đạo',
          provinceName: 'Hà Nội',
          districtName: 'Quận Hoàn Kiếm',
          wardName: 'Phường Cửa Nam',
        ),
        subtotal: 35000,
        shippingFee: 3000,
        total: 38000,
        status: 'shipping',
        statusName: 'Đang vận chuyển',
        trackingNumber: 'VN123456789',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Order(
        id: 'order_003',
        buyerId: 'user_001',
        sellerId: '3',
        sellerName: 'Công ty Bảo hộ Quốc phòng XYZ',
        items: [
          OrderItem(
            id: 'item_003',
            productId: '3',
            productTitle: 'Áo chống đạn Level IIIA',
            productImage: 'https://picsum.photos/seed/armor/400/400',
            price: 25000,
            quantity: 1,
          ),
        ],
        shippingAddress: OrderAddress(
          id: 'addr_001',
          name: 'Nguyễn Văn A',
          phone: '0123456789',
          address: 'Số 10, Đường Trần Hưng Đạo',
          provinceName: 'Hà Nội',
          districtName: 'Quận Hoàn Kiếm',
          wardName: 'Phường Cửa Nam',
        ),
        subtotal: 25000,
        shippingFee: 2000,
        total: 27000,
        status: 'pending',
        statusName: 'Chờ xác nhận',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  static List<Comment> getMockComments(String productId) {
    return [
      Comment(
        id: 'c1',
        productId: productId,
        userId: 'u1',
        userName: 'Trần Văn B',
        userAvatar: 'https://i.pravatar.cc/150?img=11',
        content: 'Sản phẩm chất lượng tốt, giao hàng nhanh!',
        likeCount: 45,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Comment(
        id: 'c2',
        productId: productId,
        userId: 'u2',
        userName: 'Lê Thị C',
        userAvatar: 'https://i.pravatar.cc/150?img=12',
        content: 'Đã mua và sử dụng được 3 tháng, rất hài lòng.',
        likeCount: 23,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Comment(
        id: 'c3',
        productId: productId,
        userId: 'u3',
        userName: 'Phạm Văn D',
        userAvatar: 'https://i.pravatar.cc/150?img=13',
        content: 'Giá cả hợp lý, đáng để mua.',
        likeCount: 12,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}