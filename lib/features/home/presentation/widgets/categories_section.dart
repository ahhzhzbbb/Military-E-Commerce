import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../models/models.dart';
import '../../data/product_provider.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const _categoryIcons = {
    'quần áo': Icons.checkroom,
    'áo': Icons.checkroom,
    'quần': Icons.checkroom,
    'giày': Icons.hiking,
    'dép': Icons.hiking,
    'balo': Icons.backpack,
    'túi': Icons.work,
    'mũ': Icons.heat_pump,
    'nón': Icons.heat_pump,
    'điện thoại': Icons.phone_android,
    'laptop': Icons.laptop,
    'máy tính': Icons.computer,
    'tablet': Icons.tablet,
    'phụ kiện': Icons.headset,
    'đồng hồ': Icons.watch,
    'sách': Icons.menu_book,
    'thực phẩm': Icons.restaurant,
    'đồ ăn': Icons.fastfood,
    'thức uống': Icons.local_cafe,
    'cơm': Icons.rice_bowl,
    'vũ khí': Icons.gavel,
    'đồ chiến': Icons.shield,
    'kỹ thuật': Icons.engineering,
    'viễn thông': Icons.settings_input_antenna,
    'y tế': Icons.medical_services,
    'sức khỏe': Icons.favorite,
    'thể thao': Icons.sports_soccer,
    'nhà cửa': Icons.home,
    'đồ gia dụng': Icons.kitchen,
    'xe': Icons.directions_car,
    'ô tô': Icons.directions_car,
    'xe máy': Icons.two_wheeler,
    'đồ chơi': Icons.toys,
    'trẻ em': Icons.child_care,
    'mỹ phẩm': Icons.face,
    'làm đẹp': Icons.spa,
  };

  IconData _getIcon(String name) {
    final lower = name.toLowerCase();
    for (final entry in _categoryIcons.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Danh mục',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }
            return SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  final isSelected = provider.selectedCategoryId == category.id;
                  return _CategoryChip(
                    category: category,
                    isSelected: isSelected,
                    icon: _getIcon(category.name),
                    onTap: () {
                      if (isSelected) {
                        provider.clearCategoryFilter();
                      } else {
                        provider.loadProducts(categoryId: category.id);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomNetworkImage(
                        imageUrl: category.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      icon,
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 26,
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
