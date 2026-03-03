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
        scaffoldBackgroundColor: const Color(0xFF0B0C10), // Obsidian background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0C10),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0B0C10),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
        ),
      ).copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
