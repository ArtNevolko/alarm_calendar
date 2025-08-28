import 'package:flutter/material.dart';
import 'package:alarm_calendar/core/audio/audio_player_service.dart'
    show AudioPlayerService, RingtoneInfo, PlaybackUiState, PlaybackStatus;

class SoundSelectorWidget extends StatefulWidget {
  final String selectedSound;
  final ValueChanged<String> onChanged;
  const SoundSelectorWidget({
    super.key,
    required this.selectedSound,
    required this.onChanged,
  });

  @override
  State<SoundSelectorWidget> createState() => _SoundSelectorWidgetState();
}

class _SoundSelectorWidgetState extends State<SoundSelectorWidget> {
  List<RingtoneInfo> _list = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await AudioPlayerService.instance.initialize();
    final l = await AudioPlayerService.instance.getAllRingtones();
    if (mounted) setState(() => _list = l);
  }

  Future<void> _add() async {
    final r = await AudioPlayerService.instance.addCustomRingtone(context);
    if (r != null) _init();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Мелодии',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: ValueListenableBuilder<PlaybackUiState>(
                  valueListenable:
                      AudioPlayerService.instance.playbackStateNotifier,
                  builder: (_, playState, __) {
                    return ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (_, i) {
                        final r = _list[i];
                        final sel = r.id == widget.selectedSound;
                        final isLoading = playState.status == PlaybackStatus.loading && playState.id == r.id;
                        final isPlaying = playState.status == PlaybackStatus.playing && playState.id == r.id;
                        final isError = playState.status == PlaybackStatus.error && playState.id == r.id;
                        return ListTile(
                          leading: Icon(
                            r.icon,
                            color: (isPlaying || sel)
                                ? Colors.deepPurple
                                : (isError ? Colors.red : null),
                          ),
                          title: Text(r.name),
                          subtitle: isError
                              ? const Text('Ошибка воспроизведения',
                                  style: TextStyle(color: Colors.red))
                              : (r.isCustom
                                  ? const Text('Пользовательская')
                                  : null),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (w, anim) =>
                                    ScaleTransition(scale: anim, child: w),
                                child: isLoading
                                    ? SizedBox(
                                        key: const ValueKey('loading'),
                                        width: 24,
                                        height: 24,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.deepPurple,
                                        ),
                                      )
                                    : IconButton(
                                        key: ValueKey<String>(isPlaying
                                            ? 'stop'
                                            : (isError ? 'error' : 'play')),
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.stop_circle
                                              : isError
                                                  ? Icons.error_outline
                                                  : Icons.play_arrow,
                                          color: isError
                                              ? Colors.red
                                              : Colors.deepPurple,
                                        ),
                                        onPressed: () async {
                                          if (isPlaying) {
                                            await AudioPlayerService.instance
                                                .stopPlayback();
                                          } else {
                                            await AudioPlayerService.instance
                                                .playRingtone(r.id);
                                          }
                                          if (mounted) setState(() {});
                                        },
                                      ),
                              ),
                              if (r.isCustom)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await AudioPlayerService.instance
                                        .deleteCustomRingtone(r.id);
                                    if (!mounted) return;
                                    await _init();
                                  },
                                ),
                              if (sel)
                                const Icon(Icons.check, color: Colors.green),
                            ],
                          ),
                          onTap: () {
                            widget.onChanged(r.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Добавить свою мелодию'),
              ),
              TextButton(
                onPressed: () {
                  AudioPlayerService.instance.stopPlayback();
                  Navigator.pop(context);
                },
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
