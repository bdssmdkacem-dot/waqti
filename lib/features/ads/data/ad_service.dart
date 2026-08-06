import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/app_constants.dart';

// ── Manual provider ───────────────────────────────────────────
final adServiceProvider = Provider<AdService>(
  (ref) => AdService.instance,
);

// ── Service ───────────────────────────────────────────────────
class AdService extends ChangeNotifier {
  AdService._();
  static final AdService instance = AdService._();

  BannerAd?       _homeBanner;
  BannerAd?       _lessonBanner;
  InterstitialAd? _interstitial;
  RewardedAd?     _rewarded;

  bool _homeBannerReady   = false;
  bool _lessonBannerReady = false;
  bool _interstitialReady = false;
  int  _lessonsSinceAd   = 0;

  bool      get homeBannerReady   => _homeBannerReady;
  bool      get lessonBannerReady => _lessonBannerReady;
  BannerAd? get homeBanner        => _homeBanner;
  BannerAd? get lessonBanner      => _lessonBanner;

  // ── IDs ─────────────────────────────────────────────────────
  static String get _bannerId =>
      kDebugMode ? AdMobIds.testBanner
      : (Platform.isIOS ? AdMobIds.iosBannerHome : AdMobIds.androidBannerHome);

  static String get _lessonBannerId =>
      kDebugMode ? AdMobIds.testBanner
      : (Platform.isIOS ? AdMobIds.iosBannerLesson : AdMobIds.androidBannerLesson);

  static String get _interId =>
      kDebugMode ? AdMobIds.testInterstitial
      : (Platform.isIOS ? AdMobIds.iosInterstitial : AdMobIds.androidInterstitial);

  static String get _rewardedId =>
      kDebugMode ? AdMobIds.testRewarded
      : (Platform.isIOS ? AdMobIds.iosRewarded : AdMobIds.androidRewarded);

  // ── Initialization ───────────────────────────────────────────
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    // Required for children's app
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent:      TagForUnderAgeOfConsent.yes,
        maxAdContentRating:           MaxAdContentRating.g,
      ),
    );
    loadHomeBanner();
    loadLessonBanner();
    loadInterstitial();
    loadRewarded();
  }

  // ── Banner ads ───────────────────────────────────────────────
  void loadHomeBanner() {
    _homeBanner = BannerAd(
      adUnitId: _bannerId,
      size:     AdSize.banner,
      request:  const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _homeBannerReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _homeBannerReady = false;
          if (kDebugMode) debugPrint('HomeBanner failed: $err');
        },
      ),
    )..load();
  }

  void loadLessonBanner() {
    _lessonBanner = BannerAd(
      adUnitId: _lessonBannerId,
      size:     AdSize.banner,
      request:  const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _lessonBannerReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _lessonBannerReady = false;
        },
      ),
    )..load();
  }

  // ── Interstitial — every 3 lessons ──────────────────────────
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interId,
      request:  const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial     = ad;
          _interstitialReady = true;
        },
        onAdFailedToLoad: (err) {
          _interstitialReady = false;
          if (kDebugMode) debugPrint('Interstitial failed: $err');
        },
      ),
    );
  }

  // ── Rewarded ─────────────────────────────────────────────────
  void loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request:  const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded     = ad;
        },
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
          _interstitialReady = false;
          loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          loadInterstitial();
        },
      );
      await _interstitial!.show();
    }
  }

  Future<bool> showRewarded({
    required void Function(int amount) onRewarded,
  }) async {
    if (_rewarded == null) return false;
    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadRewarded();
      },
    );
    await _rewarded!.show(
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
