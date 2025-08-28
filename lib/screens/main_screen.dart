import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../utils/alarm_utils.dart';
import 'edit_alarm_screen.dart';
import 'settings_screen.dart';
import '../presentation/screens/timer_screen.dart';
import '../widgets/alarm_time_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final AlarmService _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    if (_alarmService.getAlarms().isEmpty) {
      _alarmService.addAlarm(Alarm(
        time: TimeOfDay.now(),
        repeatDays: [1, 3, 5],
        isActive: true,
        sound: 'default',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final alarms = _alarmService.getAlarms();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Будильники'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            tooltip: 'Таймер',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return ListTile(
            leading: /* Можно заменить на Image.asset('assets/images/alarm_icon.png', width: 32, height: 32) */
                const Icon(Icons.alarm_on),
            title: AlarmTimeWidget(time: alarm.time, isActive: alarm.isActive),
            subtitle: Text('Повтор: ${daysToString(alarm.repeatDays)}'),
            trailing: Switch(
              value: alarm.isActive,
              onChanged: (val) {
                setState(() {
                  _alarmService.toggleAlarm(alarm);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditAlarmScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
