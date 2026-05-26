import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../models/models.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildDiscountBadge(),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          // const SizedBox(height: 8),
          // _buildRatingRow(),
          const SizedBox(height: 16),
          _buildPriceRow(),
          const SizedBox(height: 16),
          _buildDetailsRows(),
        ],
      ),
    );
  }

  // Widget _buildDiscountBadge() {
  //   if (!product.hasDiscount) return const SizedBox.shrink();
    
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: AppColors.error,
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     child: Text(
  //       'Giảm ${product.discountPercentage.toStringAsFixed(0)}%',
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 12,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildRatingRow() {
  //   return Row(
  //     children: [
  //       if (product.ratingAverage != null) ...[
  //         RatingStars(rating: product.ratingAverage!),
  //         const SizedBox(width: 8),
  //         Text(
  //           '${product.ratingAverage!.toStringAsFixed(1)} (${product.ratingCount} đánh giá)',
  //           style: const TextStyle(color: AppColors.textSecondary),
  //         ),
  //         const SizedBox(width: 16),
  //       ],
  //       Text(
  //         'Đã bán ${product.soldCount ?? 0}',
  //         style: const TextStyle(color: AppColors.textSecondary),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PriceDisplay(
          price: product.price,
          originalPrice: product.price,
          showDiscountPercent: true,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '/ cái',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDetailsRows() {
    return Column(
      children: [
        _buildInfoRow('Danh mục', product.category?.name ?? 'N/A'),
        _buildInfoRow('Thương hiệu', product.brand?.name ?? 'N/A'),
        _buildInfoRow(
          'Tình trạng',
          // product.condition == 'new' ? 'Mới' : 'Đã sử dụng',
          'Mới',
        ),
        // _buildInfoRow('Kho hàng', '${product.stock ?? 0} sản phẩm'),
        // _buildInfoRow('Gửi từ', product.shipFromName ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
