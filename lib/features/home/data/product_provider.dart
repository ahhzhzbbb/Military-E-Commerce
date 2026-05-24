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
  String? _selectedCategoryId;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;

  dynamic _categoryParam(String categoryId) {
    return int.tryParse(categoryId) ?? categoryId;
  }

  List<Category> _parseCategories(dynamic data) {
    return ApiData.asList(data, ['categories'])
        .whereType<Map>()
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<Product> _parseProducts(dynamic data) {
    return ApiData.asList(data, ['products', 'items', 'list'])
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

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

  Future<void> loadProducts({String? categoryId, String? keyword}) async {
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

  Future<void> loadAllProducts() async {
    await loadProducts();
  }

  void clearCategoryFilter() {
    _selectedCategoryId = null;
    loadProducts();
  }
}
