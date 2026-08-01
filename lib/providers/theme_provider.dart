import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app theme mode (system / light / dark), stored in SharedPreferences.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    // Seeded synchronously from the value loaded at startup (see main.dart).
    return _initial;
  }

  static ThemeMode _initial = ThemeMode.system;

  /// The persisted mode, readable before a ProviderScope exists (the quick
  /// "Define" card builds its MaterialApp outside the main provider tree).
  static ThemeMode get initial => _initial;

  /// Call once at startup before running the app.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _initial = _decode(prefs.getString(_key));
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _encode(mode));
  }

  static String _encode(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _decode(String? s) => switch (s) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
