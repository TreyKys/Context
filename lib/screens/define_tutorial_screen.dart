import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Teaches the "Define" selection-menu feature.
///
/// This is the app's best feature and also its least discoverable — nothing in
/// the UI hints that Context lives inside every other app's text selection
/// menu. It's shown once after onboarding and stays reachable from Settings.
class DefineTutorialScreen extends StatelessWidget {
  final VoidCallback? onDone;
  const DefineTutorialScreen({super.key, this.onDone});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () =>
                      onDone != null ? onDone!() : Navigator.pop(context),
                  child: Icon(CupertinoIcons.xmark,
                      color: colors.inkSoft, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [colors.accent, colors.accent2],
                ).createShader(b),
                child: Icon(CupertinoIcons.text_cursor,
                    size: 44, color: colors.ink),
              ).animate().fadeIn(duration: 400.ms).scale(),
              const SizedBox(height: 18),
              Text(
                'Define anything,\nwithout leaving the app',
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Reading a post, an article, a message? You never have to come '
                'back here to look a word up.',
                style: TextStyle(
                    color: colors.inkSoft, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              ..._steps.asMap().entries.map(
                    (e) => _Step(
                      number: e.key + 1,
                      title: e.value.$1,
                      body: e.value.$2,
                    )
                        .animate(delay: (120 * e.key).ms)
                        .fadeIn()
                        .slideY(begin: 0.08, end: 0),
                  ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.lightbulb_fill,
                            size: 15, color: colors.accent2),
                        const SizedBox(width: 8),
                        Text('Can\'t find "Define"?',
                            style: TextStyle(
                                color: colors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the ⋮ (three dots) at the end of the selection menu — '
                      'Android hides extra options there when the bar is full.',
                      style: TextStyle(
                          color: colors.inkSoft, fontSize: 12.5, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () =>
                    onDone != null ? onDone!() : Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.accent, colors.accent2],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Got it',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.bg,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _steps = <(String, String)>[
  (
    'Select the word',
    'Long-press any word in any app — X, WhatsApp, Chrome, your email. '
        'Drag the handles to grab a whole phrase if you want.',
  ),
  (
    'Tap "Define"',
    'It appears in the same menu as Copy and Share. Nothing to open, '
        'no permission to grant.',
  ),
  (
    'Read, then carry on',
    'A small card floats over what you were reading. Tap anywhere outside '
        'to dismiss it and go straight back — you never lose your place.',
  ),
];

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  const _Step({required this.number, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
            ),
            child: Text('$number',
                style: TextStyle(
                    color: colors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: colors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(body,
                    style: TextStyle(
                        color: colors.inkSoft, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
