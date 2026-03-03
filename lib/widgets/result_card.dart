import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/vibe_result.dart';

class ResultCard extends StatelessWidget {
  final VibeResult? result;
  final String? error;
  final bool isLoading;

  const ResultCard({
    super.key,
    this.result,
    this.error,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Loading State
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            color: Colors.cyanAccent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Error State
    if (error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2A0000), // Dark red bg
          borderRadius: BorderRadius.circular(32), // Heavily rounded
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 16),
            const Text(
              'Decryption Failed: Signal Lost or High Network Traffic.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
    }

    // Empty State
    if (result == null) return const SizedBox.shrink();

    // Success State
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Literal Definition Header
          Text(
            'LITERAL DEFINITION',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Literal Definition Content
          AnimatedTextKit(
            key: ValueKey('literal_${result!.literalDefinition}'),
            isRepeatingAnimation: false,
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
            animatedTexts: [
              TypewriterAnimatedText(
                result!.literalDefinition,
                textStyle: const TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 16,
                  height: 1.4,
                ),
                speed: const Duration(milliseconds: 10),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Vibe Translation / Etymology Context Header
          Text(
            result!.isDirectSearch ? 'ETYMOLOGY & CONTEXT' : 'VIBE TRANSLATION',
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Vibe Translation / Etymology Content
          AnimatedTextKit(
            key: ValueKey('vibe_${result!.vibeTranslation}'),
            isRepeatingAnimation: false,
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
            animatedTexts: [
              TypewriterAnimatedText(
                result!.vibeTranslation,
                textStyle: TextStyle(
                  color: result!.isDirectSearch
                      ? const Color(0xFFE0E0E0)
                      : Colors.cyanAccent,
                  fontSize: result!.isDirectSearch ? 16 : 24,
                  fontWeight: result!.isDirectSearch
                      ? FontWeight.normal
                      : FontWeight.bold,
                  height: 1.4,
                  letterSpacing: result!.isDirectSearch ? 0 : -0.5,
                ),
                speed: const Duration(milliseconds: 15),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Example Sentence Box (Only for Vibe Translate mode)
          if (!result!.isDirectSearch) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: AnimatedTextKit(
                key: ValueKey('example_${result!.exampleSentence}'),
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    result!.exampleSentence,
                    textStyle: const TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    speed: const Duration(milliseconds: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result!.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.all(1), // Space for gradient border
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    colors: [Colors.purpleAccent, Color(0xFF0B0C10)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0B0C10,
                    ), // Solid Obsidian background inside chip
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag.startsWith('#') ? tag : '#$tag',
                    style: TextStyle(
                      color: Colors.grey[200], // Crisp light grey / white text
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
