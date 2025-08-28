import 'package:flutter_bloc/flutter_bloc.dart';

// События для работы с будильниками
abstract class AlarmEvent {}

class LoadAlarmsEvent extends AlarmEvent {}

class AddAlarmEvent extends AlarmEvent {
  final String time;
  final String? label;
  final List<DateTime> dates;
  final String ringtone;

  AddAlarmEvent({
    required this.time,
    this.label,
    required this.dates,
    required this.ringtone,
  });
}

class UpdateAlarmEvent extends AlarmEvent {
  final AlarmModel alarm;

  UpdateAlarmEvent(this.alarm);
}

class DeleteAlarmEvent extends AlarmEvent {
  final String alarmId;
  DeleteAlarmEvent(this.alarmId);
}

class ToggleAlarmEvent extends AlarmEvent {
  final String alarmId;
  ToggleAlarmEvent(this.alarmId);
}

// Модель данных будильника
class AlarmModel {
  final String id;
  final String time;
  final String? label;
  final List<DateTime> dates;
  final String ringtone;
  final bool enabled;

  AlarmModel({
    required this.id,
    required this.time,
    this.label,
    required this.dates,
    required this.ringtone,
    this.enabled = true,
  });

  // Копирование с возможностью изменения отдельных полей
  AlarmModel copyWith({
    String? time,
    String? label,
    List<DateTime>? dates,
    String? ringtone,
    bool? enabled,
  }) {
    return AlarmModel(
      id: id,
      time: time ?? this.time,
      label: label ?? this.label,
      dates: dates ?? this.dates,
      ringtone: ringtone ?? this.ringtone,
      enabled: enabled ?? this.enabled,
    );
  }
}

// Состояние для BLoC
class AlarmState {
  final List<AlarmModel> alarms;
  final String? error;

  const AlarmState({
    this.alarms = const [],
    this.error,
  });

  AlarmState copyWith({
    List<AlarmModel>? alarms,
    String? error,
  }) {
    return AlarmState(
      alarms: alarms ?? this.alarms,
      error: error,
    );
  }
}

// BLoC для управления будильниками
class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  // Список будильников хранится в памяти для примера
  final List<AlarmModel> _alarms = [];

  AlarmBloc() : super(const AlarmState()) {
    on<LoadAlarmsEvent>(_onLoadAlarms);
    on<AddAlarmEvent>(_onAddAlarm);
    on<UpdateAlarmEvent>(_onUpdateAlarm);
    on<DeleteAlarmEvent>(_onDeleteAlarm);
    on<ToggleAlarmEvent>(_onToggleAlarm);
  }

  void _onLoadAlarms(
    LoadAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) {
    emit(state.copyWith(alarms: _alarms));
  }

  void _onAddAlarm(
    AddAlarmEvent event,
    Emitter<AlarmState> emit,
  ) {
    final newAlarm = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: event.time,
      label: event.label,
      dates: event.dates,
      ringtone: event.ringtone,
      enabled: true,
    );

    _alarms.add(newAlarm);
    emit(state.copyWith(alarms: List.from(_alarms)));
  }

  void _onUpdateAlarm(
    UpdateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) {
    final index = _alarms.indexWhere((alarm) => alarm.id == event.alarm.id);
    if (index != -1) {
      _alarms[index] = event.alarm;
      emit(state.copyWith(alarms: List.from(_alarms)));
    }
  }

  void _onDeleteAlarm(
    DeleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) {
    _alarms.removeWhere((alarm) => alarm.id == event.alarmId);
    emit(state.copyWith(alarms: List.from(_alarms)));
  }

  void _onToggleAlarm(
    ToggleAlarmEvent event,
    Emitter<AlarmState> emit,
  ) {
    final index = _alarms.indexWhere((alarm) => alarm.id == event.alarmId);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(enabled: !_alarms[index].enabled);
      emit(state.copyWith(alarms: List.from(_alarms)));
    }
  }
}
