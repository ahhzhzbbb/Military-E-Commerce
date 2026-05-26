import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_data.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../models/models.dart';

class ProductDetailController {
  final ApiClient apiClient = ApiClient();

  Product? product;
  List<Comment> comments = [];
  bool isLoading = true;
  String? error;
  bool isLiked = false;

  dynamic productIdParam(String productId) {
    return int.tryParse(productId) ?? productId;
  }

  Product? parseProduct(dynamic data) {
    final map = ApiData.mapFrom(data, ['product']);
    if (map != null) return Product.fromJson(map);

    final list = ApiData.asList(data, ['products', 'items', 'list']);
    if (list.isEmpty || list.first is! Map) return null;
    return Product.fromJson(Map<String, dynamic>.from(list.first as Map));
  }

  List<Comment> parseComments(dynamic data) {
    return ApiData.asList(data, ['comments', 'items', 'list'])
        .whereType<Map>()
        .map((item) => Comment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> loadProduct(String productId) async {
    isLoading = true;
    error = null;

    try {
      final productResponse = await apiClient.post(
        ApiConstants.getProduct,
        body: {'id': productIdParam(productId)},
        requiresAuth: true,
      );

      if (!productResponse.isSuccess) {
        throw Exception(
          '${productResponse.message} (Code: ${productResponse.code})',
        );
      }

      final commentsResponse = await apiClient.post(
        ApiConstants.getCommentsProduct,
        body: {'product_id': productIdParam(productId), 'index': 0, 'count': 20},
        requiresAuth: true,
      );

      product = parseProduct(productResponse.data);
      comments =
          commentsResponse.isSuccess ? parseComments(commentsResponse.data) : [];
          isLiked = product?.isLiked ?? false;
    } catch (e) {
      product = null;
      comments = [];
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<bool> toggleLike(String productId) async {
    if (product == null) return false;

    final response = await apiClient.post(
      ApiConstants.likeProduct,
      body: {'product_id': productIdParam(productId)},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      isLiked = !isLiked;
      return true;
    }
    return false;
  }

  String formatDate(DateTime? date) {
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
