import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/quota_service.dart';

// Create a global provider to hold the initial notification payload
final initialNotificationPayloadProvider = Provider<String?>((ref) => null);

void main() async {
  // 1. This MUST be the absolute first line
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Initialize AdMob SDK
    await MobileAds.instance.initialize();

    // 3. Load the environment variables
    await dotenv.load(fileName: ".env");

    // 4. Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();
    await notificationService.scheduleDailyNotifications();

    final initialPayload = notificationService.initialPayload;

    // 5. Initialize Quota Service
    final quotaService = QuotaService();
    await quotaService.init();

    // 6. Run the actual app wrapped in Riverpod
    runApp(
      ProviderScope(
        overrides: [
          initialNotificationPayloadProvider.overrideWithValue(initialPayload),
          quotaServiceProvider.overrideWithValue(quotaService),
        ],
        child: const ContextDictionaryApp(),
      ),
    );
  } catch (error, stackTrace) {
    // 7. If ANYTHING fails above, boot this error screen instead of crashing
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF8B0000), // Dark Red
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text('''FATAL CRASH:
$error

STACKTRACE:
$stackTrace''', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
        ),
      ),
    );
  }
}

class ContextDictionaryApp extends StatelessWidget {
  const ContextDictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Context Dictionary',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0C10), // Obsidian
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0C10),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0B0C10),
          elevation: 0,
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
          surface: Color(0xFF0B0C10),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
