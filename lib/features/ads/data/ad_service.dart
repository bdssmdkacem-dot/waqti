import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/app_constants.dart';

final adServiceProvider = Provider<AdService>(
  (ref) => AdService.instance,
);

class AdService extends ChangeNotifier {
  AdService._();
  static final AdService instance = AdService._();

  BannerAd? _homeBanner;
  BannerAd? _lessonBanner;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  bool _homeBannerReady = false;
  bool _lessonBannerReady = false;
  bool _interstitialReady = false;
  int _lessonsSinceAd = 0;

  bool get homeBannerReady => _homeBannerReady;
  bool get lessonBannerReady => _lessonBannerReady;
  BannerAd? get homeBanner => _homeBanner;
  BannerAd? get lessonBanner => _lessonBanner;

  // Until real ad-unit IDs are configured, always use Google's official
  // test units. Placeholder IDs containing X must never reach AdMob.
  static String _safeAndroidId(String id, String testId) =>
      id.contains('X') ? testId : id;

  static String get _bannerId => kDebugMode
      ? AdMobIds.testBanner
      : (Platform.isIOS
          ? AdMobIds.iosBannerHome
          : _safeAndroidId(AdMobIds.androidBannerHome, AdMobIds.testBanner));

  static String get _lessonBannerId => kDebugMode
      ? AdMobIds.testBanner
      : (Platform.isIOS
          ? AdMobIds.iosBannerLesson
          : _safeAndroidId(AdMobIds.androidBannerLesson, AdMobIds.testBanner));

  static String get _interId => kDebugMode
      ? AdMobIds.testInterstitial
      : (Platform.isIOS
          ? AdMobIds.iosInterstitial
          : _safeAndroidId(AdMobIds.androidInterstitial, AdMobIds.testInterstitial));

  static String get _rewardedId => kDebugMode
      ? AdMobIds.testRewarded
      : (Platform.isIOS
          ? AdMobIds.iosRewarded
          : _safeAndroidId(AdMobIds.androidRewarded, AdMobIds.testRewarded));

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
    loadHomeBanner();
    loadLessonBanner();
    loadInterstitial();
    loadRewarded();
  }

  void loadHomeBanner() {
    _homeBanner?.dispose();
    _homeBanner = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _homeBannerReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _homeBanner = null;
          _homeBannerReady = false;
          if (kDebugMode) debugPrint('HomeBanner failed: $err');
        },
      ),
    )..load();
  }

  void loadLessonBanner() {
    _lessonBanner?.dispose();
    _lessonBanner = BannerAd(
      adUnitId: _lessonBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _lessonBannerReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _lessonBanner = null;
          _lessonBannerReady = false;
        },
      ),
    )..load();
  }

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialReady = true;
        },
        onAdFailedToLoad: (err) {
          _interstitialReady = false;
          if (kDebugMode) debugPrint('Interstitial failed: $err');
        },
      ),
    );
  }

  void loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (err) {
          if (kDebugMode) debugPrint('Rewarded failed: $err');
        },
      ),
    );
  }

  Future<void> onLessonComplete() async {
    _lessonsSinceAd++;
    if (_lessonsSinceAd >= 3 && _interstitialReady && _interstitial != null) {
      _lessonsSinceAd = 0;
      _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitial = null;
          _interstitialReady = false;
          loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          _interstitial = null;
          _interstitialReady = false;
          loadInterstitial();
        },
      );
      await _interstitial!.show();
    }
  }

  Future<bool> showRewarded({
    required void Function(int amount) onRewarded,
  }) async {
    final ad = _rewarded;
    if (ad == null) return false;
    _rewarded = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadRewarded();
      },
    );
    await ad.show(
      onUserEarnedReward: (_, reward) => onRewarded(reward.amount.toInt()),
    );
    return true;
  }

  @override
  void dispose() {
    _homeBanner?.dispose();
    _lessonBanner?.dispose();
    _interstitial?.dispose();
    _rewarded?.dispose();
    super.dispose();
  }
}
