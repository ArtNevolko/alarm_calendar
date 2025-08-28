import '../models/alarm.dart';
import '../services/notification_service.dart';

class AlarmService {
  final List<Alarm> _alarms = [];
  final NotificationService _notificationService = NotificationService();

  List<Alarm> getAlarms() => List.unmodifiable(_alarms);

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    _notificationService.scheduleAlarmNotification(
      DateTime.now().add(const Duration(minutes: 1)),
      alarm.hashCode.toString(),
    );
  }

  void removeAlarm(Alarm alarm) {
    _alarms.remove(alarm);
    _notificationService.cancelAlarmNotification(alarm.hashCode.toString());
  }

  void toggleAlarm(Alarm alarm) {
    int index = _alarms.indexOf(alarm);
    if (index != -1) {
      _alarms[index] = Alarm(
        time: alarm.time,
        repeatDays: alarm.repeatDays,
        isActive: !alarm.isActive,
        sound: alarm.sound,
      );
    }
  }
}
