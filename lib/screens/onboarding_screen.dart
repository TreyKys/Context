import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EBDD),
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: _currentPage < 2
                    ? GestureDetector(
                        onTap: widget.onDone,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox(height: 20),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [
                  _OnboardPage1(),
                  _OnboardPage2(),
                  _OnboardPage3(),
                ],
              ),
            ),

            // Dots + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: active ? Color(0xFFB07A47) : Colors.grey[700],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // CTA button
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB07A47), Color(0xFFCDA15F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFB07A47).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage < 2 ? 'Next' : 'Get Started',
                          style: const TextStyle(
                            color: Color(0xFF2A2521),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage1 extends StatelessWidget {
  const _OnboardPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFB07A47), Color(0xFFCDA15F)],
            ).createShader(b),
            child: const Icon(
              CupertinoIcons.sparkles,
              size: 72,
              color: Color(0xFF2A2521),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 32),
          const Text(
            'Welcome to\nThe Context Dictionary',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2A2521),
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'Words have context. Now you do too.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 12),
          Text(
            'AI-powered definitions that go beyond the dictionary — cultural context, slang, and real usage across 25 unique perspectives.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _OnboardPage2 extends StatelessWidget {
  const _OnboardPage2();

  static const _personas = [
    ('Gen Z / TikTok Slang', CupertinoIcons.flame_fill, Colors.orange),
    ('Corporate Executive', CupertinoIcons.briefcase_fill, Colors.blue),
    ('Web3 Degen', CupertinoIcons.chart_bar_fill, Colors.yellow),
    ('Exhausted Parent', CupertinoIcons.person_2_fill, Colors.pink),
    ('90s Hacker', CupertinoIcons.keyboard, Colors.green),
    ('Victorian Aristocrat', CupertinoIcons.star_fill, Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFCDA15F), Color(0xFFB07A47)],
            ).createShader(b),
            child: const Icon(
              CupertinoIcons.person_2_fill,
              size: 60,
              color: Color(0xFF2A2521),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 28),
          const Text(
            '25 Unique Perspectives',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2A2521),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Same word, completely different energy depending on who\'s explaining it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _personas
                .map(
                  (p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: (p.$3 as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: (p.$3 as Color).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(p.$2 as IconData, size: 12, color: p.$3 as Color),
                        const SizedBox(width: 6),
                        Text(
                          p.$1,
                          style: TextStyle(
                            color: (p.$3 as Color).withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _OnboardPage3 extends StatelessWidget {
  const _OnboardPage3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFB07A47), Color(0xFFCDA15F)],
            ).createShader(b),
            child: const Icon(
              CupertinoIcons.book_fill,
              size: 60,
              color: Color(0xFF2A2521),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 28),
          const Text(
            'Build Your\nWord Library',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2A2521),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Save any definition with one tap. Your personal glossary of every word that ever made you pause.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 28),
          ...[
            (CupertinoIcons.bell_fill, 'Daily Word of the Day at 10 AM'),
            (CupertinoIcons.checkmark_shield_fill, 'Fact-checked against Wikipedia'),
            (CupertinoIcons.square_stack_fill, 'Search from any app (Premium)'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(item.$1, color: Color(0xFFCDA15F), size: 16),
                  const SizedBox(width: 12),
                  Text(
                    item.$2,
                    style: const TextStyle(color: Color(0xFF2A2521), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'NeuroDev Labs — Building tools for curious minds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
}
