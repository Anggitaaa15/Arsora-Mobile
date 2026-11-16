import 'package:arsora_mobile/pages/category_products.dart';
import 'package:arsora_mobile/pages/product.dart';
import 'package:arsora_mobile/pages/explore.dart';
import 'package:arsora_mobile/pages/home.dart';
import 'package:arsora_mobile/pages/login.dart';
import 'package:arsora_mobile/pages/profile.dart';
import 'package:arsora_mobile/pages/register.dart';
import 'package:arsora_mobile/pages/splashScreen.dart';
import 'package:arsora_mobile/widgets/bottomBar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
      ),

      routes: {
        "/splashScreen": (context) => SplashScreen(),
        "/login": (context) => Login(),
        "/register":(context) => Register(),
        "/home":(context) => MainNavigation(),
        "/explore": (context) => Explore(),
        "/product":(context) => Product(),
        "/profile":(context) => Profile(),
      },
      initialRoute: "/splashScreen",
    );
  }
}