
import 'package:flutter/material.dart';

import '../theme/appColors.dart';
import '../theme/appTextStyles.dart';
import '../service/api.dart';
import '../pages/product_detail.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isAdmin;
  final VoidCallback? onRefresh;

  const ProductCard({
    super.key,
    required this.product,
    required this.isAdmin,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? '';
    final category = product['category']?.toString() ?? '';
    final price = product['price']?.toString() ?? '0';
    final image = product['imageUrl']?.toString() ?? '';

    Future<void> addToCart() async {
      try {
        await ApiService.post('/cart', {
          'productId': product['id'],
          'quantity': 1,
        });

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added to cart successfully'),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              product: product,
              isAdmin: isAdmin,
              onAddToCart: isAdmin ? null : addToCart,
            ),
          ),
        );

        if (result == true) {
          onRefresh?.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image_outlined,
                          );
                        },
                      )
                    : const Icon(Icons.image_outlined),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    price,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
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
}
