/// ══════════════════════════════════════════════════════════════
/// وقتي — App Constants
/// ══════════════════════════════════════════════════════════════

class AppConstants {
  AppConstants._();
  static const String appName      = 'وقتي';
  static const String appVersion   = '3.0.0';
  static const String packageName  = 'com.daryne.waqti';
  static const String supportEmail = 'support@waqti-app.com';
}

class HiveBoxes {
  HiveBoxes._();
  static const String progress = 'waqti_progress';
  static const String settings = 'waqti_settings';
}

/// ══════════════════════════════════════════════════════════════
/// AdMob IDs
/// ──────────────────────────────────────────────────────────────
/// Your real Android App ID is already in AndroidManifest.xml:
///   ca-app-pub-1377346158677931~9202705192
///
/// NEXT STEPS:
///   1. Create ad units in AdMob console (see ADMOB_SETUP.md)
///   2. Replace every XXXXXXXXXX below with your real unit IDs
///   3. Keep test IDs during development — switch to real for release
/// ══════════════════════════════════════════════════════════════
class AdMobIds {
  AdMobIds._();

  // ── Your Android App ID (already in AndroidManifest.xml) ───
  static const androidAppId = 'ca-app-pub-1377346158677931~9202705192';

  // ── Android Ad Unit IDs — REPLACE these with your real ones ─
  // Get them from: admob.google.com → Apps → Ad units → Create
  static const androidBannerHome    = 'ca-app-pub-1377346158677931/XXXXXXXXXX';
  static const androidBannerLesson  = 'ca-app-pub-1377346158677931/XXXXXXXXXX';
  static const androidInterstitial  = 'ca-app-pub-1377346158677931/XXXXXXXXXX';
  static const androidRewarded      = 'ca-app-pub-1377346158677931/XXXXXXXXXX';

  // ── iOS — not needed now (Android only) ─────────────────────
  static const iosBannerHome    = 'ca-app-pub-3940256099942544/2934735716';
  static const iosBannerLesson  = 'ca-app-pub-3940256099942544/2934735716';
  static const iosInterstitial  = 'ca-app-pub-3940256099942544/4411468910';
  static const iosRewarded      = 'ca-app-pub-3940256099942544/1712485313';

  // ── Google Test IDs — used automatically in debug mode ──────
  static const testBanner       = 'ca-app-pub-3940256099942544/6300978111';
  static const testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const testRewarded     = 'ca-app-pub-3940256099942544/5224354917';
}
