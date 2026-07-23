import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/vibe_result.dart';
import '../providers/library_provider.dart';
import 'paywall_card.dart';

class ResultCard extends ConsumerWidget {
  final VibeResult? result;
  final String? error;
  final bool isLoading;
  final bool isQuotaLocked;
  final String? searchWord;

  const ResultCard({
    super.key,
    this.result,
    this.error,
    this.isLoading = false,
    this.isQuotaLocked = false,
    this.searchWord,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isQuotaLocked) return const PaywallCard();

    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF6EC),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFE2D8C4), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A2521).withValues(alpha: 0.06),
              blurRadius: 18.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Color(0xFFB07A47), // Electric Cyan
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Cross-referencing sources...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .shimmer(duration: 1500.ms, color: const Color(0xFFB07A47).withValues(alpha: 0.1))
       .fade(begin: 0.7, end: 1.0, duration: 800.ms);
    }

    if (error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF2DAD3),
          borderRadius: BorderRadius.circular(32),
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
                color: Color(0xFF2A2521),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
    }

    if (result == null) return const SizedBox.shrink();

    return _ResultContent(result: result!, searchWord: searchWord)
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _ResultContent extends ConsumerWidget {
  final VibeResult result;
  final String? searchWord;

  const _ResultContent({required this.result, this.searchWord});

  void _copyToClipboard(BuildContext context) {
    final text =
        '"${searchWord ?? ''}" — ${result.literalDefinition}\n\n${result.vibeTranslation}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFEAE0CE),
      ),
    );
  }

  void _shareDefinition(BuildContext context) {
    final word = searchWord ?? '';
    final text =
        '🧠 "$word" — via The Context Dictionary\n\n'
        '${result.literalDefinition}\n\n'
        '${result.isDirectSearch ? '' : '${result.vibeTranslation}\n\n'}'
        '${result.tags.map((t) => t.startsWith('#') ? t : '#$t').join(' ')}';
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied & ready to share!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFEAE0CE),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = searchWord ?? '';
    final savedAsync = word.isNotEmpty
        ? ref.watch(isWordSavedProvider(word.trim().toLowerCase()))
        : const AsyncData(false);
    final isSaved = savedAsync.asData?.value ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EC),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2D8C4), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A2521).withValues(alpha: 0.06),
            blurRadius: 18.0,
            offset: const Offset(0, 8),
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
          AnimatedTextKit(
            key: ValueKey('literal_${result.literalDefinition}'),
            isRepeatingAnimation: false,
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
            animatedTexts: [
              TypewriterAnimatedText(
                result.literalDefinition,
                textStyle: const TextStyle(
                  color: Color(0xFF2A2521),
                  fontSize: 16,
                  height: 1.4,
                ),
                speed: const Duration(milliseconds: 10),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Vibe Translation / Etymology Header
          Text(
            result.isDirectSearch ? 'ETYMOLOGY & CONTEXT' : 'VIBE TRANSLATION',
            style: const TextStyle(
              color: Color(0xFFB07A47),
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedTextKit(
            key: ValueKey('vibe_${result.vibeTranslation}'),
            isRepeatingAnimation: false,
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
            animatedTexts: [
              TypewriterAnimatedText(
                result.vibeTranslation,
                textStyle: TextStyle(
                  color: result.isDirectSearch
                      ? const Color(0xFF2A2521)
                      : Color(0xFFCDA15F),
                  fontSize: result.isDirectSearch ? 16 : 24,
                  fontWeight: result.isDirectSearch
                      ? FontWeight.normal
                      : FontWeight.bold,
                  height: 1.4,
                  letterSpacing: result.isDirectSearch ? 0 : -0.5,
                ),
                speed: const Duration(milliseconds: 15),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Example Sentence (Vibe only)
          if (!result.isDirectSearch) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2A2521).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Color(0xFF2A2521).withValues(alpha: 0.1)),
              ),
              child: AnimatedTextKit(
                key: ValueKey('example_${result.exampleSentence}'),
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    result.exampleSentence,
                    textStyle: const TextStyle(
                      color: Color(0xB32A2521),
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
            children: result.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB07A47), Color(0xFFF2EBDD)],
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
                    color: const Color(0xFFF2EBDD),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag.startsWith('#') ? tag : '#$tag',
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2D8C4), thickness: 1),
          const SizedBox(height: 12),

          // Action Row: Save | Copy | Share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: isSaved
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                label: isSaved ? 'Saved' : 'Save',
                color: isSaved ? Color(0xFFCDA15F) : Colors.grey[500]!,
                onTap: word.isEmpty
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        if (isSaved) {
                          await ref
                              .read(libraryProvider.notifier)
                              .deleteByWord(word);
                        } else {
                          final error = await ref
                              .read(libraryProvider.notifier)
                              .saveWord(result, word);
                          if (error == 'library_limit' && context.mounted) {
                            _showLibraryLimitDialog(context);
                          }
                        }
                      },
              ),
              _ActionButton(
                icon: CupertinoIcons.doc_on_clipboard,
                label: 'Copy',
                color: Colors.grey[500]!,
                onTap: () => _copyToClipboard(context),
              ),
              _ActionButton(
                icon: CupertinoIcons.share,
                label: 'Share',
                color: Colors.grey[500]!,
                onTap: () => _shareDefinition(context),
              ),
            ],
          ),

          // Verified badge
          if (result.isVerified) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  size: 11,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Fact-checked against Wikipedia & Dictionary',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showLibraryLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF2EBDD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Library Full',
          style: TextStyle(color: Color(0xFF2A2521)),
        ),
        content: Text(
          'Free accounts can save up to 10 words. Upgrade to Premium for unlimited library access.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // SubscriptionScreen push handled by caller if needed
            },
            child: const Text(
              'Go Premium',
              style: TextStyle(color: Color(0xFFB07A47)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.3 : 1.0,
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
