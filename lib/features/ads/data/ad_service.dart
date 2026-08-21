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
  BannerAd? _freePlayBanner;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  RewardedAd? _rewardedHint;
  Timer? _retryTimer;

  bool _initialized = false;
  bool _loadingAll = false;

  final Map<String, String> _errors = <String, String>{};

  bool _homeBannerReady = false;
  bool _lessonBannerReady = false;
  bool _freePlayBannerReady = false;
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _rewardedHintReady = false;

  String? get lastError => _errors.isEmpty ? null : _errors.values.last;
  String? errorFor(String type) => _errors[type];
  bool get initialized => _initialized;

  bool get homeBannerReady => _homeBannerReady;
  bool get lessonBannerReady => _lessonBannerReady;
  bool get freePlayBannerReady => _freePlayBannerReady;
  bool get interstitialReady => _interstitialReady;
  bool get rewardedReady => _rewardedReady;
  bool get rewardedHintReady => _rewardedHintReady;

  BannerAd? get homeBanner => _homeBanner;
  BannerAd? get lessonBanner => _lessonBanner;
  BannerAd? get freePlayBanner => _freePlayBanner;

  static String get _bannerId => kDebugMode
      ? AdMobIds.testBanner
      : (Platform.isIOS ? AdMobIds.iosBannerHome : AdMobIds.androidBannerHome);

  static String get _lessonBannerId => kDebugMode
      ? AdMobIds.testBanner
      : (Platform.isIOS
          ? AdMobIds.iosBannerLesson
          : AdMobIds.androidBannerLesson);

  static String get _interId => kDebugMode
      ? AdMobIds.testInterstitial
      : (Platform.isIOS
          ? AdMobIds.iosInterstitial
          : AdMobIds.androidInterstitial);

  static String get _rewardedId => kDebugMode
      ? AdMobIds.testRewarded
      : (Platform.isIOS ? AdMobIds.iosRewarded : AdMobIds.androidRewarded);

  static String get _rewardedHintId => kDebugMode
      ? AdMobIds.testRewarded
      : (Platform.isIOS
          ? AdMobIds.iosRewarded
          : AdMobIds.androidRewardedHint);

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Waqti is a mixed-audience app. Do not force child/under-age flags.
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );

      final status = await MobileAds.instance.initialize();
      _initialized = true;

      debugPrint('Waqti AdMob initialized: ${status.adapterStatuses}');
      for (final entry in status.adapterStatuses.entries) {
        debugPrint(
          'Waqti AdMob adapter ${entry.key}: '
          'state=${entry.value.state}, '
          'description=${entry.value.description}, '
          'latency=${entry.value.latency}',
        );
      }

      notifyListeners();
      _loadAll();
    } catch (error, stackTrace) {
      _errors['SDK'] = 'SDK initialization failed: $error';
      debugPrint('Waqti AdMob SDK initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
      _scheduleRetry();
      rethrow;
    }
  }

  void reloadAll() {
    if (!_initialized) {
      unawaited(initialize());
      return;
    }
    _loadAll();
  }

  void _loadAll() {
    if (!_initialized || _loadingAll) return;
    _loadingAll = true;
    try {
      loadHomeBanner();
      loadLessonBanner();
      loadFreePlayBanner();
      loadInterstitial();
      loadRewarded();
      loadRewardedHint();
    } finally {
      _loadingAll = false;
    }
  }

  void _recordError(String type, LoadAdError error) {
    final message =
        '$type: code=${error.code}, domain=${error.domain}, '
        'message=${error.message}, responseInfo=${error.responseInfo}';
    _errors[type] = message;
    debugPrint('Waqti AdMob $message');
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
    if (!_initialized) return;
    _homeBanner?.dispose();
    _homeBannerReady = false;
    _homeBanner = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _homeBannerReady = true;
          _recordLoaded('Home Banner', _bannerId);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _homeBanner = null;
          _homeBannerReady = false;
          _recordError('Home Banner', error);
        },
      ),
    )..load();
  }

  void loadLessonBanner() {
    if (!_initialized) return;
    _lessonBanner?.dispose();
    _lessonBannerReady = false;
    _lessonBanner = BannerAd(
      adUnitId: _lessonBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _lessonBannerReady = true;
          _recordLoaded('Lesson Banner', _lessonBannerId);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _lessonBanner = null;
          _lessonBannerReady = false;
          _recordError('Lesson Banner', error);
        },
      ),
    )..load();
  }

  // A BannerAd cannot safely be mounted in Home and Free Play at the same
  // time. Use a separate BannerAd instance, even though the unit ID is shared.
  void loadFreePlayBanner() {
    if (!_initialized) return;
    _freePlayBanner?.dispose();
    _freePlayBannerReady = false;
    _freePlayBanner = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _freePlayBannerReady = true;
          _recordLoaded('Free Play Banner', _bannerId);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _freePlayBanner = null;
          _freePlayBannerReady = false;
          _recordError('Free Play Banner', error);
        },
      ),
    )..load();
  }

  void loadInterstitial() {
    if (!_initialized) return;
    _interstitial?.dispose();
    _interstitial = null;
    _interstitialReady = false;
    InterstitialAd.load(
      adUnitId: _interId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialReady = true;
          _recordLoaded('Interstitial', _interId);
        },
        onAdFailedToLoad: (error) {
          _interstitialReady = false;
          _recordError('Interstitial', error);
        },
      ),
    );
  }

  void loadRewarded() {
    if (!_initialized) return;
    _rewarded?.dispose();
    _rewarded = null;
    _rewardedReady = false;
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedReady = true;
          _recordLoaded('Rewarded', _rewardedId);
        },
        onAdFailedToLoad: (error) {
          _rewardedReady = false;
          _recordError('Rewarded', error);
        },
      ),
    );
  }

  void loadRewardedHint() {
    if (!_initialized) return;
    _rewardedHint?.dispose();
    _rewardedHint = null;
    _rewardedHintReady = false;
    RewardedAd.load(
      adUnitId: _rewardedHintId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedHint = ad;
          _rewardedHintReady = true;
          _recordLoaded('Rewarded Hint', _rewardedHintId);
        },
        onAdFailedToLoad: (error) {
          _rewardedHintReady = false;
          _recordError('Rewarded Hint', error);
        },
      ),
    );
  }

  Future<void> onLessonComplete() async {
    final ad = _interstitial;
    if (ad == null || !_interstitialReady) {
      loadInterstitial();
      return;
    }

    _interstitial = null;
    _interstitialReady = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Waqti Interstitial show failed: $error');
        ad.dispose();
        loadInterstitial();
      },
    );
    await ad.show();
  }

  Future<bool> showRewarded({
    required void Function(int amount) onRewarded,
  }) async {
    final ad = _rewarded;
    if (ad == null || !_rewardedReady) {
      loadRewarded();
      return false;
    }

    _rewarded = null;
    _rewardedReady = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Waqti Rewarded show failed: $error');
        ad.dispose();
        loadRewarded();
      },
    );
    await ad.show(
      onUserEarnedReward: (_, reward) {
        onRewarded(reward.amount.toInt());
      },
    );
    return true;
  }

  Future<bool> showRewardedHint({
    required void Function(int amount) onRewarded,
  }) async {
    final ad = _rewardedHint;
    if (ad == null || !_rewardedHintReady) {
      loadRewardedHint();
      return false;
    }

    _rewardedHint = null;
    _rewardedHintReady = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedHint();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Waqti Rewarded Hint show failed: $error');
        ad.dispose();
        loadRewardedHint();
      },
    );
    await ad.show(
      onUserEarnedReward: (_, reward) {
        onRewarded(reward.amount.toInt());
      },
    );
    return true;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _homeBanner?.dispose();
    _lessonBanner?.dispose();
    _freePlayBanner?.dispose();
    _interstitial?.dispose();
    _rewarded?.dispose();
    _rewardedHint?.dispose();
    super.dispose();
  }
}
