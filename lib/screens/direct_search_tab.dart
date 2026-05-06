import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibe_provider.dart';
import '../providers/quota_provider.dart';
import '../services/history_service.dart';
import '../services/quota_service.dart';
import '../widgets/result_card.dart';
import '../widgets/search_counter.dart';

const List<String> _kDomainContexts = [
  'General / All Topics',
  'Internet & Memes',
  'Gen Z & TikTok Slang',
  'Medical & Clinical',
  'Legal & Law',
  'Finance & Investing',
  'Crypto & Web3',
  'Technology & Software',
  'Food & Culinary',
  'Gaming',
  'Sports & Athletics',
  'Academic & Research',
  'Science & Biology',
  'Business & Corporate',
  'Fitness & Wellness',
  'Social Media & Influencer',
  'Pop Culture & Entertainment',
  'Music & Hip-Hop',
  'Film & Television',
  'Fashion & Beauty',
  'LGBTQ+ Culture',
  'Politics & Government',
  'Military & Defense',
  'Religion & Spirituality',
  'Environment & Climate',
  'Philosophy & Ethics',
  'History & Historical',
  'Architecture & Design',
  'Real Estate & Property',
  'Mental Health & Psychology',
  'Automotive & Cars',
  'Travel & Tourism',
  'Parenting & Family',
];

class DirectSearchTab extends ConsumerStatefulWidget {
  const DirectSearchTab({super.key});

  @override
  ConsumerState<DirectSearchTab> createState() => _DirectSearchTabState();
}

class _DirectSearchTabState extends ConsumerState<DirectSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _lastSearchedWord = '';
  bool _showHistory = false;
  List<HistoryEntry> _history = [];
  String _selectedContext = _kDomainContexts.first;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!mounted) return;
      if (_focusNode.hasFocus) _loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadHistory() {
    final history = HistoryService().getHistory();
    if (!mounted) return;
    setState(() {
      _history = history.where((e) => e.isDirectSearch).take(8).toList();
      _showHistory = history.isNotEmpty && _searchController.text.isEmpty;
    });
  }

  Future<void> _performSearch() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    final vibeState = ref.read(directSearchProvider);
    if (vibeState.isLoading) return;

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    setState(() {
      _lastSearchedWord = input;
      _showHistory = false;
    });

    await HistoryService().addEntry(HistoryEntry(
      word: input,
      mode: '',
      persona: _selectedContext,
      isDirectSearch: true,
      timestamp: DateTime.now(),
    ));

    ref.read(directSearchProvider.notifier).directSearch(
      input,
      domain: _selectedContext,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vibeState = ref.watch(directSearchProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Direct Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Objective definitions with etymology & context',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0C10),
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
                  color: Colors.purpleAccent.withValues(alpha: 0.2),
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
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Search for a definition...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: Colors.purpleAccent,
                        ),
                        onPressed: _performSearch,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                    onChanged: (v) {
                      if (!mounted) return;
                      setState(() {
                        _showHistory = v.isEmpty && _history.isNotEmpty;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Context dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0C10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedContext,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                dropdownColor: const Color(0xFF111118),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedContext = val);
                },
                items: _kDomainContexts.map((ctx) {
                  return DropdownMenuItem<String>(
                    value: ctx,
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Colors.purpleAccent, Colors.cyanAccent],
                          ).createShader(b),
                          child: const Icon(
                            CupertinoIcons.tag_fill,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            ctx,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Search counter — free tier only
          SearchCounter(isPremium: ref.read(quotaServiceProvider).isPremium),

          // History chips
          if (_showHistory && _history.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'RECENT',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _history.map((entry) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = entry.word;
                    setState(() => _showHistory = false);
                    _performSearch();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111118),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFF2A2A3E)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.clock,
                            size: 11, color: Colors.grey[600]),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            entry.word,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFFBBBBBB), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Empty state
          if (!vibeState.isLoading &&
              vibeState.result == null &&
              vibeState.error == null &&
              !vibeState.isQuotaLocked) ...[
            const SizedBox(height: 56),
            Center(
              child: Column(
                children: [
                  Icon(CupertinoIcons.search, size: 32, color: Colors.grey[800]),
                  const SizedBox(height: 12),
                  Text(
                    'Try  "sonder",  "liminal",  or  "gaslighting"',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Result
          ResultCard(
            isLoading: vibeState.isLoading,
            result: vibeState.result,
            error: vibeState.error,
            isQuotaLocked: vibeState.isQuotaLocked,
            searchWord: _lastSearchedWord.isNotEmpty ? _lastSearchedWord : null,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
