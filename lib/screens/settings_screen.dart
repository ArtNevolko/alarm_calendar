import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language/language_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _vibration = true;
  String _theme = 'system';
  String _language = 'ru';

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
                DropdownMenuItem(value: 'system', child: Text('Системная тема')),
                DropdownMenuItem(value: 'light', child: Text('Светлая тема')),
                DropdownMenuItem(value: 'dark', child: Text('Тёмная тема')),
              ],
              onChanged: (val) => setState(() => _theme = val ?? 'system'),
              decoration: const InputDecoration(labelText: 'Тема'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'uk', child: Text('Українська')),
              ],
              onChanged: (val) {
                setState(() => _language = val ?? 'ru');
                // Смена языка через Bloc
                final locale = _language == 'ru'
                    ? const Locale('ru')
                    : _language == 'en'
                        ? const Locale('en')
                        : const Locale('uk');
                // ignore: use_build_context_synchronously
                context.read<LanguageBloc>().add(ChangeLanguageEvent(locale));
              },
              decoration: const InputDecoration(labelText: 'Язык'),
            ),
          ],
        ),
      ),
    );
  }
}
