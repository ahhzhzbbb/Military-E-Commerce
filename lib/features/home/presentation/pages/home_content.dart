import 'package:flutter/material.dart';
import 'package:military_e_commerce/features/product/presentation/search_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../auth/data/auth_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/categories_section.dart';
import '../widgets/featured_section.dart';
import '../widgets/all_products_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const BalanceCard(),
                const SizedBox(height: 16),
                const CategoriesSection(),
                const SizedBox(height: 24),
                const FeaturedSection(),
                const SizedBox(height: 24),
                const AllProductsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.primary,
      title: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tìm kiếm sản phẩm...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: auth.user?.avatar != null
                    ? ClipOval(
                        child: CustomNetworkImage(
                          imageUrl: auth.user!.avatar,
                          width: 32,
                          height: 32,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
