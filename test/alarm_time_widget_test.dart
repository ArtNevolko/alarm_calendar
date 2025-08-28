import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_calendar/widgets/alarm_time_widget.dart';

void main() {
  testWidgets('AlarmTimeWidget отображает время', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AlarmTimeWidget(
              time: TimeOfDay(hour: 9, minute: 15), isActive: true),
        ),
      ),
    );
    expect(find.text('9:15'), findsOneWidget);
    expect(find.byIcon(Icons.alarm_on), findsOneWidget);
  });
}
