import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/social.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../data/notification_provider.dart';
import '../../../features/product/presentation/product_detail_screen.dart';
import '../../../features/social/presentation/user_profile_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () => _markAllAsRead(provider),
                  child: const Text(
                    'Đọc tất cả',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return _buildShimmerList();
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: () => provider.loadNotifications(),
            );
          }

          if (provider.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Không có thông báo',
              message: 'Bạn sẽ nhận được thông báo khi có hoạt động mới',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.loadNotifications(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.notifications.length) {
                  return _buildLoadMoreIndicator(provider);
                }
                final notification = provider.notifications[index];
                final prevUnread = index > 0
                    ? !provider.notifications[index - 1].isRead
                    : null;
                final isUnread = !notification.isRead;
                final showDivider = index == 0 ||
                    (prevUnread != null && prevUnread != isUnread);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDivider && isUnread && (index == 0 || (prevUnread != null && !prevUnread)))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                        child: Text(
                          'Mới',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (showDivider && !isUnread && prevUnread != null && prevUnread)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                        child: Text(
                          'Trước đó',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    _buildNotificationCard(provider, notification, index),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationProvider provider, AppNotification notification, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.cardBackground : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!notification.isRead) {
              provider.markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(notification),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      if (notification.message != null && notification.message!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.message!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _getNotificationIcon(notification.type),
                            size: 13,
                            color: _getNotificationColor(notification.type),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getNotificationLabel(notification.type),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getNotificationColor(notification.type),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (notification.createdAt != null)
                            Text(
                              _formatTime(notification.createdAt!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AppNotification notification) {
    if (notification.avatar != null && notification.avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.divider,
        child: ClipOval(
          child: CustomNetworkImage(
            imageUrl: notification.avatar,
            width: 44,
            height: 44,
          ),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getNotificationColor(notification.type).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getNotificationIcon(notification.type),
        color: _getNotificationColor(notification.type),
        size: 22,
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    if (notification.productId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: notification.productId!),
        ),
      );
    } else if (notification.objectId != null) {
      final type = notification.type.toLowerCase();
      if (type == 'follow') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: notification.objectId.toString()),
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead(NotificationProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đánh dấu tất cả đã đọc'),
        content: const Text('Tất cả thông báo sẽ được đánh dấu là đã đọc.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.markAllAsRead();
    }
  }

  Widget _buildLoadMoreIndicator(NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: provider.isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Text(
                '',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: List.generate(
        6,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: Colors.white, radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 200, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 160, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 80, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'follow':
        return Icons.person_add_outlined;
      case 'review':
        return Icons.star_outline;
      case 'like':
        return Icons.favorite_border;
      case 'comment':
      case 'comment_product':
        return Icons.chat_bubble_outline;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return AppColors.primary;
      case 'payment':
        return AppColors.info;
      case 'promotion':
        return AppColors.warning;
      case 'follow':
        return const Color(0xFF6366F1);
      case 'review':
        return const Color(0xFFF59E0B);
      case 'like':
        return AppColors.error;
      case 'comment':
      case 'comment_product':
        return const Color(0xFF06B6D4);
      case 'system':
        return AppColors.textSecondary;
      default:
        return AppColors.textHint;
    }
  }

  String _getNotificationLabel(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return 'Đơn hàng';
      case 'payment':
        return 'Thanh toán';
      case 'promotion':
        return 'Khuyến mãi';
      case 'follow':
        return 'Theo dõi';
      case 'review':
        return 'Đánh giá';
      case 'like':
        return 'Yêu thích';
      case 'comment':
      case 'comment_product':
        return 'Bình luận';
      case 'system':
        return 'Hệ thống';
      default:
        return 'Thông báo';
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}
