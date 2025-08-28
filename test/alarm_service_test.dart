import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:alarm_calendar/models/alarm.dart';
import 'package:alarm_calendar/services/alarm_service.dart';

void main() {
  test('Добавление и удаление будильника', () {
    final service = AlarmService();
    final alarm = Alarm(
      time: const TimeOfDay(hour: 8, minute: 0),
      repeatDays: [2, 4],
      isActive: true,
      sound: 'beep',
    );
    service.addAlarm(alarm);
    expect(service.getAlarms().contains(alarm), true);
    service.removeAlarm(alarm);
    expect(service.getAlarms().contains(alarm), false);
  });
}
