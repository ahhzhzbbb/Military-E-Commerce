import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../models/models.dart';
import '../product_reviews_screen.dart';

class ProductTabsWidget extends StatefulWidget {
  final Product product;
  final List<Comment> comments;

  const ProductTabsWidget({
    super.key,
    required this.product,
    required this.comments,
  });

  @override
  State<ProductTabsWidget> createState() => _ProductTabsWidgetState();
}

class _ProductTabsWidgetState extends State<ProductTabsWidget> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        _buildTabItem('Mô tả', 0),
        _buildTabItem('Đánh giá (${widget.product.ratingCount ?? 0})', 1),
        _buildTabItem('Câu hỏi', 2),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildDescriptionTab();
      case 1:
        return _buildReviewsTab();
      case 2:
        return _buildQuestionsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDescriptionTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.described ?? 'Không có mô tả cho sản phẩm này.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.comments.isEmpty)
            const Text(
              'Chưa có đánh giá nào',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...widget.comments.take(3).map((comment) => _buildCommentItem(comment)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductReviewsScreen(
                      productId: widget.product.id.toString(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Xem tất cả đánh giá'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: comment.userAvatar != null
                ? ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: comment.userAvatar,
                      width: 40,
                      height: 40,
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName ?? 'Người dùng',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (comment.isLiked == true)
                      const Icon(Icons.favorite, size: 16, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(comment.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.help_outline, size: 48, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('Chưa có câu hỏi nào'),
            SizedBox(height: 8),
            Text(
              'Hãy là người đầu tiên đặt câu hỏi về sản phẩm này',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    }
    return 'Vừa xong';
  }
}
