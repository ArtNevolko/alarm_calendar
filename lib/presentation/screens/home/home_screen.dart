import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../bloc/alarm/alarm_bloc.dart';
import '../../../bloc/premium/premium_bloc.dart';
import '../../../core/localization/app_localizations.dart';
import '../premium/premium_screen.dart';
import '../timer_screen.dart';
import '../../../screens/settings_screen.dart';
import 'package:alarm_calendar/presentation/screens/create_alarm/create_alarm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Показываем уведомление о том, что язык определен автоматически
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context);
      Future.delayed(const Duration(seconds: 1), () {
        _showSnackBar(l.languageDetected);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getTimeString() {
    return '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
  }

  String _getDateString() {
    final l = AppLocalizations.of(context);
    return '${l.weekdays[_currentTime.weekday - 1]}, ${_currentTime.day} ${l.months[_currentTime.month - 1]}';
  }

  String _getGreeting() {
    final l = AppLocalizations.of(context);
    final hour = _currentTime.hour;
    if (hour < 12) return l.goodMorning;
    if (hour < 17) return l.goodDay;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: BlocBuilder<AlarmBloc, AlarmState>(
                builder: (context, alarmState) {
                  return Text(
                    '${alarmState.alarms.length}/∞ alarms',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<PremiumBloc, PremiumState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  Icons.workspace_premium,
                  color: state.isPremium ? Colors.amber : Colors.grey,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PremiumScreen()),
                ),
              );
            },
          ),
          // Переключение языка перенесено в настройки
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AlarmBloc, AlarmState>(
        builder: (context, state) {
          return Column(
            children: [
              // Time Display
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _getTimeString(),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_getGreeting()}, ${_getDateString()}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAlarmScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          l.newAlarm,
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TimerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.timer),
                        label: Text(l.timer),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Alarms List
              Expanded(
                child: state.alarms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.alarm_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.alarmListEmpty,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.addFirstAlarm,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: state.alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = state.alarms[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                Icons.alarm,
                                color: alarm.enabled
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                              ),
                              title: Text(
                                alarm.time,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: alarm.label != null
                                  ? Text(alarm.label!)
                                  : Text(l.datesSelected(alarm.dates.length)),
                              trailing: Switch(
                                value: alarm.enabled,
                                onChanged: (value) {
                                  context
                                      .read<AlarmBloc>()
                                      .add(ToggleAlarmEvent(alarm.id));
                                },
                                activeColor: const Color(0xFF10B981),
                              ),
                              onTap: () {
                                // Открываем экран редактирования будильника
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateAlarmScreen(alarm: alarm),
                                  ),
                                );
                              },
                              onLongPress: () => _showDeleteDialog(alarm.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }


  void _showDeleteDialog(String alarmId) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.confirmDeleteTitle),
        content: Text(l.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<AlarmBloc>().add(DeleteAlarmEvent(alarmId));
              Navigator.pop(context);
              _showSnackBar(l.alarmDeleted);
            },
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}
