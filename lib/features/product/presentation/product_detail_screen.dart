import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/models.dart';
import '../../cart/data/cart_provider.dart';
import '../../social/data/follow_provider.dart';
import 'controllers/product_detail_controller.dart';
import 'product_reviews_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductDetailController _controller;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _controller = ProductDetailController();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    await _controller.loadProduct(widget.productId.toString());
    if (mounted) setState(() {});
  }

  Future<void> _toggleLike() async {
    final success = await _controller.toggleLike(widget.productId.toString());
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thao tác thất bại'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() {});
  }

  Future<void> _toggleFollow(String sellerId) async {
    final followProvider = context.read<FollowProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await followProvider.toggleFollow(sellerId);
    if (!mounted) return;
    if (success) {
      final isFollowing = followProvider.isFollowing(sellerId);
      messenger.showSnackBar(
        SnackBar(
          content: Text(isFollowing ? 'Đã theo dõi' : 'Đã bỏ theo dõi'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Theo dõi thất bại'), backgroundColor: AppColors.error),
      );
    }
  }

  void _addToCart() {
    if (_controller.product == null) return;
    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(product: _controller.product!, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${_controller.product!.name}" vào giỏ hàng'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Xem giỏ',
          textColor: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _buyNow() {
    _addToCart();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingIndicator(message: 'Đang tải thông tin sản phẩm...'),
      );
    }

    if (_controller.product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Không tìm thấy sản phẩm',
          message: _controller.error ?? 'Sản phẩm này có thể đã bị xóa hoặc không tồn tại.',
          buttonText: 'Thử lại',
          onButtonPressed: _loadProduct,
        ),
      );
    }

    final product = _controller.product!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildImageHeader(product),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(product),
                const SizedBox(height: 8),
                _buildSellerRow(product),
                const SizedBox(height: 8),
                _buildDescriptionBlock(product),
                const SizedBox(height: 8),
                _buildCommentsBlock(product),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(product),
    );
  }

  Widget _buildImageHeader(Product product) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: Colors.white,
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
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            child: IconButton(
              icon: Icon(
                _controller.isLiked ? Icons.favorite : Icons.favorite_border,
                color: _controller.isLiked ? Colors.red : Colors.white,
                size: 20,
              ),
              onPressed: _toggleLike,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (product.images.isNotEmpty)
              PageView.builder(
                itemCount: product.images.length,
                onPageChanged: (index) => setState(() => _selectedImageIndex = index),
                itemBuilder: (context, index) {
                  return CustomNetworkImage(
                    imageUrl: product.images[index],
                    fit: BoxFit.cover,
                  );
                },
              )
            else
              CustomNetworkImage(imageUrl: null, fit: BoxFit.cover),
            if (product.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: index == _selectedImageIndex ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: index == _selectedImageIndex
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            if (product.images.length > 1)
              Positioned(
                top: 52,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedImageIndex + 1}/${product.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 24,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    final ratingCount = product.ratingCount ?? 0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              const SizedBox(width: 2),
              if (ratingCount > 0) ...[
                Text('$ratingCount đánh giá', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 14, color: AppColors.divider),
              ],
              Icon(Icons.favorite, size: 14, color: AppColors.error.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text('${product.likeCount}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 14, color: AppColors.divider),
              Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('${product.commentCount}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              PriceDisplay(
                price: product.effectivePrice,
                originalPrice: product.hasDiscount ? product.price : null,
                showDiscountPercent: true,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                originalStyle: const TextStyle(fontSize: 14, color: AppColors.textHint, decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: 6),
              Text('/ cái', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              if (product.hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Tiết kiệm ${(product.price - product.effectivePrice).toStringAsFixed(0)} xu',
                    style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                _buildInfoRow(Icons.category_outlined, 'Danh mục', product.category?.name ?? 'N/A'),
                _buildInfoRow(Icons.branding_watermark_outlined, 'Thương hiệu', product.brand?.name ?? 'N/A'),
                _buildInfoRow(Icons.verified_outlined, 'Tình trạng', 'Mới'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSellerRow(Product product) {
    final sellerId = product.seller?.id ?? product.sellerId ?? '';
    final sellerName = product.seller?.fullname?.isNotEmpty == true
        ? product.seller!.fullname!
        : product.seller?.username ?? 'Cửa hàng quân sự';
    final sellerAvatar = product.seller?.avatar;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
              child: sellerAvatar != null && sellerAvatar.isNotEmpty
                  ? ClipOval(child: CustomNetworkImage(imageUrl: sellerAvatar, width: 48, height: 48))
                  : const Icon(Icons.store_outlined, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sellerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildBadge(Icons.shield_outlined, 'Chính hãng', AppColors.success),
                    const SizedBox(width: 6),
                    _buildBadge(Icons.verified_user_outlined, 'Yên tâm', AppColors.info),
                  ],
                ),
              ],
            ),
          ),
          if (sellerId.isNotEmpty)
            Consumer<FollowProvider>(
              builder: (context, followProvider, _) {
                final isFollowed = followProvider.isFollowing(sellerId);
                final isLoading = followProvider.isLoading;
                return SizedBox(
                  height: 38,
                  child: isFollowed
                      ? OutlinedButton.icon(
                          onPressed: isLoading ? null : () => _toggleFollow(sellerId),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Đang theo dõi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: isLoading ? null : () => _toggleFollow(sellerId),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Theo dõi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                );
              },
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildDescriptionBlock(Product product) {
    return Container(
      color: Colors.white,
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
              const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.described ?? 'Không có mô tả cho sản phẩm này.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsBlock(Product product) {
    final comments = _controller.comments;
    return Container(
      color: Colors.white,
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
              const Expanded(
                child: Text('Bình luận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              if (comments.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductReviewsScreen(
                          productId: product.id.toString(),
                          sellerId: product.seller?.id ?? product.sellerId ?? '',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Xem tất cả'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 40, color: AppColors.textHint),
                    const SizedBox(height: 8),
                    const Text('Chưa có bình luận nào', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            ...comments.take(3).map((comment) => _buildCommentItem(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: comment.userAvatar != null
                ? ClipOval(child: CustomNetworkImage(imageUrl: comment.userAvatar, width: 36, height: 36))
                : const Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userName ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    if (comment.isLiked == true) const Icon(Icons.favorite, size: 14, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                const SizedBox(height: 4),
                Text(_formatDate(comment.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  Widget _buildBottomBar(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _buildQuantitySelector(),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                  label: const Text('Thêm giỏ hàng'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _buyNow,
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text('Mua ngay'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: const Icon(Icons.remove, size: 16),
              onPressed: _quantity > 1 ? () => _updateQuantity(_quantity - 1) : null,
              color: AppColors.textPrimary,
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _updateQuantity(_quantity + 1),
              color: AppColors.textPrimary,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int value) {
    setState(() => _quantity = value);
  }
}
