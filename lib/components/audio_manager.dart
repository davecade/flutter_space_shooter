import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioManager extends Component {
  bool musicEnabled = true;
  bool soundsEnabled = true;

  final Map<String, AudioPool> _soundPools = {};
  final Map<String, DateTime> _lastPlayed = {};
  final Map<String, int> _activePlayers = {};

  static const int _maxSoundsPerFrame = 6;
  static const int _cooldownMs = 40;

  int _soundsThisFrame = 0;
  bool _ready = false;

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();

    // Preload all audio to prevent cache race crashes
    await FlameAudio.audioCache.loadAll([
      'music.ogg',
      'laser.ogg',
      'hit.ogg',
      'fire.ogg',
      'explode1.ogg',
      'explode2.ogg',
      'collect.ogg',
      'click.ogg',
      'start.ogg',
    ]);

    await _createPool('laser', 4);
    await _createPool('hit', 2);
    await _createPool('fire', 2);
    await _createPool('explode1', 3);
    await _createPool('explode2', 3);
    await _createPool('collect', 1);
    await _createPool('click', 1);
    await _createPool('start', 1);

    _ready = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _soundsThisFrame = 0;
  }

  Future<void> _createPool(String sound, int maxPlayers) async {
    _activePlayers[sound] = 0;

    _soundPools[sound] = await FlameAudio.createPool(
      '$sound.ogg',
      maxPlayers: maxPlayers,
    );
  }

  // ---------------- MUSIC ----------------

  void playMusic() {
    // if (!musicEnabled || !_ready) return;
    // FlameAudio.bgm.play('music.ogg', volume: 0.5);
  }

  void stopMusic() {
    FlameAudio.bgm.stop();
  }

  void toggleMusic() {
    musicEnabled = !musicEnabled;
    musicEnabled ? playMusic() : stopMusic();
  }

  // ---------------- SOUND EFFECTS ----------------

  void playSound(String sound) {
    if (!soundsEnabled || !_ready) return;

    if (_soundsThisFrame >= _maxSoundsPerFrame) return;

    final pool = _soundPools[sound];
    if (pool == null) return;

    final int currentPlayers = _activePlayers[sound] ?? 0;
    final int maxPlayers = pool.maxPlayers;

    // Block if pool is full
    if (currentPlayers >= maxPlayers) return;

    final now = DateTime.now();
    final last = _lastPlayed[sound];

    if (last != null && now.difference(last).inMilliseconds < _cooldownMs) {
      return;
    }

    _lastPlayed[sound] = now;
    _activePlayers[sound] = currentPlayers + 1;

    try {
      _soundsThisFrame++;
      pool.start().whenComplete(() {
        _activePlayers[sound] = (_activePlayers[sound] ?? 1) - 1;
      });
    } catch (e) {
      _activePlayers[sound] = (_activePlayers[sound] ?? 1) - 1;
      debugPrint('Audio error [$sound]: $e');
    }
  }

  void toggleSounds() {
    soundsEnabled = !soundsEnabled;
  }

  // ---------------- CLEANUP ----------------

  @override
  void onRemove() {
    for (final pool in _soundPools.values) {
      pool.dispose();
    }
    FlameAudio.bgm.dispose();
    super.onRemove();
  }
}
