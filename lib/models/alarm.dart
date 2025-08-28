import 'package:flutter/material.dart';

class Alarm {
  final TimeOfDay time;
  final List<int> repeatDays;
  final bool isActive;
  final String sound;

  Alarm({
    required this.time,
    required this.repeatDays,
    required this.isActive,
    required this.sound,
  });

  Alarm copyWith({
    TimeOfDay? time,
    List<int>? repeatDays,
    bool? isActive,
    String? sound,
  }) {
    return Alarm(
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      isActive: isActive ?? this.isActive,
      sound: sound ?? this.sound,
    );
  }
}
