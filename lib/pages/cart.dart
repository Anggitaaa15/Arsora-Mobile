import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../service/api.dart';
import '../theme/appColors.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<dynamic> cartItems = [];
  Set<int> selectedItems = {};

  bool isLoading = true;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    getCart();
  }

  // Get Cart
  Future<void> getCart() async {
    try {
      final response = await ApiService.get('/cart');

      final List<dynamic> data = response['data']['cart'];

      setState(() {
        cartItems = data;
        selectedItems = data.map<int>((item) => item['id'] as int).toSet();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint('Get cart error: $e');
    }
  }

  // Select All
  void selectAll(bool? value) {
    setState(() {
      if (value == true) {
        selectedItems = cartItems.map<int>((item) => item['id'] as int).toSet();
      } else {
        selectedItems.clear();
      }
    });
  }

  // Select One
  void selectItem(int id, bool? value) {
    setState(() {
      if (value == true) {
        selectedItems.add(id);
      } else {
        selectedItems.remove(id);
      }
    });
  }

  // Calculate Total
  double get totalPrice {
    double total = 0;

    for (var item in cartItems) {
      if (selectedItems.contains(item['id'])) {
        total +=
            double.parse(item['price'].toString()) *
            int.parse(item['quantity'].toString());
      }
    }

    return total;
  }

  // Update Quantity
  Future<void> updateQuantity(int id, int quantity) async {
    if (quantity < 1) return;

    try {
      await ApiService.put('/cart/$id', {'quantity': quantity});

      await getCart();
    } catch (e) {
      debugPrint('Update quantity error: $e');
    }
  }

  // Remove Item
  Future<void> removeItem(int id) async {
    try {
      await ApiService.delete('/cart/$id');

      setState(() {
        cartItems.removeWhere((item) => item['id'] == id);
        selectedItems.remove(id);
      });
    } catch (e) {
      debugPrint('Remove cart item error: $e');
    }
  }

  // Clear All Cart
  Future<void> clearCart() async {
    if (cartItems.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to remove all products from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.delete('/cart/clear');

      if (!mounted) return;

      setState(() {
        cartItems.clear();
        selectedItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All products removed from cart')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to clear cart: $e')));
    }
  }

  // Checkout Selected Products
  Future<void> checkoutSelected() async {
    if (selectedItems.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Checkout'),
        content: Text(
          'Are you sure you want to checkout ${selectedItems.length} selected product(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final idsToCheckout = selectedItems.toList();

    try {
      for (final id in idsToCheckout) {
        await ApiService.delete('/cart/$id');
      }

      if (!mounted) return;

      setState(() {
        cartItems.removeWhere((item) => idsToCheckout.contains(item['id']));

        selectedItems.clear();
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 55),
          title: const Text('Checkout Successful!'),
          content: const Text(
            'Your selected products have been checked out successfully.',
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));

      await getCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllSelected =
        cartItems.isNotEmpty && selectedItems.length == cartItems.length;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: clearCart,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            )
          : Column(
              children: [
                // Select All
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isAllSelected,
                        activeColor: AppColors.secondary,
                        onChanged: selectAll,
                      ),
                      const Text(
                        'Select All',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${selectedItems.length} selected',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Cart Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      final int id = item['id'];
                      final int quantity = item['quantity'];
                      final bool isSelected = selectedItems.contains(id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: AppColors.secondary,
                              onChanged: (value) {
                                selectItem(id, value);
                              },
                            ),

                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['imageUrl'] ?? '',
                                width: 100,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 110,
                                    color: AppColors.homeBackground,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Product Information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    item['category'] ?? '',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    currencyFormat.format(
                                      double.parse(item['price'].toString()),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Quantity Control
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: quantity > 1
                                            ? () => updateQuantity(
                                                id,
                                                quantity - 1,
                                              )
                                            : null,
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        iconSize: 22,
                                      ),

                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: quantity < item['stock']
                                            ? () => updateQuantity(
                                                id,
                                                quantity + 1,
                                              )
                                            : null,
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: AppColors.secondary,
                                        ),
                                        iconSize: 22,
                                      ),

                                      const Spacer(),

                                      IconButton(
                                        onPressed: () => removeItem(id),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
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
                    },
                  ),
                ),
              ],
            ),

      // Cart Summary
      bottomNavigationBar: cartItems.isEmpty || isLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(currencyFormat.format(totalPrice)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        currencyFormat.format(totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedItems.isEmpty
                          ? null
                          : checkoutSelected,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        disabledBackgroundColor: AppColors.border,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Checkout Now',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
