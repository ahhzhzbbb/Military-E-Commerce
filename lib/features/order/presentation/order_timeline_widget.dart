import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/order.dart';

class OrderTimelineWidget extends StatelessWidget {
  final List<OrderTimeline> timeline;

  const OrderTimelineWidget({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline, size: 48, color: AppColors.textHint),
              SizedBox(height: 12),
              Text('Chưa có cập nhật trạng thái', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lịch sử đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${timeline.length} cập nhật',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        ...timeline.map((item) => _buildTimelineItem(item)),
      ],
    );
  }

  Widget _buildTimelineItem(OrderTimeline item) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              _formatTime(item.timestamp ?? DateTime.now()),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.divider,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.statusName ?? _statusText(item.status),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.description != null && item.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'shipping': return 'Đang vận chuyển';
      case 'delivered': return 'Đã giao hàng';
      case 'cancelled': return 'Đã hủy';
      case 'refunded': return 'Đã hoàn tiền';
      default: return status;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}\n${date.day}/${date.month}';
  }
}
