import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/llm_service.dart';

class DirectSearchTab extends StatefulWidget {
  const DirectSearchTab({super.key});

  @override
  State<DirectSearchTab> createState() => _DirectSearchTabState();
}

class _DirectSearchTabState extends State<DirectSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final LLMService _llmService = LLMService();
  bool _isLoading = false;
  bool _showResult = false;
  bool _hasError = false;
  Map<String, dynamic>? _resultData;

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _showResult = false;
      _isLoading = true;
      _hasError = false;
      _resultData = null;
    });

    final systemPrompt = "You are a hyper-intelligent linguistic and cultural analyst. The user is searching for: '$query'. Return a strict JSON object with no markdown backticks containing: 1. literal_meaning: A sharp, factual definition. 2. etymology_context: A breakdown of the word's origins or current cultural/professional usage. 3. tags: An array of 4 highly specific string tags (e.g., #Finance, #GenZ).";

    try {
      final response = await _llmService.generateContent(query, systemInstruction: systemPrompt);
      if (response != null) {
        final cleanJson = response.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(cleanJson);
        if (mounted) {
          setState(() {
            _resultData = data;
            _isLoading = false;
            _showResult = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A0DAD).withValues(alpha: 0.3), // Gradient glow
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a definition...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: const Icon(CupertinoIcons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(CupertinoIcons.arrow_right_circle_fill, color: Colors.blueAccent),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(height: 40),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: CircularProgressIndicator(color: Color(0xFF6A0DAD)),
            ),

          if (_hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0505), // Dark red background
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.redAccent.shade700),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Decryption Failed: Signal Lost or High Network Traffic.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1, end: 0),

          // Result Card (Animated)
          if (_showResult && _resultData != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade800),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A0DAD).withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Icon
                  Row(
                    children: [
                      const Icon(CupertinoIcons.book_fill, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _searchController.text,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Definition Text
                  AnimatedTextKit(
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                    totalRepeatCount: 1,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        _resultData!['literal_meaning'] ?? '',
                        speed: const Duration(milliseconds: 10), // very fast speed
                        textStyle: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Etymology Context
                  AnimatedTextKit(
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                    totalRepeatCount: 1,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        _resultData!['etymology_context'] ?? '',
                        speed: const Duration(milliseconds: 10), // very fast speed
                        textStyle: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFFC5C6C7), // Secondary Text: Dark Grey
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tags / Chips
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: (_resultData!['tags'] as List<dynamic>? ?? []).map((tag) {
                      return _buildChip(tag.toString(), CupertinoIcons.tag);
                    }).toList(),
                  ),
                ],
              ),
            )
            .animate()
            .fade(duration: 500.ms)
            .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A0DAD), Color(0xFF0B0C10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(1), // Border width
        decoration: BoxDecoration(
          color: const Color(0xFF0B0C10),
          borderRadius: BorderRadius.circular(19),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
