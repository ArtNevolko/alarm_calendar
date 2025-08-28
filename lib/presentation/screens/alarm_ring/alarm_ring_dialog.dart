import 'package:flutter/material.dart';
import '../../../core/audio/audio_player_service.dart';
import '../../../services/notification_service.dart';

class AlarmRingDialog extends StatefulWidget {
  final String alarmId;
  final String? ringtoneId;
  const AlarmRingDialog({super.key, required this.alarmId, this.ringtoneId});

  @override
  State<AlarmRingDialog> createState() => _AlarmRingDialogState();
}

class _AlarmRingDialogState extends State<AlarmRingDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.ringtoneId != null) {
      AudioPlayerService.instance.playRingtoneLoop(widget.ringtoneId!);
    }
  }

  Future<void> _dismiss() async {
    await AudioPlayerService.instance.stopPlayback();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    // Отложить на 5 минут
    final dt = DateTime.now().add(const Duration(minutes: 5));
    await NotificationService.instance.scheduleAlarmNotification(
      dt,
      '${widget.alarmId}_snooze',
      title: 'Отложенный будильник',
      body: 'Сработает через 5 минут',
    );
    await _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.alarm, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 12),
                Text(
                  'Будильник',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  now.format(context),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _snooze,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Отложить'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Выключить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ),
      ),
    );
  }
}
