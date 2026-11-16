
import 'package:arsora_mobile/pages/product.dart';
import 'package:arsora_mobile/pages/explore.dart';
import 'package:arsora_mobile/pages/home.dart';
import 'package:arsora_mobile/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/appColors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  String role = 'user';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      role = prefs.getString('role') ?? 'user';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isAdmin = role == 'admin';

    final pages = isAdmin
        ? [
            Home(),
            Explore(),
            Product(),
            Profile(),
          ]
        : [
            Home(),
            Explore(),
            Profile(),
          ];

    final items = [
      SalomonBottomBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        title: const Text('Home'),
        selectedColor: AppColors.primary,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.explore_outlined),
        activeIcon: const Icon(Icons.explore),
        title: const Text('Explore'),
        selectedColor: AppColors.primary,
      ),
      if (isAdmin)
        SalomonBottomBarItem(
          icon: const Icon(Icons.inventory_2_outlined),
          activeIcon: const Icon(Icons.inventory_2),
          title: const Text('Product'),
          selectedColor: AppColors.primary,
        ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        title: const Text('Profile'),
        selectedColor: AppColors.primary,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade400,
        selectedColorOpacity: 0.12,
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        itemPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        items: items,
      ),
    );
  }
}
