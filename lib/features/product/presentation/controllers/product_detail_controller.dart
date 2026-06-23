import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_data.dart';
import '../../../../core/cache/api_cache.dart';
import '../../../../core/cache/catalog_cache.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../models/models.dart';

class ProductDetailController {
  final ApiClient apiClient = ApiClient();

  Product? product;
  List<Comment> comments = [];
  List<Rating> ratings = [];
  bool isLoading = true;
  String? error;
  bool isLiked = false;
  double averageRating = 0;

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

  List<Rating> parseRatings(dynamic data) {
    return ApiData.asList(data, ['rates', 'ratings', 'items', 'list'])
        .whereType<Map>()
        .map((item) => Rating.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _updateAverageRating() {
    averageRating = ratings.isEmpty
        ? 0
        : ratings.fold(0.0, (sum, rating) => sum + rating.stars) /
            ratings.length;
  }

  Future<void> loadProduct(
    String productId, {
    void Function()? onCachedData,
  }) async {
    final parsedProductId = productIdParam(productId);
    final productBody = {'id': parsedProductId};
    final commentsBody = {
      'product_id': parsedProductId,
      'index': 0,
      'count': 50,
    };
    final ratingsBody = {
      'product_id': parsedProductId,
      'index': 0,
      'count': 50,
    };
    final productCacheKey = CatalogCache.productDetailKey(
      productId,
      productBody,
    );
    final commentsCacheKey = CatalogCache.commentsKey(productId, commentsBody);
    final ratingsCacheKey = CatalogCache.ratingsKey(productId, ratingsBody);

    final cachedProduct = await ApiCache.read(productCacheKey);
    final cachedComments = await ApiCache.read(commentsCacheKey);
    final cachedRatings = await ApiCache.read(ratingsCacheKey);
    final hasProductCache = cachedProduct != null;

    if (hasProductCache) {
      product = parseProduct(cachedProduct);
      isLiked = product?.isLiked ?? false;
      if (cachedComments != null) {
        comments = parseComments(cachedComments);
      }
      if (cachedRatings != null) {
        ratings = parseRatings(cachedRatings);
      }
      _updateAverageRating();
      error = null;
      isLoading = false;
      onCachedData?.call();
    } else {
      isLoading = true;
      error = null;
    }

    try {
      final productResponse = await apiClient.post(
        ApiConstants.getProduct,
        body: productBody,
        requiresAuth: true,
      );

      if (!productResponse.isSuccess) {
        throw Exception(
          '${productResponse.message} (Code: ${productResponse.code})',
        );
      }

      final commentsResponse = await apiClient.post(
        ApiConstants.getCommentsProduct,
        body: commentsBody,
        requiresAuth: true,
      );

      final ratingsResponse = await apiClient.post(
        ApiConstants.getRates,
        body: ratingsBody,
        requiresAuth: true,
      );

      product = parseProduct(productResponse.data);
      await ApiCache.write(
        productCacheKey,
        productResponse.data,
        CatalogCache.productDetailTtl,
      );

      if (commentsResponse.isSuccess) {
        comments = parseComments(commentsResponse.data);
        await ApiCache.write(
          commentsCacheKey,
          commentsResponse.data,
          CatalogCache.productFeedbackTtl,
        );
      } else if (cachedComments == null) {
        comments = [];
      }

      if (ratingsResponse.isSuccess) {
        ratings = parseRatings(ratingsResponse.data);
        await ApiCache.write(
          ratingsCacheKey,
          ratingsResponse.data,
          CatalogCache.productFeedbackTtl,
        );
      } else if (cachedRatings == null) {
        ratings = [];
      }

      isLiked = product?.isLiked ?? false;
      _updateAverageRating();
    } catch (e) {
      if (!hasProductCache) {
        product = null;
        comments = [];
        ratings = [];
        averageRating = 0;
        error = e.toString();
      }
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
      await CatalogCache.clearProduct(productId);
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
