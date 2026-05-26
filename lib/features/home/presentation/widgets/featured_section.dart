import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../models/models.dart';
import '../../data/product_provider.dart';
import '../../../product/presentation/product_detail_screen.dart';

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản phẩm nổi bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.featuredProducts.length,
                itemBuilder: (context, index) {
                  return _FeaturedProductItem(
                    product: provider.featuredProducts[index],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedProductItem extends StatelessWidget {
  final Product product;

  const _FeaturedProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNetworkImage(
                imageUrl: product.images.isNotEmpty
                    ? product.images.first
                    : 'https://upload.wikimedia.org/wikipedia/en/8/8e/%C4%90%E1%BA%A1i_h%E1%BB%8Dc_B%C3%A1ch_khoa_H%C3%A0_N%E1%BB%99i_%28logo%29.png',
                height: 120,
                width: double.infinity,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    PriceDisplay(
                      price: product.price,
                      originalPrice: product.price,
                      // showDiscountPercent: product.hasDiscount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
