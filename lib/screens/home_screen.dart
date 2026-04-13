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

  final List<Widget> _tabs = const [VibeTranslateTab(), DirectSearchTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10), // Obsidian
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF0B0C10), // Obsidian
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade700,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(CupertinoIcons.sparkles, 0),
              label: 'Vibe Translate',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(CupertinoIcons.search, 1),
              label: 'Direct Search',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData iconData, int index) {
    if (_currentIndex == index) {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Colors.purpleAccent, Color(0xFF0B0C10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(iconData, size: 28, color: Colors.white),
      );
    }
    return Icon(iconData, size: 24);
  }
}
