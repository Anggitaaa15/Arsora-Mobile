import 'package:arsora_mobile/pages/add_product.dart';
import 'package:flutter/material.dart';
import '../theme/appColors.dart';
import '../theme/appTextStyles.dart';
import '../service/api.dart';
import '../widgets/product_card.dart';
import 'package:intl/intl.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<dynamic> products = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Minimalist',
    'Abstract',
    'Landscape',
    'Botanical',
    'Vintage',
    'Meaningful Works',
    'Rare Collections',
  ];

  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getProducts() async {
    try {
      final response = await ApiService.get('/products');

      List<dynamic> result = [];

      if (response is List) {
        result = response;
      } else if (response is Map) {
        final data = response['data'];

        if (data is List) {
          result = data;
        } else if (data is Map && data['products'] is List) {
          result = data['products'];
        } else if (response['products'] is List) {
          result = response['products'];
        }
      }

      if (!mounted) return;

      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil produk: $e')));
    }
  }

  String formatPrice(dynamic price) {
    final value = double.tryParse(price.toString()) ?? 0;

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String getCategory(dynamic product) {
    final categoryData = product['category'];

    if (categoryData is Map) {
      return categoryData['name']?.toString() ?? '';
    }

    return categoryData?.toString() ?? '';
  }

  List<dynamic> get filteredProducts {
    return products.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final category = getCategory(product).toLowerCase();

      final matchesSearch = name.contains(searchQuery.toLowerCase());

      final matchesCategory =
          selectedCategory == 'All' ||
          category == selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedProducts = filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: Text(
          'Produk Saya',
          style: AppTextStyles.heading.copyWith(
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: getProducts,
                    child: displayedProducts.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text('Produk tidak ditemukan.')),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayedProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.68,
                                ),
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];

                              return ProductCard(
                                product: product,
                                isAdmin: true,
                                onRefresh: getProducts,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProduct()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
