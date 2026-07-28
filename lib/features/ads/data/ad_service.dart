import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';

part 'ad_service.g.dart';

class AdService extends ChangeNotifier {
  AdService._();
  static final AdService instance = AdService._();

  BannerAd? _homeBanner;
  BannerAd? _lessonBanner;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  bool _homeBannerReady   = false;
  bool _lessonBannerReady = false;
  bool _interstitialReady = false;
  bool _rewardedReady     = false;
  int  _lessonsSinceAd    = 0;

  bool get homeBannerReady    => _homeBannerReady;
  bool get lessonBannerReady  => _lessonBannerReady;
  BannerAd? get homeBanner    => _homeBanner;
  BannerAd? get lessonBanner  => _lessonBanner;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();

    // ── REQUIRED for children's apps ──────────────────────
    // Without this, Google may suspend your AdMob account if the app
    // is categorised as a children's app on Play Store / App Store.
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

  // ── Banner — Home screen ───────────────────────────────────
  void loadHomeBanner() {
    _homeBanner = BannerAd(
      adUnitId: Platform.isIOS
          ? AdMobIds.iosBannerHome
          : AdMobIds.androidBannerHome,
      size:    AdSize.banner,
      request: const AdRequest(),
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

  // ── Banner — Lesson finish screen ──────────────────────────
  void loadLessonBanner() {
    _lessonBanner = BannerAd(
      adUnitId: Platform.isIOS
          ? AdMobIds.iosBannerLesson
          : AdMobIds.androidBannerLesson,
      size:    AdSize.banner,
      request: const AdRequest(),
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

  // ── Interstitial — shown every 3 completed lessons ─────────
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: Platform.isIOS
          ? AdMobIds.iosInterstitial
          : AdMobIds.androidInterstitial,
      request: const AdRequest(),
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

  // ── Rewarded — unlock a hint ───────────────────────────────
  void loadRewarded() {
    RewardedAd.load(
      adUnitId: Platform.isIOS
          ? AdMobIds.iosRewarded
          : AdMobIds.androidRewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded     = ad;
          _rewardedReady = true;
        },
        onAdFailedToLoad: (err) {
          _rewardedReady = false;
        },
      ),
    );
  }

  // ── Call after every lesson completion ─────────────────────
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

  // ── Rewarded ad — call from hint button ────────────────────
  Future<bool> showRewarded({
    required void Function(int amount) onRewarded,
  }) async {
    if (!_rewardedReady || _rewarded == null) return false;
    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedReady = false;
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

@Riverpod(keepAlive: true)
AdService adService(AdServiceRef ref) => AdService.instance;
