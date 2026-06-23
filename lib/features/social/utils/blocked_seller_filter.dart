import '../../../models/models.dart';

String? productSellerId(Product product) {
  final nestedSellerId = product.seller?.id;
  if (nestedSellerId != null && nestedSellerId.isNotEmpty) {
    return nestedSellerId;
  }

  final sellerId = product.sellerId;
  if (sellerId != null && sellerId.isNotEmpty) {
    return sellerId;
  }

  return null;
}

Set<String> blockedSellerIdsFromUsers(List<User> blockedUsers) {
  return blockedUsers
      .map((user) => user.id)
      .where((id) => id.isNotEmpty)
      .toSet();
}

bool isProductFromBlockedSeller(
  Product product,
  Set<String> blockedSellerIds,
) {
  final sellerId = productSellerId(product);
  return sellerId != null && blockedSellerIds.contains(sellerId);
}

List<Product> visibleProductsForBlockedSellers(
  List<Product> products,
  List<User> blockedUsers,
) {
  final blockedSellerIds = blockedSellerIdsFromUsers(blockedUsers);
  if (blockedSellerIds.isEmpty) return products;

  return products
      .where((product) => !isProductFromBlockedSeller(product, blockedSellerIds))
      .toList();
}
