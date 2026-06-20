import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/social.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../data/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: const Text(
                    'Đọc tất cả',
                    style: TextStyle(color: Colors.white),
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
            return _buildNotificationShimmer();
          }

          if (provider.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'Không có thông báo',
              message: 'Bạn sẽ nhận được thông báo khi có hoạt động mới',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(),
            child: ListView.separated(
              itemCount: provider.notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationItem(provider, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationShimmer() {
    return ListView(
      children: List.generate(5, (_) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: const ShimmerListTile(leadingCircle: true),
      )),
    );
  }

  Widget _buildNotificationItem(NotificationProvider provider, AppNotification notification) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.divider
              : AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getNotificationIcon(notification.type),
          color: notification.isRead ? AppColors.textHint : AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: notification.message != null
          ? Text(
              notification.message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: notification.createdAt != null
          ? Text(
              _formatTime(notification.createdAt!),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            )
          : null,
      tileColor: notification.isRead ? null : AppColors.primary.withValues(alpha: 0.03),
      onTap: () {
        if (!notification.isRead) {
          provider.markAsRead(notification.id);
        }
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
      case 'promotion':
        return Icons.local_offer;
      case 'follow':
        return Icons.person_add;
      case 'review':
        return Icons.star;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
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
