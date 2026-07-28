/// ══════════════════════════════════════════════════════════════
/// وقتي — App Constants
/// ══════════════════════════════════════════════════════════════

class AppConstants {
  AppConstants._();
  static const String appName     = 'وقتي';
  static const String appVersion  = '3.0.0';
  static const String packageName = 'com.daryne.waqti';
  static const String supportEmail = 'support@waqti-app.com';
  static const String privacyPolicyUrl = 'https://daryne.github.io/waqti/privacy';
}

/// Hive box names
class HiveBoxes {
  HiveBoxes._();
  static const String progress = 'waqti_progress';
  static const String settings = 'waqti_settings';
}

/// SharedPreferences keys
class PrefKeys {
  PrefKeys._();
  static const String soundEnabled   = 'sound_enabled';
  static const String volumeLevel    = 'volume_level';
  static const String streakDays     = 'streak_days';
  static const String lastPlayDate   = 'last_play_date';
  static const String totalStars     = 'total_stars';
  static const String totalLessons   = 'total_lessons';
  static const String isPremium      = 'is_premium';
  static const String onboarded      = 'onboarded';
}

/// ══════════════════════════════════════════════════════════════
/// AdMob IDs
/// ──────────────────────────────────────────────────────────────
/// HOW TO SET YOUR REAL IDS:
///   1. Go to https://admob.google.com
///   2. Add app → Android / iOS
///   3. Create 4 ad units (Banner Home, Banner Lesson, Interstitial, Rewarded)
///   4. Replace every XXXXXXXXXX below with your real ID
///   5. Also update AndroidManifest.xml and ios/Runner/Info.plist
/// ══════════════════════════════════════════════════════════════
class AdMobIds {
  AdMobIds._();

  // ─── Android ───────────────────────────────────────────────
  /// Your Android App ID from AdMob console
  /// Format: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
  static const androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  //                           ↑ REPLACE — currently Google Test ID

  static const androidBannerHome    = 'ca-app-pub-3940256099942544/6300978111';
  static const androidBannerLesson  = 'ca-app-pub-3940256099942544/6300978111';
  static const androidInterstitial  = 'ca-app-pub-3940256099942544/1033173712';
  static const androidRewarded      = 'ca-app-pub-3940256099942544/5224354917';

  // ─── iOS ───────────────────────────────────────────────────
  /// Your iOS App ID from AdMob console
  static const iosAppId = 'ca-app-pub-3940256099942544~1458002511';
  //                       ↑ REPLACE — currently Google Test ID

  static const iosBannerHome    = 'ca-app-pub-3940256099942544/2934735716';
  static const iosBannerLesson  = 'ca-app-pub-3940256099942544/2934735716';
  static const iosInterstitial  = 'ca-app-pub-3940256099942544/4411468910';
  static const iosRewarded      = 'ca-app-pub-3940256099942544/1712485313';

  // ─── Google Test IDs (auto-used in debug mode) ─────────────
  static const _testBanner       = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewarded     = 'ca-app-pub-3940256099942544/5224354917';

  static bool get _isDebug =>
      const bool.fromEnvironment('dart.vm.product') == false;

  static bool get _isAndroid {
    try {
      // ignore: avoid_dynamic_calls
      return identical(0, 0.0) == false;
    } catch (_) { return true; }
  }

  static String get bannerHome =>
      _isDebug ? _testBanner : (_isAndroid ? androidBannerHome : iosBannerHome);

  static String get bannerLesson =>
      _isDebug ? _testBanner : (_isAndroid ? androidBannerLesson : iosBannerLesson);

  static String get interstitial =>
      _isDebug ? _testInterstitial : (_isAndroid ? androidInterstitial : iosInterstitial);

  static String get rewarded =>
      _isDebug ? _testRewarded : (_isAndroid ? androidRewarded : iosRewarded);
}
