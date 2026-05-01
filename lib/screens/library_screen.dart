import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_word.dart';
import '../models/vibe_result.dart';
import '../providers/library_provider.dart';
import '../widgets/result_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'My Library',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your saved words & definitions',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111118),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E1E2E)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Icon(CupertinoIcons.search, color: Colors.grey[600], size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search your library...',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    child: Icon(CupertinoIcons.xmark_circle_fill,
                        color: Colors.grey[600], size: 16),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: libraryAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
              ),
              error: (_, __) => const Center(
                child: Text('Failed to load library', style: TextStyle(color: Colors.grey)),
              ),
              data: (words) {
                final filtered = _query.isEmpty
                    ? words
                    : words
                        .where(
                          (w) =>
                              w.word.toLowerCase().contains(_query.toLowerCase()) ||
                              w.literalDefinition
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()),
                        )
                        .toList();

                if (filtered.isEmpty) {
                  return _EmptyLibrary(isFiltered: _query.isNotEmpty);
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _LibraryCard(
                    word: filtered[i],
                    onTap: () => _showWordDetail(context, filtered[i]),
                    onDelete: () => ref
                        .read(libraryProvider.notifier)
                        .deleteWord(filtered[i].id!, filtered[i].word),
                  )
                      .animate(delay: (30 * i).ms)
                      .fadeIn()
                      .slideY(begin: 0.03, end: 0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWordDetail(BuildContext context, SavedWord word) {
    final result = VibeResult(
      literalDefinition: word.literalDefinition,
      vibeTranslation: word.vibeTranslation,
      exampleSentence: word.exampleSentence,
      tags: word.tags,
      isDirectSearch: word.isDirectSearch,
      isVerified: word.isVerified,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0C10),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                word.word,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ResultCard(result: result, searchWord: word.word),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final SavedWord word;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LibraryCard({
    required this.word,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111118),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1E1E2E)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        word.word,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (word.isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(
                          CupertinoIcons.checkmark_shield_fill,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.literalDefinition.length > 70
                        ? '${word.literalDefinition.substring(0, 70)}...'
                        : word.literalDefinition,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: word.tags.take(3).map((tag) {
                      return Text(
                        tag.startsWith('#') ? tag : '#$tag',
                        style: TextStyle(
                          color: Colors.purpleAccent.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.trash,
                  color: Colors.grey[700],
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final bool isFiltered;
  const _EmptyLibrary({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.book, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No results found' : 'Your library is empty',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try a different search term'
                : 'Search for words and tap the bookmark icon to save them here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
