import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_calendar/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen отображает элементы управления',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Вибрация'), findsOneWidget);
    expect(find.text('Тема'), findsOneWidget);
  });
}
