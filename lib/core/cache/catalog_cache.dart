import '../constants/api_constants.dart';
import 'api_cache.dart';

class CatalogCache {
  CatalogCache._();

  static const categoriesTtl = Duration(hours: 24);
  static const productListTtl = Duration(minutes: 15);
  static const searchTtl = Duration(minutes: 15);
  static const productDetailTtl = Duration(minutes: 10);
  static const productFeedbackTtl = Duration(minutes: 5);

  static String categoriesKey() {
    return ApiCache.buildKey(
      'catalog:categories',
      ApiConstants.getCategories,
      body: const <String, dynamic>{},
    );
  }

  static String productListKey(Map<String, dynamic> body) {
    return ApiCache.buildKey(
      'catalog:products',
      ApiConstants.getListProducts,
      body: body,
    );
  }

  static String searchKey(Map<String, dynamic> body) {
    return ApiCache.buildKey(
      'catalog:search',
      ApiConstants.search,
      body: body,
    );
  }

  static String productPrefix(String productId) {
    return 'catalog:product:$productId';
  }

  static String productDetailKey(String productId, Map<String, dynamic> body) {
    return ApiCache.buildKey(
      productPrefix(productId),
      ApiConstants.getProduct,
      body: body,
    );
  }

  static String commentsKey(String productId, Map<String, dynamic> body) {
    return ApiCache.buildKey(
      productPrefix(productId),
      ApiConstants.getCommentsProduct,
      body: body,
    );
  }

  static String ratingsKey(String productId, Map<String, dynamic> body) {
    return ApiCache.buildKey(
      productPrefix(productId),
      ApiConstants.getRates,
      body: body,
    );
  }

  static Future<void> clearProduct(String productId) {
    return ApiCache.removeByPrefix(productPrefix(productId));
  }
}
