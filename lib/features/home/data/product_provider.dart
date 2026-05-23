import 'package:flutter/material.dart';
import 'package:military_e_commerce/models/models.dart';
import 'package:military_e_commerce/core/utils/mock_data.dart';

class ProductProvider extends ChangeNotifier {
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

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _categories = MockData.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({String? categoryId, String? keyword}) async {
    _isLoading = true;
    _selectedCategoryId = categoryId;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _products = MockData.getProducts(
        categoryId: categoryId,
        keyword: keyword,
      );
      _featuredProducts = _products.take(4).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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