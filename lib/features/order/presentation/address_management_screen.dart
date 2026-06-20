import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/models.dart';
import 'package:shimmer/shimmer.dart';
import '../data/order_provider.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ giao hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.addresses.isEmpty) {
            return _buildAddressShimmer();
          }

          if (orderProvider.addresses.isEmpty) {
            return EmptyState(
              icon: Icons.location_off,
              title: 'Chưa có địa chỉ',
              message: 'Thêm địa chỉ giao hàng để đặt hàng nhanh hơn',
              buttonText: 'Thêm địa chỉ',
              onButtonPressed: () => _showAddressDialog(context),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProvider.addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final address = orderProvider.addresses[index];
                    return _buildAddressCard(context, address, orderProvider);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddressDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm địa chỉ mới'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressShimmer() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(3, (_) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 120, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 13, width: 140, color: Colors.white),
              const SizedBox(height: 6),
              Container(height: 13, width: double.infinity, color: Colors.white),
              const SizedBox(height: 6),
              Container(height: 13, width: 200, color: Colors.white),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildAddressCard(BuildContext context, OrderAddress address, OrderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Mặc định',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address.phone,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            address.displayAddress,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showEditAddressDialog(context, address),
                child: const Text('Sửa'),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () => _deleteAddress(context, address, provider),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddressDialog(BuildContext context, [OrderAddress? existing]) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final addressController = TextEditingController(text: existing?.fullAddress ?? '');
    bool isDefault = existing?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: isDefault,
                onChanged: (v) => setDialogState(() => isDefault = v ?? false),
                title: const Text('Đặt làm mặc định'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty || addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin'), backgroundColor: AppColors.error),
                  );
                  return;
                }

                Navigator.of(context).pop();
                final orderProvider = this.context.read<OrderProvider>();

                if (existing != null) {
                  await orderProvider.updateAddress(
                    addressId: existing.id,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    address: addressController.text.trim(),
                    isDefault: isDefault,
                  );                } else {
                  await orderProvider.addAddress(
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    address: addressController.text.trim(),
                    isDefault: isDefault,
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog(BuildContext context, OrderAddress address) {
    _showAddressDialog(context, address);
  }

  Future<void> _deleteAddress(BuildContext context, OrderAddress address, OrderProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: Text('Bạn có chắc muốn xóa địa chỉ của ${address.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await provider.deleteAddress(address.id);
    }
  }
}
