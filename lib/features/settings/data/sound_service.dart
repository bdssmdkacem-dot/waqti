import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sound_service.g.dart';

enum WaqtiSound {
  click, correct, wrong, success,
  lessonComplete, levelUp, streak, reward,
  countdown, notification,
}

const _assets = <WaqtiSound, String>{
  WaqtiSound.click:          'sounds/click.mp3',
  WaqtiSound.correct:        'sounds/correct.mp3',
  WaqtiSound.wrong:          'sounds/wrong.mp3',
  WaqtiSound.success:        'sounds/success.mp3',
  WaqtiSound.lessonComplete: 'sounds/lesson_complete.mp3',
  WaqtiSound.levelUp:        'sounds/level_up.mp3',
  WaqtiSound.streak:         'sounds/streak.mp3',
  WaqtiSound.reward:         'sounds/reward.mp3',
  WaqtiSound.countdown:      'sounds/countdown.mp3',
  WaqtiSound.notification:   'sounds/notification.mp3',
};

const _poolSize = <WaqtiSound, int>{
  WaqtiSound.click:     3,
  WaqtiSound.countdown: 4,
};

class SoundService extends ChangeNotifier {
  SoundService._();
  static final SoundService instance = SoundService._();

  final _pools  = <WaqtiSound, List<AudioPlayer>>{};
  final _idx    = <WaqtiSound, int>{};
  bool _muted   = false;
  bool _ready   = false;
  double _volume = 1.0;

  bool get isMuted => _muted;
  bool get isReady => _ready;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_ready) return;
    final p = await SharedPreferences.getInstance();
    _muted  = !(p.getBool('sound_on') ?? true);
    _volume = p.getDouble('sound_volume') ?? 1.0;

    for (final evt in WaqtiSound.values) {
      final size = _poolSize[evt] ?? 1;
      final players = <AudioPlayer>[];
      for (int i = 0; i < size; i++) {
        final pl = AudioPlayer();
        await pl.setReleaseMode(ReleaseMode.stop);
        await pl.setVolume(_volume);
        players.add(pl);
      }
      _pools[evt] = players;
      _idx[evt]   = 0;
    }

    // Preload
    for (final e in _assets.entries) {
      try {
        await _pools[e.key]!.first.setSource(AssetSource(e.value));
      } catch (_) {}
    }

    _ready = true;
    if (kDebugMode) debugPrint('🔊 SoundService ready (muted=$_muted)');
  }

  Future<void> play(WaqtiSound sound) async {
    if (_muted || !_ready) return;
    final pool  = _pools[sound];
    final asset = _assets[sound];
    if (pool == null || asset == null) return;

    final i  = _idx[sound] ?? 0;
    final pl = pool[i];
    _idx[sound] = (i + 1) % pool.length;

    try {
      await pl.stop();
      await pl.play(AssetSource(asset));
    } catch (e) {
      if (kDebugMode) debugPrint('Sound error: $e');
    }
  }

  Future<void> stop(WaqtiSound sound) async {
    for (final pl in _pools[sound] ?? []) { await pl.stop(); }
  }

  Future<void> stopAll() async {
    for (final pool in _pools.values) {
      for (final pl in pool) { await pl.stop(); }
    }
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) await stopAll();
    final p = await SharedPreferences.getInstance();
    await p.setBool('sound_on', !_muted);
    notifyListeners();
    if (!_muted) await play(WaqtiSound.click);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    for (final pool in _pools.values) {
      for (final pl in pool) { await pl.setVolume(_volume); }
    }
    final p = await SharedPreferences.getInstance();
    await p.setDouble('sound_volume', _volume);
    notifyListeners();
  }

  // Convenience shortcuts
  Future<void> click()          => play(WaqtiSound.click);
  Future<void> correct()        => play(WaqtiSound.correct);
  Future<void> wrong()          => play(WaqtiSound.wrong);
  Future<void> success()        => play(WaqtiSound.success);
  Future<void> lessonComplete() => play(WaqtiSound.lessonComplete);
  Future<void> levelUp()        => play(WaqtiSound.levelUp);
  Future<void> streak()         => play(WaqtiSound.streak);
  Future<void> reward()         => play(WaqtiSound.reward);
  Future<void> countdown()      => play(WaqtiSound.countdown);
  Future<void> notification()   => play(WaqtiSound.notification);

  @override
  Future<void> dispose() async {
    for (final pool in _pools.values) {
      for (final pl in pool) { await pl.dispose(); }
    }
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
SoundService soundService(SoundServiceRef ref) => SoundService.instance;
