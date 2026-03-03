import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. This MUST be the absolute first line
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Load the environment variables
    await dotenv.load(fileName: ".env");

    // 3. Run the actual app wrapped in Riverpod
    runApp(const ProviderScope(child: ContextDictionaryApp()));
  } catch (error, stackTrace) {
    // 4. If ANYTHING fails above, boot this error screen instead of crashing
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
