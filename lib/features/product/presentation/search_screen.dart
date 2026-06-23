import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/cache/api_cache.dart';
import 'package:military_e_commerce/core/cache/catalog_cache.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/core/constants/app_theme.dart';
import 'package:military_e_commerce/core/widgets/common_widgets.dart';
import 'package:military_e_commerce/features/social/data/follow_provider.dart';
import 'package:military_e_commerce/features/social/utils/blocked_seller_filter.dart';
import 'package:military_e_commerce/models/models.dart';
import 'package:provider/provider.dart';
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
  List<SavedSearch> _savedSearches = [];
  List<Category> _categories = [];
  bool _isSearching = false;
  bool _isLoadingSaved = true;
  int? _selectedCategoryId;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadSavedSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowProvider>().loadBlocked();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Category> _parseCategories(dynamic data) {
    return ApiData.asList(data, ['categories', 'data'])
        .whereType<Map>()
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _loadCategories() async {
    final cacheKey = CatalogCache.categoriesKey();
    final cachedData = await ApiCache.read(cacheKey);
    final hasCache = cachedData != null;

    if (hasCache && mounted) {
      setState(() {
        _categories = _parseCategories(cachedData);
        _error = null;
      });
    }

    final response = await _apiClient.post(ApiConstants.getCategories);
    if (!mounted) return;

    if (response.isSuccess) {
      setState(() {
        _categories = _parseCategories(response.data);
      });
      await ApiCache.write(
        cacheKey,
        response.data,
        CatalogCache.categoriesTtl,
      );
    } else {
      if (!hasCache) {
        setState(() => _error = response.message);
      }
    }
  }

  Future<void> _loadSavedSearches() async {
    final response = await _apiClient.post(
      ApiConstants.getListSavedSearch,
      body: {'index': 0, 'count': 20},
      requiresAuth: true,
    );
    if (!mounted) return;

    if (response.isSuccess) {
      setState(() {
        _savedSearches = ApiData.asList(response.data, ['saved_searches', 'items', 'list'])
            .whereType<Map>()
            .map((item) => SavedSearch.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        _isLoadingSaved = false;
      });
    } else {
      setState(() => _isLoadingSaved = false);
    }
  }

  Future<void> _deleteSavedSearch(SavedSearch search) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _savedSearches.removeWhere((s) => s.id == search.id);
    });

    final response = await _apiClient.post(
      ApiConstants.delSavedSearch,
      body: {
        if (search.id.isNotEmpty) 'search_id': int.tryParse(search.id) ?? 0,
        if (search.keyword.isNotEmpty) 'keyword': search.keyword,
      },
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Xóa thất bại'), backgroundColor: AppColors.error),
        );
        _loadSavedSearches();
      }
    }
  }

  Future<void> _deleteAllSavedSearches() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _savedSearches.clear());

    final response = await _apiClient.post(
      ApiConstants.delSavedSearch,
      body: {'search_id': 0},
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Xóa thất bại'), backgroundColor: AppColors.error),
        );
        _loadSavedSearches();
      }
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

  List<Product> _visibleSearchResults(BuildContext context) {
    return visibleProductsForBlockedSellers(
      _searchResults,
      context.watch<FollowProvider>().blocked,
    );
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

    final body = <String, dynamic>{
      'keyword': trimmedQuery.isNotEmpty ? trimmedQuery : ' ',
      'index': 0,
      'count': 20,
      if (_selectedCategoryId != null)
        'category_id': _categoryParam(_selectedCategoryId!),
    };
    final currentRequestId = ++_requestId;
    final cacheKey = CatalogCache.searchKey(body);
    final cachedData = await ApiCache.read(cacheKey);
    if (!mounted || currentRequestId != _requestId) return;
    final hasCache = cachedData != null;

    if (hasCache) {
      setState(() {
        _searchResults = _parseProducts(cachedData);
        _isSearching = false;
        _error = null;
      });
    } else {
      setState(() {
        _isSearching = true;
        _error = null;
      });
    }

    try {
      final response = await _apiClient.post(
        ApiConstants.search,
        body: body,
        requiresAuth: true,
      );

      if (!mounted || currentRequestId != _requestId) return;

      if (!response.isSuccess) {
        throw Exception('${response.message} (Code: ${response.code})');
      }

      setState(() {
        _searchResults = _parseProducts(response.data);
      });
      await ApiCache.write(cacheKey, response.data, CatalogCache.searchTtl);
      _loadSavedSearches();
    } catch (e) {
      if (!mounted || currentRequestId != _requestId) return;
      if (!hasCache) {
        setState(() {
          _searchResults = [];
          _error = e.toString();
        });
      }
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
    final visibleResults = _visibleSearchResults(context);

    if (_isSearching) {
      return const ShimmerProductGrid();
    }

    if (visibleResults.isNotEmpty) {
      return _buildSearchResults(visibleResults);
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
          if (_savedSearches.isNotEmpty) ...[
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
                  onPressed: _deleteAllSavedSearches,
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _savedSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search.keyword;
                    _performSearch(search.keyword);
                  },
                  child: Chip(
                    label: Text(search.keyword),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _deleteSavedSearch(search),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ] else if (!_isLoadingSaved) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Chưa có tìm kiếm gần đây',
                style: TextStyle(color: AppColors.textHint, fontSize: 13),
              ),
            ),
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

  Widget _buildSearchResults(List<Product> visibleResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tìm thấy ${visibleResults.length} sản phẩm',
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
            itemCount: visibleResults.length,
            itemBuilder: (context, index) {
              return _buildProductItem(visibleResults[index]);
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
