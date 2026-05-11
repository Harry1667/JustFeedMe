
import 'package:flutter/material.dart';
import 'package:forkit_mobile/home_screen.dart';

void main() {
  print('🚀 App Starting...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forkit Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default but explicit
      ),
      home: const HomeScreen(),
    );
  }
}
