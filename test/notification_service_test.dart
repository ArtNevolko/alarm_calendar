import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_calendar/services/notification_service.dart';

void main() {
  test('Вызовы методов NotificationService не вызывают ошибок', () async {
    final service = NotificationService();
    await service.scheduleAlarmNotification(DateTime.now(), 'test_alarm');
    await service.cancelAlarmNotification('test_alarm');
    expect(true, true); // если дошли до сюда — ошибок не было
  });
}
