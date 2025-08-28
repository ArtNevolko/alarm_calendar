import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/alarm/alarm_bloc.dart';
import '../../../core/audio/audio_player_service.dart'
    show AudioPlayerService, RingtoneInfo, PlaybackUiState, PlaybackStatus;
import '../../../services/notification_service.dart' show NotificationService;

class CreateAlarmScreen extends StatefulWidget {
  final AlarmModel? alarm;
  const CreateAlarmScreen({super.key, this.alarm});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  final _label = TextEditingController();
  final _audio = AudioPlayerService.instance;

  late TimeOfDay _time;
  late List<DateTime> _dates;
  late String _ringtoneId;
  String? _alarmId;
  RingtoneInfo? _ringtoneInfo;

  @override
  void initState() {
    super.initState();
    _time = widget.alarm != null ? _parseTime(widget.alarm!.time) : TimeOfDay.now();
    _dates = widget.alarm?.dates.toList() ?? [];
    _ringtoneId = widget.alarm?.ringtone ?? 'default';
    _alarmId = widget.alarm?.id;
    _label.text = widget.alarm?.label ?? '';
    // Переносим тяжелую инициализацию за первый кадр
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAudio();
    });
  }

  Future<void> _initAudio() async {
    await _audio.initialize();
    await _audio.preloadRingtones();
    if (!mounted) return;
    setState(() => _ringtoneInfo = _audio.getRingtoneById(_ringtoneId));
  }

  TimeOfDay _parseTime(String s) {
    final p = s.split(':');
    if (p.length == 2) {
      final h = int.tryParse(p[0]) ?? 0;
      final m = int.tryParse(p[1].split(' ').first) ?? 0;
      return TimeOfDay(hour: h, minute: m);
    }
    return TimeOfDay.now();
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fmt(DateTime d) {
    const m = ['янв','фев','мар','апр','май','июн','июл','авг','сен','окт','ноя','дек'];
    return '${d.day} ${m[d.month - 1]}';
  }

  void _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null && mounted) setState(() => _time = t);
  }

  void _pickDates() {
    showDialog(
      context: context,
      builder: (_) {
        final temp = Set<DateTime>.from(_dates);
        return StatefulBuilder(
          builder: (c, setS) {
            return AlertDialog(
              title: const Text('Выберите даты'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 300,
                      child: CalendarDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        onDateChanged: (d) {
                          setS(() {
                            if (temp.any((e) => _same(e, d))) {
                              temp.removeWhere((e) => _same(e, d));
                            } else {
                              temp.add(d);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (temp.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: temp
                            .map((d) => Chip(
                                  label: Text(_fmt(d)),
                                  onDeleted: () => setS(() {
                                    temp.removeWhere((e) => _same(e, d));
                                  }),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => setS(() => temp.clear()),
                  child: const Text('Очистить'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _dates = temp.toList());
                    Navigator.pop(context);
                  },
                  child: const Text('Готово'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickRingtone() async {
    final ctx = context; // локальная ссылка
    await _audio.stopPlayback();
    String current = _ringtoneId;
    final result = await showModalBottomSheet<String>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setM) {
            return FutureBuilder<List<RingtoneInfo>>(
              future: _audio.getAllRingtones(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()));
                }
                final list = snap.data!;
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Выберите мелодию',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ValueListenableBuilder<PlaybackUiState>(
                          valueListenable: _audio.playbackStateNotifier,
                          builder: (_, playState, __) {
                            return ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (c, i) {
                                final r = list[i];
                                final sel = r.id == current;
                                final isLoading = playState.status == PlaybackStatus.loading && playState.id == r.id;
                                final isPlaying = playState.status == PlaybackStatus.playing && playState.id == r.id;
                                final isError = playState.status == PlaybackStatus.error && playState.id == r.id;
                                return Card(
                                  color: sel ? Colors.deepPurple.shade50 : null,
                                  child: ListTile(
                                    leading: Icon(
                                      r.icon,
                                      color: (isPlaying || sel)
                                          ? Colors.deepPurple
                                          : (isError
                                              ? Colors.red
                                              : Colors.grey),
                                    ),
                                    title: Text(
                                      r.name,
                                      style: TextStyle(
                                        fontWeight: sel
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: r.isCustom
                                        ? const Text('Пользовательская')
                                        : (isError
                                            ? const Text(
                                                'Ошибка воспроизведения',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              )
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
                                                  key: ValueKey<String>(
                                                      isPlaying
                                                          ? 'stop'
                                                          : (isError
                                                              ? 'error'
                                                              : 'play')),
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
                                                      await _audio.stopPlayback();
                                                    } else {
                                                      await _audio.playRingtone(r.id);
                                                      current = r.id;
                                                    }
                                                    if (mounted) setM(() {});
                                                  },
                                                ),
                                        ),
                                        if (r.isCustom)
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              await _audio.deleteCustomRingtone(r.id);
                                              if (current == r.id) current = 'default';
                                              if (mounted) setM(() {});
                                            },
                                          ),
                                        if (sel)
                                          const Icon(Icons.check,
                                              color: Colors.deepPurple),
                                      ],
                                    ),
                                    onTap: () => setM(() => current = r.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _audio.stopPlayback();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Отмена'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              _audio.stopPlayback();
                              Navigator.pop(ctx, current);
                            },
                            child: const Text('Выбрать'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final added =
                              await _audio.addCustomRingtone(context);
                          if (added != null) setM(() {});
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить свою мелодию'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    if (result != null) {
      setState(() {
        _ringtoneId = result;
        _ringtoneInfo = _audio.getRingtoneById(result);
      });
    }
  }

  void _save() {
    if (_dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы одну дату')),
      );
      return;
    }
    final alarmId = _alarmId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    if (_alarmId != null) {
      final updated = AlarmModel(
        id: _alarmId!,
        time: _time.format(context),
        label: _label.text.isEmpty ? null : _label.text,
        dates: _dates,
        ringtone: _ringtoneId,
        enabled: widget.alarm?.enabled ?? true,
      );
      context.read<AlarmBloc>().add(UpdateAlarmEvent(updated));
    } else {
      context.read<AlarmBloc>().add(AddAlarmEvent(
            time: _time.format(context),
            label: _label.text.isEmpty ? null : _label.text,
            dates: _dates,
            ringtone: _ringtoneId,
          ));
    }

    // Планирование уведомлений
    for (final d in _dates) {
      var dt = DateTime(d.year, d.month, d.day, _time.hour, _time.minute);
      NotificationService.instance.scheduleAlarmNotification(
        dt,
        '${alarmId}_${d.millisecondsSinceEpoch}',
        title: _label.text.isEmpty ? 'Будильник' : _label.text,
        body: 'Запланировано на ${_time.format(context)}',
        ringtoneId: _ringtoneId,
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _label.dispose();
    _audio.stopPlayback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: Text(_alarmId == null ? 'Новый будильник' : 'Редактирование'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Сохранить',
                style: TextStyle(
                    color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _time.format(context),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Нажмите для выбора времени',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Название',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _label,
              decoration: const InputDecoration(
                hintText: 'Например: Работа',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Выбор дат',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDates,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dates.isEmpty
                              ? 'Нажмите для выбора дат'
                              : 'Выбрано: ${_dates.length}',
                          style: TextStyle(
                            color:
                                _dates.isEmpty ? Colors.grey : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                    if (_dates.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _dates
                            .map((d) => Chip(
                                  label: Text(_fmt(d)),
                                  backgroundColor:
                                      const Color(0xFF8B5CF6).withValues(alpha: .1),
                                  labelStyle: const TextStyle(
                                      color: Color(0xFF8B5CF6)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Мелодия',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickRingtone,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_ringtoneInfo?.name ?? 'Стандартная мелодия'),
                    const Icon(Icons.music_note, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Сохранить будильник',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                NotificationService.instance.scheduleTestInSeconds(15, ringtoneId: _ringtoneId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Тест будильника через 15 сек')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Тест через 15 сек'),
            ),
          ],
        ),
      ),
    );
  }
}
