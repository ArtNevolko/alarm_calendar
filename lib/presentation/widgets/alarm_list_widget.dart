import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alarm/alarm_bloc.dart';

class AlarmListWidget extends StatelessWidget {
  const AlarmListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withAlpha(26), // 0.1 opacity = ~26 alpha (255 * 0.1)
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Alarms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (state.alarms.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No alarms yet.\nTap + to create your first alarm.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.alarms.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final alarm = state.alarms[index];
                    return ListTile(
                      leading: Icon(
                        Icons.alarm,
                        color: alarm.enabled
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      title: Text(
                        alarm.time,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: alarm.enabled ? null : Colors.grey,
                        ),
                      ),
                      subtitle: Text(alarm.label ?? ''),
                      trailing: Switch(
                        value: alarm.enabled,
                        onChanged: (value) {
                          // Toggle alarm - заглушка
                        },
                      ),
                      onTap: () {
                        // Navigate to edit alarm
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
