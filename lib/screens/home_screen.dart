import 'dart:async';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/quota_provider.dart';
import '../providers/process_text_provider.dart';
import '../services/process_text_service.dart';
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

  final List<Widget> _tabs = [
    VibeTranslateTab(),
    DirectSearchTab(),
    LibraryScreen(),
  ];

  StreamSubscription<String>? _selectionSub;

  @override
  void initState() {
    super.initState();
    // Launched from another app's selection menu — land on Direct Search so the
    // pending lookup is visible as it runs.
    if (ref.read(pendingLookupProvider) != null) _currentIndex = 1;

    // Selections that arrive while the app is already open.
    _selectionSub = ProcessTextService.instance.textStream.listen((text) {
      if (!mounted) return;
      setState(() => _currentIndex = 1);
      ref.read(pendingLookupProvider.notifier).set(text);
    });

    // Listen for rating prompt after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(showRatingPromptProvider, (_, shouldShow) {
        if (shouldShow && mounted) {
          _showRatingSnackBar();
          ref.read(showRatingPromptProvider.notifier).set(false);
        }
      });
    });
  }

  @override
  void dispose() {
    _selectionSub?.cancel();
    super.dispose();
  }

  void _showRatingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.colors.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Enjoying Context? A quick rating really helps us!',
                style: TextStyle(color: context.colors.ink, fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Rate Us',
          textColor: context.colors.accent2,
          onPressed: () {
            launchUrl(
              Uri.parse(
                'https://play.google.com/store/apps/details?id=com.context.dictv1',
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
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.gear_alt_fill,
              color: context.colors.inkSoft,
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
          Divider(height: 1, color: context.colors.border),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: context.colors.bg,
              selectedItemColor: context.colors.ink,
              unselectedItemColor: context.colors.inkSoft,
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
          return LinearGradient(
            colors: [context.colors.accent, context.colors.accent2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(iconData, size: 26, color: context.colors.ink),
      );
    }
    return Icon(iconData, size: 22);
  }
}
