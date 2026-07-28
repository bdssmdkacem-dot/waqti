import 'dart:io';

/// ══════════════════════════════════════════════════════════════
/// وقتي — App Constants
/// ══════════════════════════════════════════════════════════════

class AppConstants {
  AppConstants._();

  static const String appName = 'وقتي';
  static const String appVersion = '3.0.0';

  /// Must match Android applicationId and iOS Bundle Identifier
  static const String packageName = 'com.daryne.waqti';

  static const String supportEmail = 'support@waqti-app.com';

  static const String privacyPolicyUrl =
      'https://daryne.github.io/waqti/privacy';
}

/// ══════════════════════════════════════════════════════════════
/// Hive Box Names
/// ══════════════════════════════════════════════════════════════

class HiveBoxes {
  HiveBoxes._();

  static const String progress = 'waqti_progress';
  static const String settings = 'waqti_settings';
}

/// ══════════════════════════════════════════════════════════════
/// SharedPreferences Keys
/// ══════════════════════════════════════════════════════════════

class PrefKeys {
  PrefKeys._();

  static const String soundEnabled = 'sound_enabled';
  static const String volumeLevel = 'volume_level';
  static const String streakDays = 'streak_days';
  static const String lastPlayDate = 'last_play_date';
  static const String totalStars = 'total_stars';
  static const String totalLessons = 'total_lessons';
  static const String isPremium = 'is_premium';
  static const String onboarded = 'onboarded';
}

/// ══════════════════════════════════════════════════════════════
/// AdMob IDs
///
/// NOTE:
/// • App IDs DO NOT belong here.
/// • Android App ID → AndroidManifest.xml
/// • iOS App ID → ios/Runner/Info.plist
/// • Debug builds automatically use Google's Test IDs.
/// • Release builds automatically use your real IDs.
/// ══════════════════════════════════════════════════════════════

class AdMobIds {
  AdMobIds._();

  // ============================================================
  // Android Production IDs
  // ============================================================

  static const String _androidBannerHome =
      'ca-app-pub-1377346158677931/9766224662';

  // Reusing the same banner until a dedicated Lesson Banner is created.
  static const String _androidBannerLesson =
      'ca-app-pub-1377346158677931/9766224662';

  static const String _androidInterstitial =
      'ca-app-pub-1377346158677931/1504591265';

  static const String _androidRewarded =
      'ca-app-pub-1377346158677931/2789752776';

  // ============================================================
  // iOS Production IDs
  // ============================================================

  static const String _iosBannerHome = '';
  static const String _iosBannerLesson = '';
  static const String _iosInterstitial = '';
  static const String _iosRewarded = '';

  // ============================================================
  // Google Official Test IDs
  // https://developers.google.com/admob/android/test-ads
  // ============================================================

  static const String _testBanner =
      'ca-app-pub-3940256099942544/6300978111';

  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _testRewarded =
      'ca-app-pub-3940256099942544/5224354917';

  // ============================================================
  // Environment
  // ============================================================

  static bool get _isDebug =>
      !const bool.fromEnvironment('dart.vm.product');

  // ============================================================
  // Public Getters
  // ============================================================

  static String get bannerHome {
    if (_isDebug) return _testBanner;
    return Platform.isAndroid ? _androidBannerHome : _iosBannerHome;
  }

  static String get bannerLesson {
    if (_isDebug) return _testBanner;
    return Platform.isAndroid ? _androidBannerLesson : _iosBannerLesson;
  }

  static String get interstitial {
    if (_isDebug) return _testInterstitial;
    return Platform.isAndroid
        ? _androidInterstitial
        : _iosInterstitial;
  }

  static String get rewarded {
    if (_isDebug) return _testRewarded;
    return Platform.isAndroid ? _androidRewarded : _iosRewarded;
  }
}
