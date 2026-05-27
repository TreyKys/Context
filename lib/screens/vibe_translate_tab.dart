import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibe_provider.dart';
import '../providers/quota_provider.dart';
import '../services/history_service.dart';
import '../services/quota_service.dart';
import '../widgets/result_card.dart';
import '../widgets/search_counter.dart';
import '../main.dart';

class VibeTranslateTab extends ConsumerStatefulWidget {
  const VibeTranslateTab({super.key});

  @override
  ConsumerState<VibeTranslateTab> createState() => _VibeTranslateTabState();
}

class _VibeTranslateTabState extends ConsumerState<VibeTranslateTab> {
  String? _selectedMode = 'Define';
  String? _selectedContext = 'Gen Z / TikTok Slang';
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  String _lastSearchedWord = '';
  bool _showHistory = false;
  List<HistoryEntry> _history = [];

  final List<String> _modes = ['Define', 'Roast', 'Explain Like I\'m 5'];

  final List<String> _contexts = [
    'Gen Z / TikTok Slang',
    'Corporate Executive',
    'Web3 Degen',
    'Smart Money Trader',
    'Clinical Pharmacist',
    'Cybersecurity Analyst',
    'Synthetic Chemist',
    'Academic Scholar',
    'Tech Startup Founder',
    'Boomer on Facebook',
    'Passive-Aggressive Colleague',
    '90s Hacker',
    'Fitness Influencer',
    'Fantasy RPG NPC',
    'Legalese / Lawyer',
    'Overly Dramatic Reality Star',
    'Doomsday Prepper',
    'Art Critic',
    'Exhausted Parent',
    'Lagos Uncle / Aunty',
    'Victorian Aristocrat',
    'Gritty Noir Detective',
    'Sweaty Esports Gamer',
    'Existential Philosopher',
    'Wild Card (Auto-Detect)',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _loadHistory();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPayload();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadHistory() {
    final history = HistoryService().getHistory();
    setState(() {
      _history = history.where((e) => !e.isDirectSearch).take(8).toList();
      _showHistory = history.isNotEmpty && _controller.text.isEmpty;
    });
  }

  void _checkNotificationPayload() {
    final payload = ref.read(initialNotificationPayloadProvider);
    if (payload != null && payload.isNotEmpty) {
      _controller.text = payload;
      _handleSearch();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _handleSearch() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    final vibeState = ref.read(vibeProvider);
    if (vibeState.isLoading) return;

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    setState(() {
      _lastSearchedWord = input;
      _showHistory = false;
    });

    await HistoryService().addEntry(HistoryEntry(
      word: input,
      mode: _selectedMode ?? 'Define',
      persona: _selectedContext ?? '',
      isDirectSearch: false,
      timestamp: DateTime.now(),
    ));

    ref
        .read(vibeProvider.notifier)
        .generateVibe(input, _selectedMode!, _selectedContext!);
  }

  void _fillFromHistory(HistoryEntry entry) {
    _controller.text = entry.word;
    if (_modes.contains(entry.mode)) {
      setState(() => _selectedMode = entry.mode);
    }
    if (_contexts.contains(entry.persona)) {
      setState(() => _selectedContext = entry.persona);
    }
    setState(() => _showHistory = false);
    _handleSearch();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final vibeState = ref.watch(vibeProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'What would you like to know?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE3E3E3),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 28),

            // Input container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0C10),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.shade800, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    offset: const Offset(0, 4),
                  ),
                  const BoxShadow(
                    color: Colors.purpleAccent,
                    blurRadius: 8.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Enter a word or phrase...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: Colors.cyanAccent,
                        ),
                        onPressed: _handleSearch,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                       _debounce?.cancel();
                       _handleSearch();
                    },
                    onChanged: (v) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _showHistory = v.isEmpty && _history.isNotEmpty;
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedMode,
                          items: _modes,
                          onChanged: (val) =>
                              setState(() => _selectedMode = val),
                          icon: CupertinoIcons.gear,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedContext,
                          items: _contexts,
                          onChanged: (val) =>
                              setState(() => _selectedContext = val),
                          icon: CupertinoIcons.person_2,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    onTap: () => _fillFromHistory(entry),
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
                          Text(
                            entry.word,
                            style: const TextStyle(
                              color: Color(0xFFBBBBBB),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Empty state hint
            if (!vibeState.isLoading &&
                vibeState.result == null &&
                vibeState.error == null &&
                !vibeState.isQuotaLocked) ...[
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.sparkles,
                        size: 32, color: Colors.grey[800]),
                    const SizedBox(height: 12),
                    Text(
                      'Try  "rizz",  "HODL",  or  "synergy"',
                      style:
                          TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Result
            ResultCard(
              isLoading: vibeState.isLoading,
              result: vibeState.result,
              error: vibeState.error,
              isQuotaLocked: vibeState.isQuotaLocked,
              searchWord: _lastSearchedWord.isNotEmpty
                  ? _lastSearchedWord
                  : null,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          dropdownColor: const Color(0xFF0B0C10),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.purpleAccent, Color(0xFF0B0C10)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Icon(icon, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text(item, overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
