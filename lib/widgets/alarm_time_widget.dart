import 'package:flutter/material.dart';

class AlarmTimeWidget extends StatelessWidget {
  final TimeOfDay time;
  final bool isActive;

  const AlarmTimeWidget(
      {super.key, required this.time, required this.isActive});

  @override
  Widget build(BuildContext context) {
    String formatted =
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}'; // фиксированный формат H:mm
    return Row(
      children: [
        Icon(isActive ? Icons.alarm_on : Icons.alarm_off),
        const SizedBox(width: 8),
        Text(
          formatted,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
