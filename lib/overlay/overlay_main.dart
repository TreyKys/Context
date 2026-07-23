import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../firebase_options.dart';
import '../services/ai_config.dart';

/// RevenueCat public SDK key, supplied via --dart-define (see SubscriptionService).
const String _kRevenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');

/// Registered as a separate Flutter engine entry point.
/// flutter_overlay_window calls this to render the floating widget.
@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The overlay runs in its own engine, so Firebase must be initialised here too.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );
  } catch (_) {}

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.bricolageGrotesqueTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const _OverlaySearchWidget(),
    ),
  );
}

class _OverlaySearchWidget extends StatefulWidget {
  const _OverlaySearchWidget();

  @override
  State<_OverlaySearchWidget> createState() => _OverlaySearchWidgetState();
}

class _OverlaySearchWidgetState extends State<_OverlaySearchWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _result;
  String? _error;
  bool _expanded = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
      _expanded = true;
    });

    try {
      final isPremium = await _isPremiumUser();
      if (!isPremium) {
        setState(() {
           _error = 'Overlay search requires Premium. Open app to upgrade.';
           _isLoading = false;
        });
        return;
      }

      final model = FirebaseAI.googleAI().generativeModel(model: kGeminiModel);
      final prompt =
          'Give a concise 1-2 sentence definition of "$input" suitable for '
          'quick reference. Include current cultural/slang usage if applicable. '
          'Plain text only, no JSON, no formatting.';

      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 10));

      setState(() {
        _result = response.text?.trim() ?? 'No result.';
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Signal lost. Check connection.';
        _isLoading = false;
      });
    }
  }

  Future<bool> _isPremiumUser() async {
    try {
      if (_kRevenueCatApiKey.isNotEmpty) {
        PurchasesConfiguration configuration =
            PurchasesConfiguration(_kRevenueCatApiKey);
        await Purchases.configure(configuration);
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        return customerInfo.entitlements.active.containsKey("pro_fluency");
      }
    } catch (_) {}
    return false;
  }

  void _close() {
    FlutterOverlayWindow.closeOverlay();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _result = null;
      _error = null;
      _expanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF6EC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFB07A47).withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFB07A47).withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFB07A47), Color(0xFFCDA15F)],
                    ).createShader(b),
                    child: const Icon(
                      CupertinoIcons.sparkles,
                      size: 16,
                      color: Color(0xFF2A2521),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: false,
                      style: const TextStyle(
                        color: Color(0xFF2A2521),
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search a word...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                         _debounce?.cancel();
                         _search();
                      },
                      onChanged: (_) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          if (_controller.text.trim().isNotEmpty) {
                             _search();
                          }
                        });
                      },
                    ),
                  ),
                  if (_expanded)
                    GestureDetector(
                      onTap: _clear,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: Colors.grey[700],
                          size: 16,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: _search,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB07A47), Color(0xFFCDA15F)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_right,
                        color: Color(0xFF2A2521),
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _close,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        CupertinoIcons.minus_circle_fill,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Result area
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        color: Color(0xFFCDA15F),
                        strokeWidth: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Translating...',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              )
            else if (_result != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Color(0xFFE2D8C4), height: 1),
                    const SizedBox(height: 8),
                    Text(
                      _result!,
                      style: const TextStyle(
                        color: Color(0xFF2A2521),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'via Context Dictionary',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                        letterSpacing: 0.3,
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
