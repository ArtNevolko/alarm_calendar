import 'package:flutter/material.dart';

/// Простая альтернатива для file_picker, которая открывает простой диалог выбора файлов
/// и возвращает имя выбранного файла. Использует только стандартные API Flutter.
class CustomFilePicker {
  /// Открывает диалог для выбора аудио файла
  static Future<String?> pickAudio(BuildContext context) async {
    return await _showPickerDialog(context, 'Выберите аудио файл');
  }

  /// Имитирует выбор файла с помощью простого диалога
  static Future<String?> _showPickerDialog(
      BuildContext context, String title) async {
    // Имитируем список доступных файлов
    final List<String> mockFiles = [
      'Alarm_Classic.mp3',
      'Morning_Birds.mp3',
      'Soft_Bells.mp3',
      'Wake_Up.mp3',
      'Digital_Alarm.mp3',
    ];

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: ListView.builder(
            itemCount: mockFiles.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.audio_file),
                title: Text(mockFiles[index]),
                onTap: () {
                  Navigator.of(context).pop(mockFiles[index]);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }
}
