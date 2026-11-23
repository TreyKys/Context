import 'dart:async';

import 'package:context_dictionary/main.dart';
import 'package:context_dictionary/models/vibe_result.dart';
import 'package:context_dictionary/providers/quota_provider.dart';
import 'package:context_dictionary/providers/subscription_provider.dart';
import 'package:context_dictionary/providers/vibe_provider.dart';
import 'package:context_dictionary/services/ai_config.dart';
import 'package:context_dictionary/services/history_service.dart';
import 'package:context_dictionary/services/llm_service.dart';
import 'package:context_dictionary/services/notification_service.dart';
import 'package:context_dictionary/services/quota_service.dart';
import 'package:context_dictionary/services/subscription_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAppCheck implements FirebaseAppCheck {
  _FakeAppCheck({this.tokenToReturn, this.errorToThrow});

  final String? tokenToReturn;
  final Object? errorToThrow;

  @override
  Future<String?> getToken([bool? forceRefresh]) async {
    if (errorToThrow != null) throw errorToThrow!;
    return tokenToReturn;
  }

  @override
  Future<String> getLimitedUseToken() async {
    if (errorToThrow != null) throw errorToThrow!;
    return tokenToReturn ?? '';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestLLMService implements LLMService {
  int vibeCalls = 0;
  int directCalls = 0;

  @override
  Future<VibeResult> generateVibe(
    String input,
    String mode,
    String vibe,
  ) async {
    vibeCalls++;
    return VibeResult(
      literalDefinition: 'Literal for $input',
      vibeTranslation: 'Vibe for $input',
      exampleSentence: 'For context, $input is used in tests.',
      tags: ['test'],
    );
  }

  @override
  Future<VibeResult> directSearch(String input, {String? domain}) async {
    directCalls++;
    return VibeResult(
      literalDefinition: 'Direct literal for $input',
      vibeTranslation: 'Etymology for $input',
      exampleSentence: '',
      tags: ['direct'],
      isDirectSearch: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'has_onboarded': true});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('App Check & AI error handling', () {
    test('kAppCheckEnabled defaults to true', () {
      expect(kAppCheckEnabled, isTrue);
    });

    test('ResilientFirebaseAppCheck returns token on success', () async {
      final resilient = ResilientFirebaseAppCheck(
        _FakeAppCheck(tokenToReturn: 'valid-jwt-token'),
      );
      final token = await resilient.getToken();
      expect(token, 'valid-jwt-token');
      expect(AppCheckService.lastAttestationError, isNull);
    });

    test(
      'ResilientFirebaseAppCheck catches attestation failure and returns null instead of crashing client-side',
      () async {
        final resilient = ResilientFirebaseAppCheck(
          _FakeAppCheck(
            errorToThrow: FirebaseException(
              plugin: 'firebase_app_check',
              message: '403 App attestation failed.',
            ),
          ),
        );
        final token = await resilient.getToken();
        expect(token, isNull);
        expect(
          AppCheckService.lastAttestationError,
          contains('403 App attestation failed'),
        );
      },
    );

    test(
      'isModelUnavailableError and isNonRetryableAiError classify errors',
      () {
        expect(
          isModelUnavailableError('models/gemini-3.5-flash is not found'),
          isTrue,
        );
        expect(
          isModelUnavailableError(
            'This model is no longer available to new users',
          ),
          isTrue,
        );
        expect(
          isNonRetryableAiError('Firebase App Check token is invalid.'),
          isTrue,
        );
        expect(
          isNonRetryableAiError('SocketException: Failed host lookup'),
          isFalse,
        );
      },
    );
  });

  group('QuotaService & isPremiumProvider', () {
    test('isPremiumProvider emits initial status immediately', () async {
      final quota = QuotaService();
      await quota.init('anonymous');

      final container = ProviderContainer(
        overrides: [
          quotaServiceProvider.overrideWithValue(quota),
          subscriptionServiceProvider.overrideWithValue(SubscriptionService()),
        ],
      );
      addTearDown(container.dispose);

      final completer = Completer<bool>();
      final sub = container.listen<AsyncValue<bool>>(isPremiumProvider, (
        _,
        next,
      ) {
        if (next.asData?.value == true && !completer.isCompleted) {
          completer.complete(true);
        }
      }, fireImmediately: true);
      addTearDown(sub.close);

      final initial = await container.read(isPremiumProvider.future);
      expect(initial, isFalse);

      await quota.setPremium(true);
      expect(await completer.future, isTrue);
    });

    test('markPrepaidLookup prevents double-billing the same word', () async {
      final quota = QuotaService();
      await quota.init('anonymous');
      expect(quota.availableSearches, 3);

      // QuickDefineSheet consumes 1 search and marks the word as prepaid
      await quota.consumeSearch();
      expect(quota.availableSearches, 2);
      await quota.markPrepaidLookup('Sonder');

      // Full app DirectSearchTab consumes the prepaid marker without charging again
      await quota.consumeSearch(word: 'sonder');
      expect(quota.availableSearches, 2);

      // Subsequent lookup of the same word charges normally
      await quota.consumeSearch(word: 'sonder');
      expect(quota.availableSearches, 1);
    });
  });

  group('HistoryService', () {
    test(
      'Direct Search and Vibe Translate keep separate entries for same word',
      () async {
        final history = HistoryService();
        await history.init();
        await history.clearHistory();

        await history.addEntry(
          HistoryEntry(
            word: 'rizz',
            mode: 'Define',
            persona: 'Gen Z / TikTok Slang',
            isDirectSearch: false,
            timestamp: DateTime.now(),
          ),
        );
        await history.addEntry(
          HistoryEntry(
            word: 'rizz',
            mode: '',
            persona: 'General / All Topics',
            isDirectSearch: true,
            timestamp: DateTime.now(),
          ),
        );

        final entries = history.getHistory();
        expect(entries.where((e) => !e.isDirectSearch).length, 1);
        expect(entries.where((e) => e.isDirectSearch).length, 1);
      },
    );
  });

  group('Notification payload & tab state persistence', () {
    test('NotificationService.consumeInitialPayload only fires once', () {
      final service = NotificationService();
      service.initialPayload = 'Rizz';

      expect(service.consumeInitialPayload(), 'Rizz');
      expect(service.consumeInitialPayload(), isNull);
      expect(service.consumeInitialPayload('Rizz'), isNull);
    });

    testWidgets(
      'Switching tabs preserves search result and searchWord on ResultCard',
      (tester) async {
        final llm = _TestLLMService();
        final quota = QuotaService();
        await quota.init('anonymous');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              llmServiceProvider.overrideWithValue(llm),
              quotaServiceProvider.overrideWithValue(quota),
              quotaCountProvider.overrideWith(
                () => QuotaCountNotifier(quota.availableSearches),
              ),
            ],
            child: const ContextDictionaryApp(),
          ),
        );

        // Enter a word on Vibe tab and trigger search
        await tester.enterText(find.byType(TextField).first, 'rizz');
        await tester.tap(
          find.byIcon(CupertinoIcons.arrow_right_circle_fill).first,
        );
        await tester.pumpAndSettle();

        expect(llm.vibeCalls, 1);
        expect(find.text('LITERAL DEFINITION'), findsOneWidget);

        // Switch to Search tab and back to Vibe tab
        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Vibe'));
        await tester.pumpAndSettle();

        // Did not re-trigger search, and result + searchWord remain intact
        expect(llm.vibeCalls, 1);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ContextDictionaryApp)),
        );
        expect(container.read(vibeProvider).searchWord, 'rizz');
      },
    );
  });
}
