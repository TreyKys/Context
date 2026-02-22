import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ContextDictionaryApp());
}

class ContextDictionaryApp extends StatelessWidget {
  const ContextDictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Context Dictionary',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Dark background
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
