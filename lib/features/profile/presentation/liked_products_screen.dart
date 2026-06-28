import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/core/constants/app_theme.dart';
import 'package:military_e_commerce/core/widgets/common_widgets.dart';
import 'package:military_e_commerce/models/product.dart';
import 'package:military_e_commerce/features/product/presentation/product_detail_screen.dart';

class LikedProductsScreen extends StatefulWidget {
  const LikedProductsScreen({super.key});

  @override
  State<LikedProductsScreen> createState() => _LikedProductsScreenState();
}

class _LikedProductsScreenState extends State<LikedProductsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  bool _hasMore = true;
  int _index = 0;
  static const int _count = 20;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _isLoading = true;
    _error = null;
    setState(() {});

    final response = await _apiClient.post(
      ApiConstants.getListProducts,
      body: {'index': _index, 'count': _count, 'is_liked': 1},
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
        if (_index == 0) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }
        _hasMore = newProducts.length >= _count;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = '${response.message} (Mã lỗi: ${response.code})';
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    _index = 0;
    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sản phẩm đã thích'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const ShimmerProductGrid()
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _onRefresh)
              : _products.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_border,
                      title: 'Chưa có sản phẩm yêu thích',
                      message: 'Hãy thả tim sản phẩm bạn yêu thích nhé!',
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.58,
                        ),
                        itemCount: _products.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _products.length) {
                            return const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          return _buildProductCard(_products[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildProductCard(Product product) {
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
}
