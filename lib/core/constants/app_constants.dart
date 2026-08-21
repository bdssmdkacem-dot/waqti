/// Waqti app constants.
class AppConstants {
  AppConstants._();
  static const String appName = 'وقتي';
  static const String appVersion = '3.0.0';
  static const String packageName = 'com.daryne.waqti';
  static const String supportEmail = 'support@waqti-app.com';
}

class HiveBoxes {
  HiveBoxes._();
  static const String progress = 'waqti_progress';
  static const String settings = 'waqti_settings';
}

/// Production AdMob configuration for Waqti Android.
class AdMobIds {
  AdMobIds._();

  static const androidAppId = 'ca-app-pub-1377346158677931~9202705192';

  static const androidBannerHome =
      'ca-app-pub-1377346158677931/9766224662';

  /// Waqti currently has one production banner unit; reuse it on lessons.
  static const androidBannerLesson =
      'ca-app-pub-1377346158677931/9766224662';

  static const androidInterstitial =
      'ca-app-pub-1377346158677931/1504591265';

  static const androidRewarded =
      'ca-app-pub-1377346158677931/5354645867';

  static const androidRewardedHint =
      'ca-app-pub-1377346158677931/2789752776';

  // iOS — not used by the current Android release.
  static const iosBannerHome = 'ca-app-pub-3940256099942544/2934735716';
  static const iosBannerLesson = 'ca-app-pub-3940256099942544/2934735716';
  static const iosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const iosRewarded = 'ca-app-pub-3940256099942544/1712485313';

  // Google official test units — debug builds only.
  static const testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const testRewarded = 'ca-app-pub-3940256099942544/5224354917';
}
