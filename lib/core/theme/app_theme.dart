import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Colors ────────────────────────────────────────────────────
class WaqtiColors {
  WaqtiColors._();
  static const primary     = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const accent      = Color(0xFFFFC107);
  static const gold        = Color(0xFFFFB300);
  static const coral       = Color(0xFFFF7043);
  static const mint        = Color(0xFF43A047);
  static const purple      = Color(0xFF6A1B9A);
  static const teal        = Color(0xFF00695C);
  static const orange      = Color(0xFFE65100);
  static const sky         = Color(0xFFE3F2FD);
  static const white       = Color(0xFFFFFFFF);
  static const bg          = Color(0xFFF0F4FF);
  static const textDark    = Color(0xFF0D1B2A);
  static const textMid     = Color(0xFF546E7A);
  static const textLight   = Color(0xFF90A4AE);
  static const offWhite    = Color(0xFFF8FBFF);

  static const List<Color> units = [
    Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFF00695C),
    Color(0xFFBF360C), Color(0xFFAD1457), Color(0xFF1A237E),
    Color(0xFFE65100), Color(0xFF4527A0), Color(0xFF00838F),
    Color(0xFF558B2F), Color(0xFF37474F), Color(0xFF4E342E),
    Color(0xFF1B5E20),
  ];
}

// ── Spacing ───────────────────────────────────────────────────
class WaqtiSpacing {
  WaqtiSpacing._();
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

// ── Radius ────────────────────────────────────────────────────
class WaqtiRadius {
  WaqtiRadius._();
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 28;
  static const double full = 999;
}

// ── Responsive helpers ────────────────────────────────────────
class WaqtiSize {
  WaqtiSize._();

  static double _scale(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w >= 600) return 1.15;
    if (w >= 400) return 1.0;
    return 0.92;
  }

  static double clockSize(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final h = MediaQuery.of(ctx).size.height;
    return ((w < h ? w : h) * 0.52).clamp(180.0, 280.0);
  }

  static double lessonClockSize(BuildContext ctx) =>
      (MediaQuery.of(ctx).size.width * 0.52).clamp(160.0, 230.0);

  static double xs(BuildContext c) => 12 * _scale(c);
  static double sm(BuildContext c) => 14 * _scale(c);
  static double md(BuildContext c) => 15 * _scale(c);
  static double lg(BuildContext c) => 18 * _scale(c);
  static double xl(BuildContext c) => 22 * _scale(c);
  static double h2(BuildContext c) => 26 * _scale(c);
  static double h1(BuildContext c) => 32 * _scale(c);
}

// ── Theme ─────────────────────────────────────────────────────
class WaqtiTheme {
  WaqtiTheme._();

  static const String _font = 'Cairo';

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WaqtiColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: WaqtiColors.bg,
    fontFamily: _font,

    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: _font, fontWeight: FontWeight.w800),
      displayMedium:  TextStyle(fontFamily: _font, fontWeight: FontWeight.w800),
      displaySmall:   TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
      headlineLarge:  TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
      headlineSmall:  TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
      titleLarge:     TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
      titleMedium:    TextStyle(fontFamily: _font, fontWeight: FontWeight.w600),
      titleSmall:     TextStyle(fontFamily: _font, fontWeight: FontWeight.w600),
      bodyLarge:      TextStyle(fontFamily: _font, fontWeight: FontWeight.w400),
      bodyMedium:     TextStyle(fontFamily: _font, fontWeight: FontWeight.w400),
      bodySmall:      TextStyle(fontFamily: _font, fontWeight: FontWeight.w400),
      labelLarge:     TextStyle(fontFamily: _font, fontWeight: FontWeight.w600),
      labelMedium:    TextStyle(fontFamily: _font, fontWeight: FontWeight.w500),
      labelSmall:     TextStyle(fontFamily: _font, fontWeight: FontWeight.w500),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: WaqtiColors.primary,
      foregroundColor: WaqtiColors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: _font,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: WaqtiColors.white,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WaqtiColors.primary,
        foregroundColor: WaqtiColors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaqtiRadius.lg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: WaqtiSpacing.lg,
          vertical: WaqtiSpacing.md,
        ),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(
          fontFamily: _font,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaqtiRadius.lg),
        ),
        textStyle: const TextStyle(
          fontFamily: _font,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WaqtiRadius.xl),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      color: WaqtiColors.white,
      clipBehavior: Clip.antiAlias,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F7FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WaqtiRadius.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WaqtiRadius.lg),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WaqtiRadius.lg),
        borderSide: const BorderSide(color: WaqtiColors.primary, width: 2),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE),
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WaqtiRadius.lg),
      ),
    ),
  );
}

// ── Font helper ───────────────────────────────────────────────
class WaqtiFont {
  WaqtiFont._();
  static const String family = 'Cairo';
}
