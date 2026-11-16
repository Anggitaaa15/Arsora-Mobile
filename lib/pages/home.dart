
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/appColors.dart';
import '../theme/appTextStyles.dart';
import '../service/api.dart';
import 'cart.dart';
import 'product_detail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> products = [];

  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  // GET PRODUCTS
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get products: $e'),
        ),
      );
    }
  }

  // FORMAT PRICE
  String formatPrice(dynamic price) {
    final value = double.tryParse(price.toString()) ?? 0;

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // GET CATEGORY
  String getCategory(dynamic product) {
    final categoryData = product['category'];

    if (categoryData is Map) {
      return categoryData['name']?.toString() ?? '';
    }

    return categoryData?.toString() ?? '';
  }

  // FILTER PRODUCTS
  List<dynamic> get filteredProducts {
    return products.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final category = getCategory(product).toLowerCase();

      return name.contains(searchQuery.toLowerCase()) ||
          category.contains(searchQuery.toLowerCase());
    }).toList();
  }

  // FEATURED PRODUCTS
  List<dynamic> get popularProducts {
    return filteredProducts.take(5).toList();
  }

  // OPEN CART
  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Cart(),
      ),
    );
  }

  // OPEN PRODUCT DETAIL
  void openProductDetail(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetail(
          product: Map<String, dynamic>.from(product),
          isAdmin: false,
          onAddToCart: () {
            addToCart(product);
          },
        ),
      ),
    );
  }

  // ADD TO CART
  Future<void> addToCart(dynamic product) async {
    try {
      await ApiService.post('/cart', {
        'productId': product['id'],
        'quantity': 1,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product to cart: $e'),
        ),
      );
    }
  }

  // PRODUCT IMAGE
  Widget productImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFF0F3F5),
        child: const Icon(
          Icons.image_outlined,
          size: 40,
          color: Colors.grey,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF0F3F5),
          child: const Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  // SECTION TITLE
  Widget sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // FEATURED PAINTING CARD
  Widget buildPopularCard(dynamic product) {
    return InkWell(
      onTap: () => openProductDetail(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEDF0F2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: productImage(
                  product['imageUrl']?.toString(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    getCategory(product),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    formatPrice(product['price']),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ALL PAINTINGS CARD
  Widget buildProductCard(dynamic product) {
    return InkWell(
      onTap: () => openProductDetail(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEDF0F2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                width: double.infinity,
                child: productImage(
                  product['imageUrl']?.toString(),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      getCategory(product),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatPrice(product['price']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
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

  // HOME BANNER
  Widget buildBanner() {
    return Container(
      width: double.infinity,
      height: 175,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDDF3FF),
            Color(0xFFBCE6FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(
              Icons.palette_outlined,
              size: 125,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ART FOR YOUR SPACE',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Discover Art,\nExpress Your Space.',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Find beautiful paintings for your home.',
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.homeBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 85,
        titleSpacing: 20,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, Art Lover!',
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Arsora.',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: openCart,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),

      // HOME CONTENT
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: getProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search paintings or categories...',
                      hintStyle: AppTextStyles.subtitle.copyWith(
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFEDF0F2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: AppColors.secondary,
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // BANNER
                  buildBanner(),

                  const SizedBox(height: 27),

                  // FEATURED PAINTINGS
                  sectionTitle(
                    'Featured Paintings',
                    subtitle: 'Selected artworks for your space',
                  ),

                  if (isLoading)
                    const SizedBox(
                      height: 235,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (popularProducts.isEmpty)
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text('No featured paintings found.'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 245,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularProducts.length,
                        itemBuilder: (context, index) {
                          return buildPopularCard(
                            popularProducts[index],
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 27),

                  // ALL PAINTINGS
                  sectionTitle(
                    'All Paintings',
                    subtitle: '${allProducts.length} artworks available',
                  ),

                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (allProducts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Text('No products found.'),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        return buildProductCard(
                          allProducts[index],
                        );
                      },
                    ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
