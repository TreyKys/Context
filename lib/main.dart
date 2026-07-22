import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/consent_service.dart';
import 'services/notification_service.dart';
import 'services/quota_service.dart';
import 'services/library_service.dart';
import 'services/history_service.dart';
import 'services/subscription_service.dart';
import 'providers/library_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/quota_provider.dart';
// Overlay entry point — must be imported so the compiler includes it
import 'overlay/overlay_main.dart' as overlay_entry; // ignore: unused_import

final initialNotificationPayloadProvider = Provider<String?>((ref) => null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Gather EEA/UK ad consent (UMP) before requesting ads. Bounded so a slow
    // or stuck form can never freeze startup; no-op outside the EEA/UK.
    try {
      await ConsentService.instance
          .gatherConsent()
          .timeout(const Duration(seconds: 8));
    } catch (_) {}

    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('MobileAds init failed: $e');
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // App Check protects the Firebase AI backend. Debug builds use the debug
      // provider (register the printed debug token in the Firebase console);
      // release builds use Play Integrity.
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      );
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }

    // Each service is initialised independently so that one failure (e.g. a
    // device without a given capability) degrades that feature instead of
    // blanking the whole app on the "Failed to Start" screen.
    final notificationService = NotificationService();
    try {
      await notificationService.init();
      await notificationService.requestPermissions();
      await notificationService.scheduleDailyNotifications();
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
    final initialPayload = notificationService.initialPayload;

    final quotaService = QuotaService();
    try {
      // Assuming anonymous access, update when authenticated
      await quotaService.init('anonymous');
    } catch (e) {
      debugPrint('QuotaService init failed: $e');
    }

    final libraryService = LibraryService();
    try {
      await libraryService.init();
    } catch (e) {
      debugPrint('LibraryService init failed: $e');
    }

    final historyService = HistoryService();
    try {
      await historyService.init();
    } catch (e) {
      debugPrint('HistoryService init failed: $e');
    }

    final subscriptionService = SubscriptionService();
    try {
      await subscriptionService.init(quotaService);
    } catch (e) {
      debugPrint('SubscriptionService init failed: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('has_onboarded') ?? false;

    runApp(
      ProviderScope(
        overrides: [
          initialNotificationPayloadProvider.overrideWithValue(initialPayload),
          quotaServiceProvider.overrideWithValue(quotaService),
          libraryServiceProvider.overrideWithValue(libraryService),
          subscriptionServiceProvider.overrideWithValue(subscriptionService),
          // Seed the reactive quota counter with the real value at startup
          quotaCountProvider.overrideWith(
            () => QuotaCountNotifier(quotaService.availableSearches),
          ),
        ],
        child: ContextDictionaryApp(showOnboarding: !hasOnboarded),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('App failed to start: $e\n$stackTrace');
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0B0C10),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.redAccent,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong during startup. Please restart the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 15),
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

class ContextDictionaryApp extends StatelessWidget {
  final bool showOnboarding;
  const ContextDictionaryApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Context Dictionary',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030305),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF030305),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF030305),
          selectedItemColor: Color(0xFF00FFD1),
          unselectedItemColor: Colors.grey,
          elevation: 0,
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA855F7),
          secondary: Color(0xFF00FFD1),
          surface: Color(0xFF030305),
        ),
      ),
      home: showOnboarding ? const _OnboardingGate() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _OnboardingGate extends StatelessWidget {
  const _OnboardingGate();

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_onboarded', true);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      onDone: () => _completeOnboarding(context),
    );
  }
}
