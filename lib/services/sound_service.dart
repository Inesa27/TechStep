import 'package:audioplayers/audioplayers.dart';

/// Centralizes short, user-triggered sound effects used throughout TechStep.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playClick() => _play('audio/click.wav', 0.36);

  Future<void> playCorrect() => _play('audio/correct.wav', 0.48);

  Future<void> playIncorrect() => _play('audio/incorrect.wav', 0.42);

  Future<void> playComplete() => _play('audio/complete.wav', 0.52);

  Future<void> _play(String assetPath, double volume) async {
    try {
      // A single player keeps brief SFX from piling up over one another.
      await _player.stop();
      await _player.setVolume(volume);
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Sound is optional; a missing/blocked audio device must not affect UX.
    }
  }
}
