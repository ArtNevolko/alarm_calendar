import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_calendar/utils/alarm_utils.dart';

void main() {
  test('daysToString корректно форматирует дни недели', () {
    expect(daysToString([1, 3, 5]), 'Пн, Ср, Пт');
    expect(daysToString([]), 'Без повторов');
    expect(daysToString([0, 6]), 'Вс, Сб');
  });
}
