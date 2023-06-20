import 'package:flutter/material.dart';
import 'LoginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fish Data Collection',
      theme: ThemeData(
        primaryColor: const Color(0xFF27485D),
        primarySwatch: const MaterialColor(
          0xFF27485D,
          <int, Color>{
            50: Color(0xFFE6EEF3),
            100: Color(0xFFC2D6E1),
            200: Color(0xFF9BB9CF),
            300: Color(0xFF739CBE),
            400: Color(0xFF5187B1),
            500: Color(0xFF27485D), // Your desired color
            600: Color(0xFF1D3B4B),
            700: Color(0xFF163041),
            800: Color(0xFF0F2638),
            900: Color(0xFF08182D),
          },
        ),
      ),
      home: const LoginPage(),
    );
  }
}


