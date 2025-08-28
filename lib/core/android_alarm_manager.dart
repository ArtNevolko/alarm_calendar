import 'dart:io';
import 'package:flutter/services.dart';

class AndroidAlarmManager {
  static const MethodChannel _channel = MethodChannel('alarm_calendar/alarm_manager');

  static Future<void> scheduleAlarm({
    required int id,
    required DateTime dateTime,
    required String alarmId,
    String? ringtoneId,
  }) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('scheduleAlarm', {
      'id': id,
      'time': dateTime.millisecondsSinceEpoch,
      'alarmId': alarmId,
      'ringtoneId': ringtoneId,
    });
  }

  static Future<void> cancelAlarm(int id) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('cancelAlarm', {'id': id});
  }
}
