import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:alarm_calendar/presentation/screens/timer_screen.dart';

void main() {
  testWidgets('TimerScreen UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TimerScreen()));
    expect(find.text('Таймер'), findsOneWidget);
    expect(find.text('Старт'), findsOneWidget);
    expect(find.text('Пауза'), findsOneWidget);
    expect(find.text('Сброс'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
  });
}
