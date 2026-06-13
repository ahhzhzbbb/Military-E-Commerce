import 'package:flutter/material.dart';
import 'package:military_e_commerce/features/product/presentation/search_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../notifications/data/notification_provider.dart';
import '../../../notifications/presentation/notification_screen.dart';
import '../widgets/compact_balance_bar.dart';
import '../widgets/promo_banner.dart';
import '../widgets/categories_section.dart';
import '../widgets/featured_section.dart';
import '../widgets/all_products_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  static const _bannerItems = [
    BannerItem(
      title: 'Flash Sale',
      subtitle: 'Giảm đến 50% - Chỉ hôm nay!',
      badge: 'HOT',
      icon: Icons.bolt,
      gradientColors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
    ),
    BannerItem(
      title: 'Hàng mới về',
      subtitle: 'Cập nhật trang bị mới nhất',
      badge: 'MỚI',
      icon: Icons.new_releases,
      gradientColors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    ),
    BannerItem(
      title: 'Ưu đãi thành viên',
      subtitle: 'Tích xu đổi quà hấp dẫn',
      badge: 'VIP',
      icon: Icons.card_giftcard,
      gradientColors: [AppColors.primary, AppColors.primaryLight],
    ),
  ];

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
                const SizedBox(height: 12),
                const CompactBalanceBar(),
                const SizedBox(height: 12),
                PromoBanner(items: _bannerItems),
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
        Consumer<NotificationProvider>(
          builder: (context, notifProvider, child) {
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  if (notifProvider.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${notifProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            );
          },
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
