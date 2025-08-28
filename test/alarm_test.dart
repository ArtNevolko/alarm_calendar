import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:alarm_calendar/models/alarm.dart';

void main() {
  test('Создание Alarm', () {
    final alarm = Alarm(
      time: const TimeOfDay(hour: 7, minute: 30),
      repeatDays: [1, 3, 5],
      isActive: true,
      sound: 'default',
    );
    expect(alarm.time.hour, 7);
    expect(alarm.time.minute, 30);
    expect(alarm.repeatDays, [1, 3, 5]);
    expect(alarm.isActive, true);
    expect(alarm.sound, 'default');
  });
}
