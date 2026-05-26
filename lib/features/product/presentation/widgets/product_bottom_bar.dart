import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../models/models.dart';

class ProductBottomBar extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final Function(int) onQuantityChanged;

  const ProductBottomBar({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onQuantityChanged,
  });

  @override
  State<ProductBottomBar> createState() => _ProductBottomBarState();
}

class _ProductBottomBarState extends State<ProductBottomBar> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildQuantitySelector(),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              // onPressed: widget.product.isInStock ? _handleAddToCart : null,
              onPressed: _handleAddToCart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                // widget.product.isInStock ? 'Thêm vào giỏ hàng' : 'Hết hàng',
                'Thêm vào giỏ hàng',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            // onPressed: widget.product.isInStock ? _handleBuyNow : null,
            onPressed: _handleBuyNow,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              backgroundColor: AppColors.accent,
            ),
            child: const Text(
              'Mua ngay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            // onPressed: _quantity < (widget.product.stock ?? 1)
            //     ? () => setState(() => _quantity++)
            //     : null,
            onPressed: () => setState(() => _quantity++),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart() {
    widget.onAddToCart();
  }

  void _handleBuyNow() {
    widget.onBuyNow();
  }

  int get quantity => _quantity;
  set quantity(int value) => setState(() => _quantity = value);
}
