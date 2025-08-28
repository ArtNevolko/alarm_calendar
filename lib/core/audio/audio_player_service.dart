import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class RingtoneInfo {
  final String id;
  final String name;
  final String path;
  final IconData icon;
  final bool isCustom;
  const RingtoneInfo({
    required this.id,
    required this.name,
    required this.path,
    this.icon = Icons.music_note,
    this.isCustom = false,
  });
}

enum PlaybackStatus { idle, loading, playing, error }

class PlaybackUiState {
  final String? id;
  final PlaybackStatus status;
  const PlaybackUiState({this.id, this.status = PlaybackStatus.idle});

  PlaybackUiState copyWith({String? id, PlaybackStatus? status, bool clearId = false}) =>
      PlaybackUiState(
        id: clearId ? null : (id ?? this.id),
        status: status ?? this.status,
      );
}

class AudioPlayerService {
  AudioPlayerService._internal();
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  static AudioPlayerService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  final List<RingtoneInfo> _ringtones = [];
  bool _inited = false;
  bool _initRunning = false;
  String? _currentPlayingId;
  // Заменяем прежний ValueNotifier<String?> на полноценный state
  final ValueNotifier<PlaybackUiState> playbackStateNotifier =
      ValueNotifier<PlaybackUiState>(const PlaybackUiState());

  // + публичные геттеры
  String? get currentPlayingId => _currentPlayingId;
  bool isPlaying(String id) =>
      playbackStateNotifier.value.status == PlaybackStatus.playing &&
      playbackStateNotifier.value.id == id;

  Future<void> initialize() async {
    if (_inited || _initRunning) return;
    _initRunning = true;
    _ringtones.addAll(const [
      RingtoneInfo(
        id: 'default',
        name: 'Стандартная мелодия',
        path: 'assets/audio/alarm_default.mp3',
        icon: Icons.access_alarm,
      ),
      RingtoneInfo(
        id: 'rain',
        name: 'Дождь',
        path: 'assets/audio/rain.mp3',
        icon: Icons.water_drop,
      ),
      RingtoneInfo(
        id: 'sea',
        name: 'Море',
        path: 'assets/audio/sea.mp3',
        icon: Icons.waves,
      ),
    ]);
    await _loadCustom();
    // Подписка на состояние плеера
    _player.playerStateStream.listen((st) {
      // Завершение или остановка
      if (st.processingState == ProcessingState.completed ||
          !st.playing && st.processingState == ProcessingState.idle) {
        _currentPlayingId = null;
        playbackStateNotifier.value =
            playbackStateNotifier.value.copyWith(status: PlaybackStatus.idle, clearId: true);
      }
    });
    _inited = true;
    _initRunning = false;
  }

  Future<void> _ensure() => initialize();

  Future<void> _loadCustom() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final customDir = Directory('${dir.path}/ringtones');
      if (!await customDir.exists()) return;
      // Асинхронный обход — не блокируем UI
      await for (final entity in customDir.list()) {
        if (entity is! File) continue;
        final p = entity.path.toLowerCase();
        if (!(p.endsWith('.mp3') || p.endsWith('.wav') || p.endsWith('.m4a'))) continue;
        final name = entity.uri.pathSegments.last;
        final id = 'custom_$name';
        if (_ringtones.any((r) => r.id == id)) continue;
        _ringtones.add(RingtoneInfo(
          id: id,
            name: name.split('.').first,
            path: entity.path,
            isCustom: true,
        ));
      }
    } catch (_) {}
  }

  Future<void> preloadRingtones() async {
    await _ensure();
  }

  Future<RingtoneInfo?> addCustomRingtone(BuildContext context) async {
    await _ensure();
    try {
      final pick = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (pick == null || pick.files.single.path == null) return null;
      final src = File(pick.files.single.path!);
      final dir = await getApplicationDocumentsDirectory();
      final customDir = Directory('${dir.path}/ringtones');
      if (!await customDir.exists()) await customDir.create(recursive: true);
      final fileName = src.uri.pathSegments.last;
      final dest = '${customDir.path}/$fileName';
      await src.copy(dest);
      final r = RingtoneInfo(
        id: 'custom_$fileName',
        name: fileName.split('.').first,
        path: dest,
        isCustom: true,
      );
      _ringtones.removeWhere((e) => e.id == r.id);
      _ringtones.add(r);
      return r;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteCustomRingtone(String id) async {
    await _ensure();
    try {
      final i = _ringtones.indexWhere((r) => r.id == id);
      if (i == -1) return false;
      final r = _ringtones[i];
      if (!r.isCustom) return false;
      final f = File(r.path);
      if (await f.exists()) await f.delete();
      _ringtones.removeAt(i);
      // Если удалили текущую — остановим
      if (_currentPlayingId == id) {
        await stopPlayback();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<RingtoneInfo>> getAllRingtones() async {
    await _ensure();
    return List.unmodifiable(_ringtones);
  }

  RingtoneInfo? getRingtoneById(String id) {
    try {
      return _ringtones.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> playRingtone(String id) async {
    await _ensure();
    // Toggle если уже играет
    if (_currentPlayingId == id &&
        playbackStateNotifier.value.status == PlaybackStatus.playing) {
      await stopPlayback();
      return;
    }
    final r = getRingtoneById(id);
    if (r == null) return;

    _currentPlayingId = id;
    playbackStateNotifier.value =
        PlaybackUiState(id: id, status: PlaybackStatus.loading);

    try {
      if (_player.playing) {
        await _player.stop();
      }
      if (r.isCustom) {
        await _player.setFilePath(r.path);
      } else {
        await _player.setAsset(r.path);
      }
      await _player.setLoopMode(LoopMode.off); // гарантируем одиночное прослушивание
      await _player.setVolume(1.0);
      playbackStateNotifier.value =
          PlaybackUiState(id: id, status: PlaybackStatus.playing);
      await _player.play();
    } catch (_) {
      _currentPlayingId = null;
      playbackStateNotifier.value =
          PlaybackUiState(id: id, status: PlaybackStatus.error);
      // Авто-сброс ошибки через короткий интервал
      Future.delayed(const Duration(seconds: 2), () {
        if (playbackStateNotifier.value.status == PlaybackStatus.error &&
            playbackStateNotifier.value.id == id) {
          playbackStateNotifier.value =
              const PlaybackUiState(status: PlaybackStatus.idle);
        }
      });
    }
  }

  Future<void> playRingtoneLoop(String id) async {
    // Зацикленное воспроизведение для активного будильника
    await _ensure();
    final r = getRingtoneById(id);
    if (r == null) return;
    try {
      if (_player.playing) {
        await _player.stop();
      }
      if (r.isCustom) {
        await _player.setFilePath(r.path);
      } else {
        await _player.setAsset(r.path);
      }
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1.0);
      await _player.play();
    } catch (_) {}
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (_) {}
    _currentPlayingId = null;
    playbackStateNotifier.value =
        const PlaybackUiState(status: PlaybackStatus.idle);
  }

  void dispose() {
    _player.dispose();
    playbackStateNotifier.dispose();
  }
}
