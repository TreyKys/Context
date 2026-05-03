import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/quota_provider.dart';
import 'vibe_translate_tab.dart';
import 'direct_search_tab.dart';
import 'library_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    VibeTranslateTab(),
    DirectSearchTab(),
    LibraryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen for rating prompt after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<bool>(showRatingPromptProvider, (_, shouldShow) {
        if (shouldShow && mounted) {
          _showRatingSnackBar();
          ref.read(showRatingPromptProvider.notifier).state = false;
        }
      });
    });
  }

  void _showRatingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Enjoying Context? A quick rating really helps us!',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Rate Us',
          textColor: Colors.cyanAccent,
          onPressed: () {
            launchUrl(
              Uri.parse(
                'https://play.google.com/store/apps/details?id=com.context.dict.v1',
              ),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C10),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.gear_alt_fill,
              color: Colors.grey,
              size: 22,
            ),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: Colors.grey.shade900),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: const Color(0xFF0B0C10),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade700,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: _buildIcon(CupertinoIcons.sparkles, 0),
                  label: 'Vibe',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(CupertinoIcons.search, 1),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(CupertinoIcons.book, 2),
                  label: 'Library',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData iconData, int index) {
    if (_currentIndex == index) {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Colors.purpleAccent, Colors.cyanAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(iconData, size: 26, color: Colors.white),
      );
    }
    return Icon(iconData, size: 22);
  }
}
