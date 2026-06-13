import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_data.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/social.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String productId;

  const ProductReviewsScreen({super.key, required this.productId});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final ApiClient _apiClient = ApiClient();

  List<Rating> _ratings = [];
  List<Comment> _comments = [];
  bool _isLoading = false;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    final productId = int.tryParse(widget.productId) ?? widget.productId;

    final ratingsResponse = await _apiClient.post(
      ApiConstants.getRates,
      body: {'product_id': productId, 'index': 0, 'count': 50},
      requiresAuth: true,
    );

    final commentsResponse = await _apiClient.post(
      ApiConstants.getCommentsProduct,
      body: {'product_id': productId, 'index': 0, 'count': 50},
      requiresAuth: true,
    );

    if (mounted) {
      setState(() {
        if (ratingsResponse.isSuccess) {
          _ratings = ApiData.asList(ratingsResponse.data, ['rates', 'ratings', 'items', 'list'])
              .whereType<Map>()
              .map((item) => Rating.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          if (_ratings.isNotEmpty) {
            _averageRating = _ratings.fold(0.0, (sum, r) => sum + r.stars) / _ratings.length;
          }
        }
        if (commentsResponse.isSuccess) {
          _comments = ApiData.asList(commentsResponse.data, ['comments', 'items', 'list'])
              .whereType<Map>()
              .map((item) => Comment.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _submitRating(int stars, {String? comment}) async {
    final productId = int.tryParse(widget.productId) ?? widget.productId;
    final response = await _apiClient.post(
      ApiConstants.setRates,
      body: {
        'product_id': productId,
        'level': stars,
        if (comment != null) 'content': comment,
      },
      requiresAuth: true,
    );

    if (response.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đánh giá'), backgroundColor: AppColors.success),
      );
      _loadReviews();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải đánh giá...')
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildRatingSummary()),
                  if (_ratings.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          'Đánh giá (${_ratings.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildRatingItem(_ratings[index]),
                      childCount: _ratings.length,
                    ),
                  ),
                  if (_comments.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          'Bình luận (${_comments.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCommentItem(_comments[index]),
                      childCount: _comments.length,
                    ),
                  ),
                  if (_ratings.isEmpty && _comments.isEmpty)
                    SliverFillRemaining(
                      child: const EmptyState(
                        icon: Icons.star_outline,
                        title: 'Chưa có đánh giá',
                        message: 'Hãy là người đầu tiên đánh giá sản phẩm này',
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRatingDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.rate_review, color: Colors.white),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              RatingStars(
                rating: _averageRating,
                activeColor: AppColors.accent,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                '${_ratings.length} đánh giá',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final starCount = 5 - index;
                final count = _ratings.where((r) => r.stars == starCount).length;
                final percent = _ratings.isEmpty ? 0.0 : count / _ratings.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$starCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const Icon(Icons.star, color: AppColors.accent, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.white24,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(Rating rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: rating.userAvatar != null
                  ? ClipOval(
                      child: CustomNetworkImage(
                        imageUrl: rating.userAvatar,
                        width: 36,
                        height: 36,
                      ),
                    )
                  : const Icon(Icons.person, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rating.userName ?? 'Người dùng',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  RatingStars(rating: rating.stars.toDouble(), size: 14),
                  if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      rating.comment!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                  if (rating.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatDate(rating.createdAt!),
                        style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: comment.userAvatar != null
                ? ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: comment.userAvatar,
                      width: 36,
                      height: 36,
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName ?? 'Người dùng',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    if (comment.createdAt != null)
                      Text(
                        _formatDate(comment.createdAt!),
                        style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    int selectedStars = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Đánh giá sản phẩm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: AppColors.accent,
                      size: 36,
                    ),
                    onPressed: () => setDialogState(() => selectedStars = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Nhập bình luận (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitRating(selectedStars, comment: commentController.text.trim().isNotEmpty ? commentController.text.trim() : null);
              },
              child: const Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}
