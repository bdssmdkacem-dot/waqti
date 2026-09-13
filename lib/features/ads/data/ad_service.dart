import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/app_constants.dart';

final adServiceProvider = ChangeNotifierProvider<AdService>(
  (ref) => AdService.instance,
);

class AdService extends ChangeNotifier {
  AdService._();
  static final AdService instance = AdService._();

  BannerAd? _homeBanner;
  BannerAd? _lessonBanner;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  RewardedAd? _rewardedHint;
  Timer? _retryTimer;
  bool _initialized = false;

  int _lessonCompletionsSinceInterstitial = 0;
  static const int _interstitialFrequency = 2;

  final Map<String, String> _errors = {};

  bool _homeBannerReady = false;
  bool _lessonBannerReady = false;
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _rewardedHintReady = false;

  String? get lastError => _errors.isEmpty ? null : _errors.values.last;
  String? errorFor(String type) => _errors[type];
  bool get homeBannerReady => _homeBannerReady;
  bool get lessonBannerReady => _lessonBannerReady;
  bool get interstitialReady => _interstitialReady;
  bool get rewardedReady => _rewardedReady;
  bool get rewardedHintReady => _rewardedHintReady;
  BannerAd? get homeBanner => _homeBanner;
  BannerAd? get lessonBanner => _lessonBanner;

  static String get _bannerId => kDebugMode
      ? AdMobIds.testBanner
      : (Platform.isIOS ? AdMobIds.iosBannerHome : AdMobIds.androidBannerHome);
  static String get _lessonBannerId => kDebugMode
      ? AdMobIds.testBanner
      : (Platform.isIOS ? AdMobIds.iosBannerLesson : AdMobIds.androidBannerLesson);
  static String get _interId => kDebugMode
      ? AdMobIds.testInterstitial
      : (Platform.isIOS ? AdMobIds.iosInterstitial : AdMobIds.androidInterstitial);
  static String get _rewardedId => kDebugMode
      ? AdMobIds.testRewarded
      : (Platform.isIOS ? AdMobIds.iosRewarded : AdMobIds.androidRewarded);
  static String get _rewardedHintId => kDebugMode
      ? AdMobIds.testRewarded
      : (Platform.isIOS ? AdMobIds.testRewarded : AdMobIds.androidRewardedHint);

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
      );
      final status = await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('Waqti AdMob initialized: ${status.adapterStatuses}');
      _loadAll();
    } catch (e, st) {
      debugPrint('Waqti AdMob initialization failed: $e\n$st');
      _initialized = false;
    }
  }

  void _loadAll() {
    loadHomeBanner();
    loadLessonBanner();
    loadInterstitial();
    unawaited(loadRewarded());
    unawaited(loadRewardedHint());
  }

  void _recordError(String type, LoadAdError error) {
    _errors[type] = '$type: code=${error.code}, domain=${error.domain}, message=${error.message}';
    debugPrint('Waqti AdMob ${_errors[type]}');
    notifyListeners();
    _scheduleRetry();
  }

  void _recordLoaded(String type, String adUnitId) {
    _errors.remove(type);
    debugPrint('Waqti AdMob $type loaded: $adUnitId');
    notifyListeners();
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive ?? false) return;
    _retryTimer = Timer(const Duration(seconds: 20), () {
      _retryTimer = null;
      if (_initialized) _loadAll();
    });
  }

  void loadHomeBanner() {
    _homeBanner?.dispose();
    _homeBannerReady = false;
    _homeBanner = BannerAd(
      adUnitId: _bannerId, size: AdSize.banner, request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { _homeBannerReady = true; _recordLoaded('Home Banner', _bannerId); },
        onAdFailedToLoad: (ad, error) { ad.dispose(); _homeBanner = null; _homeBannerReady = false; _recordError('Home Banner', error); },
      ),
    )..load();
  }

  void loadLessonBanner() {
    _lessonBanner?.dispose();
    _lessonBannerReady = false;
    _lessonBanner = BannerAd(
      adUnitId: _lessonBannerId, size: AdSize.banner, request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { _lessonBannerReady = true; _recordLoaded('Lesson Banner', _lessonBannerId); },
        onAdFailedToLoad: (ad, error) { ad.dispose(); _lessonBanner = null; _lessonBannerReady = false; _recordError('Lesson Banner', error); },
      ),
    )..load();
  }

  void loadInterstitial() {
    _interstitial?.dispose(); _interstitial = null; _interstitialReady = false;
    InterstitialAd.load(
      adUnitId: _interId, request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) { _interstitial = ad; _interstitialReady = true; _recordLoaded('Interstitial', _interId); },
        onAdFailedToLoad: (error) { _interstitialReady = false; _recordError('Interstitial', error); },
      ),
    );
  }

  Future<void> loadRewarded() async {
    _rewarded?.dispose();
    _rewarded = null;
    _rewardedReady = false;
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedReady = true;
          _recordLoaded('Rewarded', _rewardedId);
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _rewardedReady = false;
          _recordError('Rewarded', error);
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    await completer.future.timeout(const Duration(seconds: 10), onTimeout: () {});
  }

  Future<void> loadRewardedHint() async {
    _rewardedHint?.dispose();
    _rewardedHint = null;
    _rewardedHintReady = false;
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: _rewardedHintId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedHint = ad;
          _rewardedHintReady = true;
          _recordLoaded('Rewarded Hint', _rewardedHintId);
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _rewardedHintReady = false;
          _recordError('Rewarded Hint', error);
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    await completer.future.timeout(const Duration(seconds: 10), onTimeout: () {});
  }

  Future<void> onLessonComplete() async {
    _lessonCompletionsSinceInterstitial++;
    if (_lessonCompletionsSinceInterstitial < _interstitialFrequency) {
      if (!_interstitialReady) loadInterstitial();
      return;
    }
    _lessonCompletionsSinceInterstitial = 0;
    final ad = _interstitial;
    if (ad == null || !_interstitialReady) { loadInterstitial(); return; }
    _interstitial = null; _interstitialReady = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); loadInterstitial(); },
      onAdFailedToShowFullScreenContent: (ad, error) { debugPrint('Waqti Interstitial show failed: $error'); ad.dispose(); loadInterstitial(); },
    );
    await ad.show();
  }

  Future<bool> showRewarded({required void Function(int amount) onRewarded}) async {
    if (_rewarded == null || !_rewardedReady) {
      await loadRewarded();
    }
    final ad = _rewarded;
    if (ad == null || !_rewardedReady) return false;
    _rewarded = null; _rewardedReady = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); unawaited(loadRewarded()); },
      onAdFailedToShowFullScreenContent: (ad, error) { debugPrint('Waqti Rewarded show failed: $error'); ad.dispose(); unawaited(loadRewarded()); },
    );
    await ad.show(onUserEarnedReward: (_, reward) => onRewarded(reward.amount.toInt()));
    return true;
  }

  Future<bool> showRewardedHint({required void Function(int amount) onRewarded}) async {
    if (_rewardedHint == null || !_rewardedHintReady) {
      await loadRewardedHint();
    }
    final ad = _rewardedHint;
    if (ad == null || !_rewardedHintReady) return false;
    _rewardedHint = null; _rewardedHintReady = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); unawaited(loadRewardedHint()); },
      onAdFailedToShowFullScreenContent: (ad, error) { debugPrint('Waqti Rewarded Hint show failed: $error'); ad.dispose(); unawaited(loadRewardedHint()); },
    );
    await ad.show(onUserEarnedReward: (_, reward) => onRewarded(reward.amount.toInt()));
    return true;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _homeBanner?.dispose();
    _lessonBanner?.dispose();
    _interstitial?.dispose();
    _rewarded?.dispose();
    _rewardedHint?.dispose();
    super.dispose();
  }
}
