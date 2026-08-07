import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const starGold    = Color(0xFFFFC107);
  static const offWhite    = Color(0xFFF8FBFF);

  // One color per unit (13 units)
  static const List<Color> units = [
    Color(0xFF1565C0), // 1  ⭐  أبطال الساعة
    Color(0xFF6A1B9A), // 2  🌙  النصف الجميل
    Color(0xFF00695C), // 3  🌟  مغامرة الربع
    Color(0xFFBF360C), // 4  🚀  عدّ بالخمسة
    Color(0xFFAD1457), // 5  👑  أسياد الوقت
    Color(0xFF1A237E), // 6  📱  الساعة الرقمية
    Color(0xFFE65100), // 7  🌅  صباح ومساء
    Color(0xFF4527A0), // 8  🔄  رقمي↔تناظري
    Color(0xFF00838F), // 9  🌈  يومي مع الساعة
    Color(0xFF558B2F), // 10 ⚡  تحدي السرعة
    Color(0xFF37474F), // 11 ⏳  كم مرّ من الوقت
    Color(0xFF4E342E), // 12 🏆  أسطورة الوقت
    Color(0xFF1B5E20), // 13 🧮  حساب الوقت
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

  static double sm(BuildContext c) => 12 * _scale(c);
  static double md(BuildContext c) => 15 * _scale(c);
  static double lg(BuildContext c) => 18 * _scale(c);
  static double xl(BuildContext c) => 22 * _scale(c);
  static double h2(BuildContext c) => 26 * _scale(c);
  static double h1(BuildContext c) => 32 * _scale(c);
}

// ── App Theme ─────────────────────────────────────────────────
class WaqtiTheme {
  WaqtiTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WaqtiColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: WaqtiColors.bg,
    fontFamily: GoogleFonts.cairo().fontFamily,
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),

    appBarTheme: AppBarTheme(
      backgroundColor: WaqtiColors.primary,
      foregroundColor: WaqtiColors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.cairo(
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
        textStyle: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700),
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
  );
}

// ── Font helper — use this instead of fontFamily: GoogleFonts.cairo().fontFamily everywhere
// GoogleFonts caches fonts after first download (works offline after that)
class WaqtiFont {
  WaqtiFont._();
  static String get family => GoogleFonts.cairo().fontFamily!;
}

/// Shortcut: TextStyle with Cairo
TextStyle cairoStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) => GoogleFonts.cairo(
  fontSize:      fontSize,
  fontWeight:    fontWeight,
  color:         color,
  height:        height,
  letterSpacing: letterSpacing,
  decoration:    decoration,
);
