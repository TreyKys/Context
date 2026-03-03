import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibe_provider.dart';
import '../widgets/result_card.dart';

class VibeTranslateTab extends ConsumerStatefulWidget {
  const VibeTranslateTab({super.key});

  @override
  ConsumerState<VibeTranslateTab> createState() => _VibeTranslateTabState();
}

class _VibeTranslateTabState extends ConsumerState<VibeTranslateTab> {
  String? _selectedMode = 'Define';
  String? _selectedContext = 'Gen Z / TikTok Slang';
  final TextEditingController _controller = TextEditingController();

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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _handleSearch() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    ref
        .read(vibeProvider.notifier)
        .generateVibe(input, _selectedMode!, _selectedContext!);
  }

  @override
  Widget build(BuildContext context) {
    // Determine greeting based on current time
    final greeting = _getGreeting();
    final vibeState = ref.watch(vibeProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Greeting
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What would you like to know?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE3E3E3), // Light grey text
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),

            // Prompt Box Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0C10), // Obsidian
                borderRadius: BorderRadius.circular(32), // Heavily rounded
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
                children: [
                  // Input Field
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Enter a word or phrase...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: Colors.cyanAccent,
                        ),
                        onPressed: _handleSearch,
                      ),
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _handleSearch(),
                  ),
                  const SizedBox(height: 20),

                  // Controls Row
                  Row(
                    children: [
                      // Left Control (Mode)
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

                      // Right Control (Context)
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

            const SizedBox(height: 32),

            // Result Area
            ResultCard(
              isLoading: vibeState.isLoading,
              result: vibeState.result,
              error: vibeState.error,
            ),

            // Bottom spacing
            const SizedBox(height: 80),
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
                  Text(item),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
