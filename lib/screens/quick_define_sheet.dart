import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_config.dart';
import '../services/quota_service.dart';
import '../theme/app_theme.dart';
import 'package:firebase_ai/firebase_ai.dart';

/// The compact "Define" card shown by QuickDefineActivity.
///
/// Deliberately not the full app: the user selected a word while reading
/// something else, and should get an answer without losing their place. Tapping
/// outside dismisses straight back to whatever they were doing.
class QuickDefineSheet extends StatefulWidget {
  const QuickDefineSheet({super.key});

  @override
  State<QuickDefineSheet> createState() => _QuickDefineSheetState();
}

class _QuickDefineSheetState extends State<QuickDefineSheet> {
  static const MethodChannel _channel =
      MethodChannel('com.context.dictv1/quick_define');

  String? _word;
  String? _result;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _close() async {
    try {
      await _channel.invokeMethod('close');
    } catch (_) {}
  }

  Future<void> _openFullApp() async {
    try {
      await _channel.invokeMethod('openFullApp');
    } catch (_) {}
  }

  Future<void> _run() async {
    String? word;
    try {
      word = await _channel.invokeMethod<String>('getText');
    } catch (_) {}

    if (word == null || word.trim().isEmpty) {
      await _close();
      return;
    }
    if (mounted) setState(() => _word = word);

    // Same daily allowance as everywhere else in the app.
    final quota = QuotaService();
    try {
      await quota.init('anonymous');
    } catch (_) {}

    if (quota.availableSearches <= 0) {
      if (mounted) {
        setState(() {
          _error = 'You\'ve used your free lookups for today.';
          _loading = false;
        });
      }
      return;
    }

    try {
      final model = FirebaseAI.googleAI().generativeModel(model: kGeminiModel);
      final response = await model.generateContent([
        Content.text(
          'Define "$word" in 1-2 short sentences for quick reference. '
          'Include current slang or cultural usage if relevant. '
          'Plain text only, no markdown, no JSON.',
        ),
      ]).timeout(const Duration(seconds: 15));

      // Only charge the user once it actually worked.
      await quota.consumeSearch();

      if (!mounted) return;
      setState(() {
        _result = response.text?.trim() ?? 'No definition found.';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Couldn\'t reach the dictionary. Check your connection.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        // Tap anywhere outside the card to dismiss.
        onTap: _close,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Center(
            child: GestureDetector(
              // Swallow taps on the card itself so it doesn't self-dismiss.
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => LinearGradient(
                            colors: [colors.accent, colors.accent2],
                          ).createShader(b),
                          child: Icon(CupertinoIcons.sparkles,
                              size: 16, color: colors.ink),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _word ?? 'Define',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _close,
                          child: Icon(CupertinoIcons.xmark_circle_fill,
                              size: 20, color: colors.inkSoft),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_loading)
                      Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.6,
                              color: colors.accent2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('Looking it up…',
                              style: TextStyle(
                                  color: colors.inkSoft, fontSize: 13)),
                        ],
                      )
                    else
                      Text(
                        _error ?? _result ?? '',
                        style: TextStyle(
                          color: _error != null ? colors.inkSoft : colors.ink,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: colors.border),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Context',
                            style: TextStyle(
                              color: colors.inkSoft,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            )),
                        GestureDetector(
                          onTap: _openFullApp,
                          child: Text(
                            _error != null ? 'Open app' : 'More detail →',
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
