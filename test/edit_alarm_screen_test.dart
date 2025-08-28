import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_calendar/screens/edit_alarm_screen.dart';

void main() {
  testWidgets('EditAlarmScreen отображает форму', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditAlarmScreen(),
      ),
    );
    expect(find.text('Добавить/Редактировать будильник'), findsOneWidget);
    expect(find.text('Время:'), findsOneWidget);
    expect(find.text('Дни недели:'), findsOneWidget);
    expect(find.text('Активен'), findsOneWidget);
    expect(find.text('Звук'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
  });
}
