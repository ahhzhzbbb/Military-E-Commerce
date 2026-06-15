import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../models/models.dart';
import '../../../social/data/follow_provider.dart';

class SellerInfoWidget extends StatelessWidget {
  final Product product;

  const SellerInfoWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final sellerId = product.seller?.id ?? product.sellerId ?? '';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: product.seller?.avatar != null
                ? ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: product.seller?.avatar,
                      width: 48,
                      height: 48,
                    ),
                  )
                : const Icon(Icons.store, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.seller?.username ?? 'Cửa hàng',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildBadge('Chính hãng', AppColors.success),
                    const SizedBox(width: 8),
                    _buildBadge('Yên tâm', AppColors.info),
                  ],
                ),
              ],
            ),
          ),
          if (sellerId.isNotEmpty)
            Consumer<FollowProvider>(
              builder: (context, followProvider, child) {
                final isFollowed = followProvider.isFollowing(sellerId);
                return OutlinedButton(
                  onPressed: () => followProvider.toggleFollow(sellerId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isFollowed ? AppColors.textSecondary : AppColors.primary,
                    side: BorderSide(
                      color: isFollowed ? AppColors.divider : AppColors.primary,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(isFollowed ? 'Đang theo dõi' : 'Theo dõi'),
                );
              },
            )
          else
            const OutlinedButton(onPressed: null, child: Text('Theo dõi')),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
