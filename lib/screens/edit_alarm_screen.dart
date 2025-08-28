import 'package:flutter/material.dart';
import 'package:alarm_calendar/presentation/widgets/sound_selector_widget.dart';
import 'package:alarm_calendar/services/notification_service.dart' show NotificationService;

class EditAlarmScreen extends StatefulWidget {
  const EditAlarmScreen({super.key});
  @override
  EditAlarmScreenState createState() => EditAlarmScreenState();
}

class EditAlarmScreenState extends State<EditAlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<int> _selectedDays = [];
  bool _isActive = true;
  String _sound = 'default';

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить/Редактировать будильник')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Время:'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            const Text('Дни недели:'),
            Wrap(
              spacing: 8,
              children: List.generate(
                  7,
                  (i) => ChoiceChip(
                        label:
                            Text(['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'][i]),
                        selected: _selectedDays.contains(i),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(i);
                            } else {
                              _selectedDays.remove(i);
                            }
                          });
                        },
                      )),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Активен'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Звук'),
              subtitle: Text(_sound),
              trailing: const Icon(Icons.music_note),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => SoundSelectorWidget(
                    selectedSound: _sound,
                    onChanged: (soundId) {
                      setState(() => _sound = soundId);
                    },
                  ),
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final result = {
                  'time': _selectedTime.format(context),
                  'days': List<int>.from(_selectedDays),
                  'active': _isActive,
                  'sound': _sound,
                };
                final now = DateTime.now();
                for (final w in _selectedDays) {
                  DateTime candidate = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );
                  // weekday: Mon=1 ... Sun=7 ; у нас список возможно 0..6 (Вс=0)
                  int targetWeekday = (w == 0) ? DateTime.sunday : w;
                  while (candidate.weekday != targetWeekday) {
                    candidate = candidate.add(const Duration(days: 1));
                  }
                  if (candidate.isBefore(now)) {
                    candidate = candidate.add(const Duration(days: 7));
                  }
                  NotificationService.instance.scheduleAlarmNotification(
                    candidate,
                    'edit_${candidate.millisecondsSinceEpoch}',
                    title: 'Будильник',
                    body: _selectedTime.format(context),
                    ringtoneId: _sound,
                  );
                }
                Navigator.pop(context, result);
              },
              child: const Center(child: Text('Сохранить')),
            ),
          ],
        ),
      ),
    );
  }
}
