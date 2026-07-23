import '../theme/app_theme.dart';
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
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: context.colors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: context.colors.ink.withValues(alpha: 0.06),
              blurRadius: 18.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: context.colors.accent, // Electric Cyan
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Cross-referencing sources...',
              style: TextStyle(
                color: context.colors.inkSoft,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .shimmer(duration: 1500.ms, color: context.colors.accent.withValues(alpha: 0.1))
       .fade(begin: 0.7, end: 1.0, duration: 800.ms);
    }

    if (error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'Decryption Failed: Signal Lost or High Network Traffic.',
              style: TextStyle(
                color: context.colors.ink,
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
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: context.colors.surfaceAlt,
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
      SnackBar(
        content: Text('Copied & ready to share!'),
        duration: Duration(seconds: 2),
        backgroundColor: context.colors.surfaceAlt,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.colors.ink.withValues(alpha: 0.06),
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
              color: context.colors.inkSoft,
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
                textStyle: TextStyle(
                  color: context.colors.ink,
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
            style: TextStyle(
              color: context.colors.accent,
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
                      ? context.colors.ink
                      : context.colors.accent2,
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
                color: context.colors.ink.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: context.colors.ink.withValues(alpha: 0.1)),
              ),
              child: AnimatedTextKit(
                key: ValueKey('example_${result.exampleSentence}'),
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    result.exampleSentence,
                    textStyle: TextStyle(
                      color: context.colors.ink.withValues(alpha: 0.7),
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
                  gradient: LinearGradient(
                    colors: [context.colors.accent, context.colors.bg],
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
                    color: context.colors.bg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag.startsWith('#') ? tag : '#$tag',
                    style: TextStyle(
                      color: context.colors.inkSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          Divider(color: context.colors.border, thickness: 1),
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
                color: isSaved ? context.colors.accent2 : context.colors.inkSoft!,
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
                color: context.colors.inkSoft!,
                onTap: () => _copyToClipboard(context),
              ),
              _ActionButton(
                icon: CupertinoIcons.share,
                label: 'Share',
                color: context.colors.inkSoft!,
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
                  color: context.colors.inkSoft,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Fact-checked against Wikipedia & Dictionary',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.inkSoft,
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
        backgroundColor: context.colors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Library Full',
          style: TextStyle(color: context.colors.ink),
        ),
        content: Text(
          'Free accounts can save up to 10 words. Upgrade to Premium for unlimited library access.',
          style: TextStyle(color: context.colors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Maybe Later', style: TextStyle(color: context.colors.inkSoft)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // SubscriptionScreen push handled by caller if needed
            },
            child: Text(
              'Go Premium',
              style: TextStyle(color: context.colors.accent),
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
