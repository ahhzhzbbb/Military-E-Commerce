import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/models/models.dart';

class ProductProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Category> _categories = [];
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedCategoryId;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;

  // Helper method to handle category ID parameter (int or string)
  dynamic _categoryParam(int categoryId) {
    return categoryId;
  }

  // Helper methods to parse API responses
  List<Category> _parseCategories(dynamic data) {
    return ApiData.asList(data, ['data'])
        .whereType<Map>()
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Helper method to parse products from API response
  List<Product> _parseProducts(dynamic data) {
    return ApiData.asList(data, ['products', 'items', 'list'])
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Load categories from API
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(ApiConstants.getCategories);
      if (!response.isSuccess) {
        throw Exception('${response.message} (Code: ${response.code})');
      }
      _categories = _parseCategories(response.data);
    } catch (e) {
      _error = e.toString();
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load products with optional category filter and search keyword
  Future<void> loadProducts({int? categoryId, String? keyword}) async {
    _isLoading = true;
    _error = null;
    _selectedCategoryId = categoryId;
    notifyListeners();

    try {
      final trimmedKeyword = keyword?.trim() ?? '';
      final useSearchEndpoint = categoryId != null || trimmedKeyword.isNotEmpty;
      final body = <String, dynamic>{
        'keyword': useSearchEndpoint
            ? (trimmedKeyword.isNotEmpty ? trimmedKeyword : ' ')
            : '',
        'index': 0,
        'count': 20,
        if (categoryId != null) 'category_id': _categoryParam(categoryId),
      };
      final response = await _apiClient.post(
        useSearchEndpoint ? ApiConstants.search : ApiConstants.getListProducts,
        body: body,
      );

      if (!response.isSuccess) {
        throw Exception('${response.message} (Code: ${response.code})');
      }

      _products = _parseProducts(response.data);
      _featuredProducts = _products.take(4).toList();
    } catch (e) {
      _error = e.toString();
      _products = [];
      _featuredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Load all products without any filters
  Future<void> loadAllProducts() async {
    await loadProducts();
  }

  // Clear category filter and reload products
  void clearCategoryFilter() {
    _selectedCategoryId = null;
    loadProducts();
  }
}
