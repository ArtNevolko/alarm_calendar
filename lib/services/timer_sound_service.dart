import 'package:just_audio/just_audio.dart';

class TimerSoundService {
  static final TimerSoundService _instance = TimerSoundService._internal();
  factory TimerSoundService() => _instance;
  TimerSoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playAsset(String fileName) async {
    try {
      await _player.setAsset('assets/audio/$fileName');
      await _player.setLoopMode(LoopMode.off);
      await _player.play();
    } catch (e) {
      // ignore: avoid_print
      print('Ошибка воспроизведения таймера: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
