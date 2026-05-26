import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../cart/data/cart_provider.dart';
import 'controllers/product_detail_controller.dart';
import 'widgets/product_header.dart';
import 'widgets/product_info_section.dart';
import 'widgets/seller_info_widget.dart';
import 'widgets/product_tabs_widget.dart';
import 'widgets/product_bottom_bar.dart';

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
        const SnackBar(
          content: Text('Thao tác thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {});
  }

  void _addToCart() {
    if (_controller.product == null) return;

    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(product: _controller.product!, quantity: _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${_controller.product!.name}" vào giỏ hàng'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
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
        body: LoadingIndicator(message: 'Đang tải thông tin sản phẩm...'),
      );
    }

    if (_controller.product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Không tìm thấy sản phẩm',
          message:
              _controller.error ?? 'Sản phẩm này có thể đã bị xóa hoặc không tồn tại.',
        ),
      );
    }

    final product = _controller.product!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ProductHeader(
            product: product,
            isLiked: _controller.isLiked,
            selectedImageIndex: _selectedImageIndex,
            onImageChanged: (index) => setState(() => _selectedImageIndex = index),
            onLikePressed: _toggleLike,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ProductInfoSection(product: product),
                const Divider(height: 1),
                SellerInfoWidget(product: product),
                const Divider(height: 1),
                ProductTabsWidget(
                  product: product,
                  comments: _controller.comments,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductBottomBar(
        product: product,
        onAddToCart: _addToCart,
        onBuyNow: _buyNow,
        onQuantityChanged: (quantity) => setState(() => _quantity = quantity),
      ),
    );
  }
}
