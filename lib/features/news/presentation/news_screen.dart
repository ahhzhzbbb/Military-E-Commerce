import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_data.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/social.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<NewsItem> _news = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _apiClient.post(
      ApiConstants.getListNews,
      body: const {'index': 0, 'count': 20},
      requiresAuth: true,
    );

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _news = ApiData.asList(response.data, ['news', 'items', 'list', 'data'])
              .whereType<Map>()
              .map((item) => NewsItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else {
          _error = response.message;
          _news = [];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin tức'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Đang tải...')
          : _news.isEmpty
              ? EmptyState(
                  icon: Icons.newspaper,
                  title: 'Không có tin tức',
                  message: _error ?? 'Chưa có bài viết nào',
                  onButtonPressed: _loadNews,
                  buttonText: 'Thử lại',
                )
              : RefreshIndicator(
                  onRefresh: _loadNews,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _news.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildNewsItem(_news[index]),
                  ),
                ),
    );
  }

  Widget _buildNewsItem(NewsItem news) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.title != null)
              Text(
                news.title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            if (news.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(news.createdAt!),
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
            if (news.content != null) ...[
              const SizedBox(height: 8),
              Text(
                news.content!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
