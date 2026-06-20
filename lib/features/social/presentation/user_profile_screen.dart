import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_data.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/user.dart';
import '../../../models/product.dart';
import 'package:military_e_commerce/features/chat/presentation/conversation_list_screen.dart';
import '../../auth/data/auth_provider.dart';
import '../../product/presentation/product_detail_screen.dart';
import '../../profile/presentation/profile_edit_screen.dart';
import '../../social/data/follow_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  User? _user;
  bool _isLoading = true;
  String? _error;

  List<Product> _products = [];
  bool _isLoadingProducts = true;
  int _productIndex = 0;
  static const int _productCount = 20;
  bool _hasMoreProducts = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userId = int.tryParse(widget.userId) ?? widget.userId;
    final response = await _apiClient.post(
      ApiConstants.getUserInfo,
      body: {'user_id': userId},
      requiresAuth: true,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      final map = ApiData.mapFrom(response.data, ['user', 'profile']);
      setState(() {
        _user = map != null ? User.fromJson(map) : User.fromJson(response.data is Map<String, dynamic> ? response.data : <String, dynamic>{});
        _isLoading = false;
      });
      if (_user?.followed != null) {
        context.read<FollowProvider>().setFollowStatus(widget.userId, _user!.followed!);
      }
      _loadProducts();
    } else {
      setState(() {
        _error = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    final userId = int.tryParse(widget.userId);
    if (userId == null) {
      setState(() => _isLoadingProducts = false);
      return;
    }

    final response = await _apiClient.post(
      ApiConstants.getUserListings,
      body: {
        'user_id': userId,
        'index': _productIndex,
        'count': _productCount,
      },
      requiresAuth: true,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      final list = ApiData.asList(response.data, []);
      final newProducts = list
          .whereType<Map>()
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      setState(() {
        if (_productIndex == 0) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }
        _hasMoreProducts = newProducts.length >= _productCount;
        _isLoadingProducts = false;
      });
    } else {
      setState(() => _isLoadingProducts = false);
    }
  }

  void _loadMoreProducts() {
    if (_isLoadingProducts || !_hasMoreProducts) return;
    _productIndex++;
    _loadProducts();
  }

  Future<void> _toggleFollow() async {
    final followProvider = context.read<FollowProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await followProvider.toggleFollow(widget.userId);
    if (!mounted) return;
    if (success) {
      final isFollowing = followProvider.isFollowing(widget.userId);
      messenger.showSnackBar(
        SnackBar(
          content: Text(isFollowing ? 'Đã theo dõi' : 'Đã bỏ theo dõi'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      _loadUserProfile();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Thao tác thất bại'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _toggleBlock() async {
    final followProvider = context.read<FollowProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await followProvider.toggleBlock(widget.userId);
    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(followProvider.blocked.any((u) => u.id == widget.userId) ? 'Đã chặn' : 'Đã bỏ chặn'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      _loadUserProfile();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Thao tác thất bại'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const ShimmerUserProfile()
          : _error != null
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: 'Không thể tải trang cá nhân',
                  message: _error,
                  buttonText: 'Thử lại',
                  onButtonPressed: _loadUserProfile,
                )
              : _buildProfile(),
    );
  }

  Widget _buildProfile() {
    final user = _user!;
    final followProvider = context.watch<FollowProvider>();
    final isFollowed = followProvider.isFollowing(widget.userId);
    final isBlocked = followProvider.blocked.any((u) => u.id == widget.userId);
    final currentUser = context.read<AuthProvider>().user;
    final isOwnProfile = currentUser?.id == widget.userId;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: Container(
            margin: const EdgeInsets.only(left: 8, top: 8),
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          actions: [
            if (!isOwnProfile)
              PopupMenuButton<String>(
                icon: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'block') _toggleBlock();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(isBlocked ? Icons.lock_open_outlined : Icons.block, color: isBlocked ? AppColors.success : AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(isBlocked ? 'Bỏ chặn' : 'Chặn người dùng', style: TextStyle(color: isBlocked ? AppColors.success : AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (user.coverImage != null && user.coverImage!.isNotEmpty)
                  CustomNetworkImage(imageUrl: user.coverImage, fit: BoxFit.cover)
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryLight,
                          child: user.avatar != null && user.avatar!.isNotEmpty
                              ? ClipOval(child: CustomNetworkImage(imageUrl: user.avatar, width: 80, height: 80))
                              : const Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                            ),
                          ),
                          if (user.status != null && user.status!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text(user.status!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (isOwnProfile)
                _buildOwnProfileActions()
              else
                _buildActionRow(isFollowed),
              _buildStatsRow(user),
              _buildInfoSection(user),
              _buildProductsSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnProfileActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            );
            _loadUserProfile();
          },
          icon: const Icon(Icons.edit_outlined, size: 20),
          label: const Text('Chỉnh sửa trang cá nhân'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(bool isFollowed) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: isFollowed
                ? OutlinedButton.icon(
                    onPressed: _toggleFollow,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Đang theo dõi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _toggleFollow,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Theo dõi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      partnerId: int.tryParse(widget.userId),
                      partnerName: _user?.displayName,
                      partnerAvatar: _user?.avatar,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Nhắn tin'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(User user) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Sản phẩm', user.listingCount ?? 0, Icons.store_outlined)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(child: _buildStatItem('Theo dõi', user.followingCount ?? 0, Icons.person_add_outlined)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(child: _buildStatItem('Người theo dõi', user.followerCount ?? 0, Icons.people_outline)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInfoSection(User user) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              const Text('Thông tin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          if (user.address != null && user.address!.isNotEmpty)
            _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ', user.address!),
          if (user.city != null && user.city!.isNotEmpty)
            _buildInfoRow(Icons.location_city_outlined, 'Thành phố', user.city!),
          if (user.email != null && user.email!.isNotEmpty)
            _buildInfoRow(Icons.email_outlined, 'Email', user.email!),
          if (user.phone != null && user.phone!.isNotEmpty)
            _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', user.phone!),
          if (user.createdAt != null)
            _buildInfoRow(Icons.calendar_today_outlined, 'Ngày tham gia', _formatDate(user.createdAt!)),
          if (user.address == null && user.city == null && user.email == null && user.phone == null && user.createdAt == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 40, color: AppColors.textHint),
                    const SizedBox(height: 8),
                    const Text('Không có thông tin hiển thị', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text(
                'Sản phẩm đang bán (${_products.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingProducts && _products.isEmpty)
            const ShimmerProductGrid()
          else if (_products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.store_outlined, size: 40, color: AppColors.textHint),
                    const SizedBox(height: 8),
                    const Text('Chưa có sản phẩm nào', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: _products.length + (_hasMoreProducts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _products.length) {
                  _loadMoreProducts();
                  return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
                }
                return _buildListingProductCard(_products[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildListingProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomNetworkImage(
                      imageUrl: product.images.isNotEmpty ? product.images.first : null,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: AppColors.error.withValues(alpha: 0.6)),
                      const SizedBox(width: 2),
                      Text('${product.likeCount}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Text('${product.commentCount}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  PriceDisplay(
                    price: product.effectivePrice,
                    originalPrice: product.hasDiscount ? product.price : null,
                    showDiscountPercent: false,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    originalStyle: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
