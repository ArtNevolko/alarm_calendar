import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_calendar/screens/main_screen.dart';

void main() {
  testWidgets('MainScreen отображает список будильников',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );
    expect(find.text('Будильники'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}
