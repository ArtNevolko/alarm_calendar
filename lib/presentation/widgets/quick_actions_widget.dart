import 'package:flutter/material.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                context,
                Icons.add_alarm,
                'Новый будильник',
                backgroundColor: Theme.of(context)
                    .primaryColor
                    .withAlpha(26), // 0.1 opacity = ~26 alpha
                onTap: () => Navigator.pushNamed(context, '/create-alarm'),
              ),
              _buildQuickAction(
                context,
                Icons.night_shelter,
                'Режим сна',
                backgroundColor:
                    Colors.indigo.withAlpha(26), // 0.1 opacity = ~26 alpha
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Режим сна будет доступен в следующем обновлении'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildQuickAction(
                context,
                Icons.timer,
                'Таймер',
                backgroundColor:
                    Colors.orange.withAlpha(26), // 0.1 opacity = ~26 alpha
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Таймер будет доступен в следующем обновлении'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label, {
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: backgroundColor
                  .withAlpha(204), // 0.8 opacity = 204 alpha (255 * 0.8)
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
