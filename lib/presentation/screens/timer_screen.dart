import 'package:flutter/material.dart';
import '../../services/timer_sound_service.dart';
import '../../services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isPlayingSound = false;
  String _soundName(String file) {
    switch (file) {
      case 'alarm_default.mp3':
        return 'Стандартный';
      case 'rain.mp3':
        return 'Дождь';
      case 'sea.mp3':
        return 'Море';
      default:
        return file;
    }
  }
  String _selectedSound = 'alarm_default.mp3';
  final List<String> _availableSounds = [
    'alarm_default.mp3',
    'rain.mp3',
    'sea.mp3',
  ];
  Duration _duration = const Duration();
  Duration _remaining = const Duration();
  bool _isRunning = false;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;
  
  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController();
    _minutesController = TextEditingController();
    _secondsController = TextEditingController();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _startTimer() {
    // Скрыть клавиатуру
    FocusScope.of(context).unfocus();
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    setState(() {
      _duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
      _remaining = _duration;
      _isRunning = true;
    });
    // Запланировать уведомление на окончание таймера
    if (_duration.inSeconds > 0) {
      final scheduled = tz.TZDateTime.now(tz.local).add(_duration);
      NotificationService.instance.scheduleTimerNotification(scheduled);
    }
    _tick();
  }

  void _tick() async {
    while (_isRunning && _remaining.inSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRunning) break;
      setState(() {
        _remaining -= const Duration(seconds: 1);
      });
    }
    if (_remaining.inSeconds == 0 && _isRunning) {
      setState(() {
        _isRunning = false;
      });
      // Проиграть звук по окончании таймера
      _playSound();
      // Показать уведомление
      NotificationService.instance.showTimerNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Время таймера вышло!')),
        );
      }
    }
  }

  Future<void> _playSound() async {
    setState(() => _isPlayingSound = true);
    await TimerSoundService().playAsset(_selectedSound);
    setState(() => _isPlayingSound = false);
  }

  Future<void> _stopSound() async {
    await TimerSoundService().stop();
    setState(() => _isPlayingSound = false);
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    NotificationService.instance.cancelTimerNotification();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remaining = _duration;
    });
    NotificationService.instance.cancelTimerNotification();
  }

  @override
  Widget build(BuildContext context) {
    final percent = _duration.inSeconds > 0
        ? (_remaining.inSeconds / _duration.inSeconds).clamp(0.0, 1.0)
        : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Таймер')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeField(_hoursController, 'чч'),
                const Text(' : '),
                _timeField(_minutesController, 'мм'),
                const Text(' : '),
                _timeField(_secondsController, 'cc'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedSound,
                    items: _availableSounds.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(_soundName(s)),
                    )).toList(),
                    onChanged: _isRunning ? null : (val) {
                      if (val != null) setState(() => _selectedSound = val);
                    },
                    isExpanded: true,
                  ),
                ),
                if (_isPlayingSound)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.volume_up, color: Colors.green),
                  ),
              ],
            ),
            if (_isPlayingSound)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: _stopSound,
                  icon: const Icon(Icons.stop),
                  label: const Text('Стоп звук'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                Text(
                  _formatDuration(_remaining),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isRunning ? Colors.grey[400] : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: _isRunning ? null : _startTimer,
                    child: const Text('Старт'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : null,
                  child: const Text('Пауза'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Сброс'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeField(TextEditingController controller, String hint) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: hint),
        textAlign: TextAlign.center,
        enabled: !_isRunning,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
