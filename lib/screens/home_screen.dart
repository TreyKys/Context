import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'vibe_translate_tab.dart';
import 'direct_search_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    VibeTranslateTab(),
    DirectSearchTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131314), // Darker background like Gemini
      body: SafeArea(
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E1F20),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.sparkles),
            label: 'Vibe Translate',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Direct Search',
          ),
        ],
      ),
    );
  }
}
