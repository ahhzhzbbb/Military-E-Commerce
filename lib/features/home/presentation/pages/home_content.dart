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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

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
                _buildGreeting(context),
                const SizedBox(height: 12),
                const CompactBalanceBar(),
                const SizedBox(height: 14),
                PromoBanner(items: _bannerItems),
                const SizedBox(height: 20),
                const CategoriesSection(),
                const SizedBox(height: 20),
                const FeaturedSection(),
                const SizedBox(height: 20),
                const AllProductsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.user?.username ?? 'Chiến hữu';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, $name!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tìm kiếm trang bị tốt nhất cho bạn',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: auth.user?.avatar != null
                    ? ClipOval(
                        child: CustomNetworkImage(
                          imageUrl: auth.user!.avatar,
                          width: 44,
                          height: 44,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.primary,
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Tìm kiếm sản phẩm...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
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
      ],
    );
  }
}
