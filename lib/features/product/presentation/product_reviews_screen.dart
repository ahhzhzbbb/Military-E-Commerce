import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_data.dart';
import '../../../core/cache/catalog_cache.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/social.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String productId;
  final String? sellerId;

  const ProductReviewsScreen({super.key, required this.productId, this.sellerId});

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

  Future<void> _submitRating(int stars, String content) async {
    final productId = int.tryParse(widget.productId) ?? widget.productId;

    final sellerId = widget.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể đánh giá: thiếu thông tin người bán'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    final response = await _apiClient.post(
      ApiConstants.setRates,
      body: {
        'user_id': int.tryParse(sellerId) ?? sellerId,
        'level': stars,
        'content': content,
        'product_id': productId,
      },
      requiresAuth: true,
    );

    if (response.isSuccess && mounted) {
      await CatalogCache.clearProduct(widget.productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đánh giá thành công!'), backgroundColor: AppColors.success),
      );
      _loadReviews();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message.isNotEmpty ? response.message : 'Gửi đánh giá thất bại'), backgroundColor: AppColors.error),
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
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
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
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showRatingDialog(),
              icon: const Icon(Icons.rate_review_outlined, size: 22),
              label: const Text('Viết đánh giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Đánh giá sản phẩm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chọn số sao',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isSelected = index < selectedStars;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedStars = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isSelected ? AppColors.accent : AppColors.textHint,
                        size: 48,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingLabel(selectedStars),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedStars >= 4 ? AppColors.success : (selectedStars >= 2 ? AppColors.warning : AppColors.error),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nội dung đánh giá *',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Nhập đánh giá của bạn...',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final content = commentController.text.trim();
                    if (content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập nội dung đánh giá'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).pop();
                    _submitRating(selectedStars, content);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Gửi đánh giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int stars) {
    switch (stars) {
      case 5:
        return 'Tuyệt vời';
      case 4:
        return 'Hài lòng';
      case 3:
        return 'Bình thường';
      case 2:
        return 'Không hài lòng';
      case 1:
        return 'Rất tệ';
      default:
        return '';
    }
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
