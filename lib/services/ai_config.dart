import 'dart:async';
import 'dart:math';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Primary Gemini model used across the app (main search, quick define, and
/// floating overlay). Overridable at build time via:
///   --dart-define=GEMINI_MODEL=gemini-2.5-flash
const String kGeminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-2.5-flash',
);

/// Ordered fallback list tried automatically if the primary model returns a
/// "model not found" / "no longer available" / 404 error.
const List<String> kGeminiModelCandidates = [
  kGeminiModel,
  'gemini-2.5-flash',
  'gemini-2.5-flash-lite',
  'gemini-3.5-flash',
  'gemini-3.5-flash-lite',
  'gemini-2.0-flash',
];

String _activeGeminiModel = kGeminiModel;

/// The model identifier currently in use (updates automatically on fallback).
String get activeGeminiModel => _activeGeminiModel;

/// Whether the client activates Firebase App Check at startup.
///
/// Defaults to **true** because Firebase AI Logic enforces App Check
/// (`Basic - Enforced`). When disabled, requests omit the `X-Firebase-AppCheck`
/// header, which Firebase logs as "Unverified: outdated client requests" and
/// rejects with HTTP 401 (`Firebase App Check token is invalid`).
const bool kAppCheckEnabled = bool.fromEnvironment(
  'ENABLE_APP_CHECK',
  defaultValue: true,
);

/// Optional explicit App Check debug token supplied at build time:
///   --dart-define=APP_CHECK_DEBUG_TOKEN=xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
const String kBuildTimeAppCheckDebugToken = String.fromEnvironment(
  'APP_CHECK_DEBUG_TOKEN',
  defaultValue: '',
);

/// Whether to use the App Check Debug Provider instead of Play Integrity.
///
/// Play Integrity only succeeds on builds installed from Google Play. Debug
/// builds (`kDebugMode`) and sideloaded test APKs built with
/// `--dart-define=USE_APP_CHECK_DEBUG_PROVIDER=true` use `AndroidDebugProvider`
/// with a persistent UUID token that can be copied from Settings (or the
/// diagnostic error card) and added under:
///   Firebase Console → App Check → Apps → com.context.dictv1 → Manage debug tokens
const bool kUseAppCheckDebugProvider =
    kDebugMode ||
    bool.fromEnvironment('USE_APP_CHECK_DEBUG_PROVIDER', defaultValue: false) ||
    kBuildTimeAppCheckDebugToken != '';

/// Whether to render diagnostic error details on failure cards.
const bool kShowDebugErrors =
    kDebugMode ||
    bool.fromEnvironment('SHOW_DEBUG_ERRORS', defaultValue: false);

/// Manages Firebase App Check activation, resilient token fetching, and
/// persistent debug-token generation for local/sideloaded test builds.
class AppCheckService {
  static const String _prefsDebugTokenKey = 'app_check_debug_token';

  static String? _debugToken;
  static String? lastAttestationError;

  /// The active debug token when [kUseAppCheckDebugProvider] is true, or null
  /// when using Play Integrity.
  static String? get debugToken => _debugToken;

  static String get activeProviderName {
    if (!kAppCheckEnabled) return 'disabled';
    return kUseAppCheckDebugProvider ? 'debug' : 'playIntegrity';
  }

  /// Activates Firebase App Check and registers a fault-tolerant wrapper so
  /// client-side attestation errors never crash before the request is sent.
  static Future<void> activate() async {
    if (!kAppCheckEnabled) return;

    final app = Firebase.app();
    final delegate = FirebaseAppCheck.instanceFor(app: app);

    if (kUseAppCheckDebugProvider) {
      final token = await _ensureDebugToken();
      _debugToken = token;
      await delegate.activate(
        providerAndroid: AndroidDebugProvider(debugToken: token),
      );
      debugPrint(
        '[AppCheck] Activated AndroidDebugProvider. '
        'Register this debug token in Firebase Console → App Check → Apps → '
        'com.context.dictv1 → Manage debug tokens: $token',
      );
    } else {
      await delegate.activate(
        providerAndroid: const AndroidPlayIntegrityProvider(),
      );
    }

    // Wrap the delegate so that if getToken() fails client-side (e.g. while
    // App Check is Unenforced in the console, or before a debug token is
    // registered), firebase_ai still sends the HTTP request instead of
    // crashing locally before contacting the server.
    app.registerService<FirebaseAppCheck>(ResilientFirebaseAppCheck(delegate));
  }

  static Future<String> _ensureDebugToken() async {
    if (kBuildTimeAppCheckDebugToken.trim().isNotEmpty) {
      return kBuildTimeAppCheckDebugToken.trim();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final existing = prefs.getString(_prefsDebugTokenKey);
      if (existing != null && existing.trim().isNotEmpty) {
        return existing.trim();
      }
      final generated = _generateUuidV4();
      await prefs.setString(_prefsDebugTokenKey, generated);
      return generated;
    } catch (_) {
      return _debugToken ?? _generateUuidV4();
    }
  }

  static String _generateUuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
  }

  /// Builds a concise diagnostic summary for AI request failures.
  static String formatDiagnostics(Object error) {
    final buffer = StringBuffer(
      'Debug [model=$_activeGeminiModel '
      'appCheck=$kAppCheckEnabled '
      'provider=$activeProviderName]: $error',
    );
    if (lastAttestationError != null) {
      buffer.write('\nAppCheck attestation: $lastAttestationError');
    }
    if (_debugToken != null) {
      buffer.write(
        '\nAppCheck debug token: $_debugToken\n'
        '(Add in Firebase Console → App Check → Apps → com.context.dictv1 → '
        '⋮ → Manage debug tokens)',
      );
    }
    return buffer.toString();
  }
}

/// Fault-tolerant [FirebaseAppCheck] proxy that prevents client-side token
/// fetch errors from aborting requests before they reach Firebase AI Logic.
class ResilientFirebaseAppCheck implements FirebaseAppCheck {
  ResilientFirebaseAppCheck(this._delegate);

  final FirebaseAppCheck _delegate;

  @override
  FirebaseApp get app => _delegate.app;

  @override
  set app(FirebaseApp value) => _delegate.app = value;

  @override
  Map<dynamic, dynamic> get pluginConstants => _delegate.pluginConstants;

  @override
  Future<String?> getToken([bool? forceRefresh]) async {
    try {
      final token = await _delegate.getToken(forceRefresh);
      AppCheckService.lastAttestationError = null;
      return token;
    } catch (e) {
      AppCheckService.lastAttestationError = e.toString();
      debugPrint('[AppCheck] getToken failed, proceeding without token: $e');
      return null;
    }
  }

  @override
  Future<String> getLimitedUseToken() async {
    try {
      final token = await _delegate.getLimitedUseToken();
      AppCheckService.lastAttestationError = null;
      return token;
    } catch (e) {
      AppCheckService.lastAttestationError = e.toString();
      debugPrint('[AppCheck] getLimitedUseToken failed: $e');
      return '';
    }
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(bool isTokenAutoRefreshEnabled) {
    return _delegate.setTokenAutoRefreshEnabled(isTokenAutoRefreshEnabled);
  }

  @override
  Stream<String?> get onTokenChange => _delegate.onTokenChange;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Calls `FirebaseAI.googleAI().generativeModel(...).generateContent(prompt)`
/// and automatically falls back across [kGeminiModelCandidates] if the active
/// model identifier is not found or retired on the project.
Future<GenerateContentResponse> generateContentWithFallback(
  Iterable<Content> prompt, {
  GenerationConfig? generationConfig,
  Duration? timeout,
}) async {
  final candidates = <String>[
    _activeGeminiModel,
    ...kGeminiModelCandidates.where((m) => m != _activeGeminiModel),
  ];

  Object? lastError;
  for (int i = 0; i < candidates.length; i++) {
    final modelName = candidates[i];
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: modelName,
        generationConfig: generationConfig,
      );
      final future = model.generateContent(prompt);
      final response = timeout != null
          ? await future.timeout(timeout)
          : await future;
      _activeGeminiModel = modelName;
      return response;
    } catch (e) {
      lastError = e;
      final isLastCandidate = i == candidates.length - 1;
      if (!isLastCandidate && isModelUnavailableError(e)) {
        debugPrint(
          '[AI] Model "$modelName" unavailable ($e); trying next candidate...',
        );
        continue;
      }
      rethrow;
    }
  }
  throw lastError ?? Exception('No Gemini model candidates available.');
}

/// True when the error indicates the requested model identifier does not exist
/// or has been retired/shut down on the backend.
bool isModelUnavailableError(Object error) {
  final msg = error.toString().toLowerCase();
  return msg.contains('not found') ||
      msg.contains('not_found') ||
      msg.contains('no longer available') ||
      msg.contains('does not exist') ||
      msg.contains('not supported for generatecontent') ||
      msg.contains('is retired') ||
      msg.contains('was retired') ||
      msg.contains('shut down');
}

/// True when the error is an authentication, App Check, or permission rejection
/// that should not be retried with backoff.
bool isNonRetryableAiError(Object error) {
  final msg = error.toString().toLowerCase();
  return msg.contains('app check') ||
      msg.contains('app attestation') ||
      msg.contains('unauthenticated') ||
      msg.contains('permission_denied') ||
      msg.contains('permission denied') ||
      msg.contains('api key not valid') ||
      msg.contains('are blocked') ||
      isModelUnavailableError(error);
}
