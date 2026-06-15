import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../models/models.dart';

class ProductHeader extends StatelessWidget {
  final Product product;
  final bool isLiked;
  final int selectedImageIndex;
  final Function(int) onImageChanged;
  final VoidCallback onLikePressed;

  const ProductHeader({
    super.key,
    required this.product,
    required this.isLiked,
    required this.selectedImageIndex,
    required this.onImageChanged,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (product.images.isNotEmpty)
              PageView.builder(
                itemCount: product.images.length,
                onPageChanged: onImageChanged,
                itemBuilder: (context, index) {
                  return CustomNetworkImage(
                    imageUrl: product.images[index],
                    fit: BoxFit.cover,
                  );
                },
              )
            else
              Positioned.fill(
                child: CustomNetworkImage(
                  imageUrl: null,
                  fit: BoxFit.cover,
                ),
              ),
            if (product.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == selectedImageIndex
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
          ),
          onPressed: onLikePressed,
        ),
        IconButton(icon: const Icon(Icons.share), onPressed: () {}),
      ],
    );
  }
}
