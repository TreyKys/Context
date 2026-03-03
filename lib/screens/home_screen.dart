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
        backgroundColor: const Color(0xFF0B0C10),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.sparkles),
            activeIcon: _buildGradientIcon(CupertinoIcons.sparkles),
            label: 'Vibe Translate',
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.search),
            activeIcon: _buildGradientIcon(CupertinoIcons.search),
            label: 'Direct Search',
          ),
        ],
      ),
    );
  }

  Widget _buildGradientIcon(IconData icon) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFF6A0DAD), Color(0xFF0B0C10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Icon(icon, color: Colors.white),
    );
  }
}
