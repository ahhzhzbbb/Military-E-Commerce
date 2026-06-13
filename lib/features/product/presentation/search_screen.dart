import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/core/constants/app_theme.dart';
import 'package:military_e_commerce/core/widgets/common_widgets.dart';
import 'package:military_e_commerce/models/models.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiClient _apiClient = ApiClient();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Product> _searchResults = [];
  final List<String> _recentSearches = [];
  List<Category> _categories = [];
  bool _isSearching = false;
  int? _selectedCategoryId;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final response = await _apiClient.post(ApiConstants.getCategories);
    if (!mounted) return;

    if (response.isSuccess) {
      setState(() {
        _categories = ApiData.asList(response.data, ['categories'])
            .whereType<Map>()
            .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      });
    } else {
      setState(() => _error = response.message);
    }
  }

  void _performSearch(String query) {
    _runSearch(query: query);
  }

  dynamic _categoryParam(int categoryId) {
    return categoryId;
  }

  List<Product> _parseProducts(dynamic data) {
    return ApiData.asList(data, ['products', 'items', 'list'])
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _runSearch({String? query}) async {
    final rawQuery = query ?? _searchController.text;
    final trimmedQuery = rawQuery.trim();

    if (trimmedQuery.isEmpty && _selectedCategoryId == null) {
      _requestId++;
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _error = null;
      });
      return;
    }

    final currentRequestId = ++_requestId;
    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final response = await _apiClient.post(
        ApiConstants.search,
        body: {
          'keyword': trimmedQuery.isNotEmpty ? trimmedQuery : ' ',
          'index': 0,
          'count': 20,
          if (_selectedCategoryId != null)
            'category_id': _categoryParam(_selectedCategoryId!),
        },
      );

      if (!mounted || currentRequestId != _requestId) return;

      if (!response.isSuccess) {
        throw Exception('${response.message} (Code: ${response.code})');
      }

      setState(() {
        _searchResults = _parseProducts(response.data);
        if (trimmedQuery.isNotEmpty &&
            !_recentSearches.contains(trimmedQuery)) {
          _recentSearches.insert(0, trimmedQuery);
          if (_recentSearches.length > 10) _recentSearches.removeLast();
        }
      });
    } catch (e) {
      if (!mounted || currentRequestId != _requestId) return;
      setState(() {
        _searchResults = [];
        _error = e.toString();
      });
    } finally {
      if (mounted && currentRequestId == _requestId) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });

    if (categoryId == null && _searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }

    _runSearch();
  }

  void _clearSearch() {
    _requestId++;
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _selectedCategoryId = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.divider.withValues(alpha: 0.3),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          onChanged: _performSearch,
          onSubmitted: _performSearch,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Không tải được dữ liệu',
        message: _error!,
      );
    }

    if (_searchController.text.isEmpty && _selectedCategoryId == null) {
      return _buildInitialContent();
    }

    if (_searchResults.isEmpty && !_isSearching) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'Không tìm thấy kết quả',
        message: 'Thử tìm kiếm với từ khóa khác',
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tìm kiếm gần đây',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  child: Chip(
                    label: Text(search),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _recentSearches.remove(search);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Danh mục sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategoryId == category.id;
              return GestureDetector(
                onTap: () => _selectCategory(isSelected ? null : category.id),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomNetworkImage(
                        imageUrl: category.imageUrl,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tìm thấy ${_searchResults.length} sản phẩm',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return _buildProductItem(_searchResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomNetworkImage(
              imageUrl: product.images.isNotEmpty ? product.images.first : null,
              height: 140,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    PriceDisplay(
                      price: product.effectivePrice,
                      originalPrice: product.hasDiscount ? product.price : null,
                      showDiscountPercent: product.hasDiscount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
