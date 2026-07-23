import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic colour tokens for The Context Dictionary. Both the light ("cream")
/// and dark ("warm dark") variants keep the same cream/caramel character — the
/// dark mode is a cozy warm dark, never a cold neon black.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg; // scaffold background
  final Color surface; // cards, inputs
  final Color surfaceAlt; // slightly raised / highlighted surfaces
  final Color border; // hairlines, dividers, outlines
  final Color ink; // primary text & icons
  final Color inkSoft; // secondary / muted text
  final Color accent; // primary accent (caramel)
  final Color accent2; // secondary accent (lighter caramel)

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.accent2,
  });

  /// Light — warm minimalist cream.
  static const light = AppColors(
    bg: Color(0xFFF2EBDD),
    surface: Color(0xFFFBF6EC),
    surfaceAlt: Color(0xFFEAE0CE),
    border: Color(0xFFE2D8C4),
    ink: Color(0xFF2A2521),
    inkSoft: Color(0xFF8A7F6E),
    accent: Color(0xFFB07A47),
    accent2: Color(0xFFCDA15F),
  );

  /// Dark — warm cocoa dark that retains the cream (cream-tinted text).
  static const dark = AppColors(
    bg: Color(0xFF1A1712),
    surface: Color(0xFF241F18),
    surfaceAlt: Color(0xFF2E2820),
    border: Color(0xFF3A332A),
    ink: Color(0xFFEDE4D3),
    inkSoft: Color(0xFFB4A992),
    accent: Color(0xFFCF9E6A),
    accent2: Color(0xFFD8B383),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? ink,
    Color? inkSoft,
    Color? accent,
    Color? accent2,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      accent: accent ?? this.accent,
      accent2: accent2 ?? this.accent2,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accent2: Color.lerp(accent2, other.accent2, t)!,
    );
  }
}

/// Ergonomic access: `context.colors.ink`, `context.colors.bg`, …
extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

ThemeData _themeFrom(AppColors c, Brightness brightness) {
  final base = brightness == Brightness.dark
      ? ThemeData.dark()
      : ThemeData.light();
  final scheme =
      (brightness == Brightness.dark
              ? const ColorScheme.dark()
              : const ColorScheme.light())
          .copyWith(
            brightness: brightness,
            primary: c.accent,
            onPrimary: brightness == Brightness.dark ? c.bg : c.surface,
            secondary: c.accent2,
            onSecondary: c.ink,
            surface: c.bg,
            onSurface: c.ink,
            onSurfaceVariant: c.inkSoft,
            outlineVariant: c.border,
            outline: c.border,
          );

  return base.copyWith(
    scaffoldBackgroundColor: c.bg,
    colorScheme: scheme,
    extensions: [c],
    textTheme: GoogleFonts.bricolageGrotesqueTextTheme(base.textTheme).apply(
      bodyColor: c.ink,
      displayColor: c.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surface,
      selectedItemColor: c.accent,
      unselectedItemColor: c.inkSoft,
      elevation: 0,
    ),
  );
}

ThemeData buildLightTheme() => _themeFrom(AppColors.light, Brightness.light);
ThemeData buildDarkTheme() => _themeFrom(AppColors.dark, Brightness.dark);
