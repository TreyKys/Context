import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 40),
            const SizedBox(height: 16),
            const Text(
              'Signal Lost: Verify Prompt Format',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (error!.isNotEmpty && error != 'null') ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(
                  color: Colors.redAccent.shade100,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
        color: const Color(0xFF050505), // Obsidian
        borderRadius: BorderRadius.circular(32), // Heavily rounded
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
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
          Text(
            result!.literalDefinition,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Vibe Translation Header
          const Text(
            'VIBE TRANSLATION',
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Vibe Translation Content (The Pop)
          Text(
            result!.vibeTranslation,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),

          // Example Sentence Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              result!.exampleSentence,
              style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result!.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.grey[800]!),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
