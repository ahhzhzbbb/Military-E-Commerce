import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/models.dart';
import '../../cart/data/cart_provider.dart';
import '../data/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  OrderAddress? _selectedAddress;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  OrderAddress? _defaultAddress(List<OrderAddress> addresses) {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => addresses.first,
    );
  }

  Future<void> _loadAddresses() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadAddresses();
    if (!mounted) return;

    setState(() {
      _selectedAddress ??= _defaultAddress(orderProvider.addresses);
    });
  }

  Future<void> _handlePlaceOrder() async {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final selectedAddress =
        _selectedAddress ?? _defaultAddress(orderProvider.addresses);

    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm địa chỉ giao hàng từ backend'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final order = await orderProvider.createOrder(
      items: cartProvider.items,
      shippingAddress: selectedAddress,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (order != null && mounted) {
      cartProvider.clearCart();
      _showOrderSuccessDialog(order);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Không thể tạo đơn hàng'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showOrderSuccessDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            const Text('Đặt hàng thành công!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã đơn hàng: ${order.id}'),
            const SizedBox(height: 8),
            Text('Tổng thanh toán: ${order.total.toStringAsFixed(0)} xu'),
            const SizedBox(height: 16),
            const Text(
              'Đơn hàng của bạn đang chờ được xác nhận. Bạn có thể theo dõi trạng thái đơn hàng trong mục "Đơn hàng của tôi".',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đặt hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShippingAddressSection(),
                      const SizedBox(height: 16),
                      _buildOrderItemsSection(cart),
                      const SizedBox(height: 16),
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final selectedAddress =
            _selectedAddress ?? _defaultAddress(orderProvider.addresses);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: orderProvider.addresses.isEmpty
                      ? _loadAddresses
                      : _showAddressPicker,
                  child: Text(
                    orderProvider.addresses.isEmpty ? 'Tải lại' : 'Thay đổi',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (orderProvider.isLoading && orderProvider.addresses.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (selectedAddress != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAddress.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            selectedAddress.phone,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress.fullAddress,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: AppColors.textHint),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        orderProvider.error ??
                            'Backend chưa trả về địa chỉ giao hàng',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _showAddressPicker() {
    final addresses = context.read<OrderProvider>().addresses;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(address.name),
                subtitle: Text(address.fullAddress),
                trailing: _selectedAddress?.id == address.id
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedAddress = address);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderItemsSection(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm đã chọn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...cart.items.map((item) => _buildOrderItem(item)),
      ],
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomNetworkImage(
              imageUrl: item.product.images.isNotEmpty
                  ? item.product.images.first
                  : null,
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.product.price.toStringAsFixed(0)} xu x ${item.quantity}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} xu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Thêm ghi chú cho đơn hàng (tùy chọn)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(CartProvider cart) {
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tạm tính:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text('${cart.subtotal.toStringAsFixed(0)} xu'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phí vận chuyển:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text('${cart.shippingFee.toStringAsFixed(0)} xu'),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng thanh toán:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${cart.total.toStringAsFixed(0)} xu',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handlePlaceOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Đặt hàng ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
