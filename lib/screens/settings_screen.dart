import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _vibration = true;
  String _theme = 'light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Вибрация'),
              value: _vibration,
              onChanged: (val) => setState(() => _vibration = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _theme,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Светлая тема')),
                DropdownMenuItem(value: 'dark', child: Text('Тёмная тема')),
              ],
              onChanged: (val) => setState(() => _theme = val ?? 'light'),
              decoration: const InputDecoration(labelText: 'Тема'),
            ),
          ],
        ),
      ),
    );
  }
}
