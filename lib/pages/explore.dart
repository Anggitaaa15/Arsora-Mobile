
import 'package:flutter/material.dart';
import '../theme/appColors.dart';
import 'category_products.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  final List<Map<String, dynamic>> leftCategories = const [
    {
      'name': 'Minimalist',
      'image': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5',
      'height': 168.0,
    },
    {
      'name': 'Landscape',
      'image': 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e',
      'height': 168.0,
    },
    {
      'name': 'Meaningful Art',
      'image': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262',
      'height': 176.0,
    },
  ];

  final List<Map<String, dynamic>> rightCategories = const [
    {
      'name': 'Abstract',
      'image': 'https://images.unsplash.com/photo-1549490349-8643362247b5',
      'height': 128.0,
    },
    {
      'name': 'Botanical',
      'image': 'https://images.unsplash.com/photo-1490750967868-88aa4486c946',
      'height': 168.0,
    },
    {
      'name': 'Vintage',
      'image': 'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342',
      'height': 104.0,
    },
    {
      'name': 'Rare Collections',
      'image': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119',
      'height': 104.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 24),
                child: Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: leftCategories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: CategoryCard(category: category),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: rightCategories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: CategoryCard(category: category),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProducts(
              categoryName: category['name'],
            ),
          ),
        );
      },
      child: Container(
        height: category['height'],
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.secondary,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              category['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.secondary);
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 8,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Explore artworks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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
