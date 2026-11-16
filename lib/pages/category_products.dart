
import 'package:flutter/material.dart';

import '../service/api.dart';
import '../theme/appColors.dart';
import '../widgets/product_card.dart';

class CategoryProducts extends StatefulWidget {
  final String categoryName;

  const CategoryProducts({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    try {
      final response = await ApiService.get('/products');

      List<dynamic> data = [];

      if (response['data'] is List) {
        data = response['data'];
      } else if (response['data'] is Map &&
          response['data']['products'] is List) {
        data = response['data']['products'];
      } else if (response['products'] is List) {
        data = response['products'];
      }

      final filteredProducts = data.where((product) {
        final category = product['category'];

        final categoryName = category is Map
            ? category['name'].toString()
            : category.toString();

        return categoryName.toLowerCase() ==
            widget.categoryName.toLowerCase();
      }).toList();

      if (!mounted) return;

      setState(() {
        products = filteredProducts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error getting products: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : products.isEmpty
              ? const Center(
                  child: Text(
                    'No artworks found in this category.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: getProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: products[index],
                        isAdmin: false,
                      );
                    },
                  ),
                ),
    );
  }
}
