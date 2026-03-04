import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibe_provider.dart';
import '../widgets/result_card.dart';

class DirectSearchTab extends ConsumerStatefulWidget {
  const DirectSearchTab({super.key});

  @override
  ConsumerState<DirectSearchTab> createState() => _DirectSearchTabState();
}

class _DirectSearchTabState extends ConsumerState<DirectSearchTab> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    final input = _searchController.text.trim();
    if (input.isNotEmpty) {
      FocusScope.of(context).unfocus();
      ref.read(directSearchProvider.notifier).directSearch(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vibeState = ref.watch(directSearchProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0C10), // Obsidian
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade800),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.purpleAccent.withValues(alpha: 0.2), // The Glow
                  blurRadius: 8.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Icon(CupertinoIcons.search, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for a definition...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: Colors.purpleAccent,
                        ),
                        onPressed: _performSearch,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Result Card
          ResultCard(
            isLoading: vibeState.isLoading,
            result: vibeState.result,
            error: vibeState.error,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
