import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/audio/audio_player_service.dart';
import '../presentation/screens/alarm_ring/alarm_ring_dialog.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;

  final navigatorKey = GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    final initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        debugPrint('[NotificationService] Click payload: $payload');
        if (payload != null) _handleAlarmPayload(payload);
      },
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    await ensurePermissions();

    const androidChannel = AndroidNotificationChannel(
      'alarm_channel',
      'Будильники',
      description: 'Уведомления будильников',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_classic'),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
    debugPrint('[NotificationService] Initialized');
  }

  Future<void> ensurePermissions() async {
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      // POST_NOTIFICATIONS runtime (API 33+)
      if (await Permission.notification.isDenied ||
          await Permission.notification.isPermanentlyDenied) {
        final res = await Permission.notification.request();
        debugPrint('[NotificationService] Notification perm result: $res');
      }
      await _requestExactAlarmPermission();
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    const methodChannel = MethodChannel('alarm_calendar/exact_alarm');
    try {
      await methodChannel.invokeMethod('requestExactAlarm');
    } catch (_) {
      // ignore
    }
  }

  int _stableId(String key) {
    // Небольшой стабильный хэш (избегаем нестабильности String.hashCode).
    int h = 0;
    for (final c in key.codeUnits) {
      h = 0x1fffffff & (h + c);
      h = 0x1fffffff & (h + ((h << 10)));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((h << 3)));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((h << 15)));
    return h & 0x7fffffff;
  }

  // Фон (должен быть top-level / static)
  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse resp) {
    final payload = resp.payload;
    if (payload != null) {
      NotificationService.instance._handleAlarmPayload(payload);
    }
  }

  void _handleAlarmPayload(String payload) {
    final parts = payload.split('|');
    final alarmId = parts.isNotEmpty ? parts[0] : payload;
    final ringtoneId = parts.length > 1 ? parts[1] : null;
    // Запуск FullscreenActivity на Android
    if (Platform.isAndroid) {
      const platform = MethodChannel('alarm_calendar/fullscreen');
      platform.invokeMethod('showAlarm', {
        'label': alarmId, // или передавайте label, если есть
      });
    } else {
      showAlarmPopup(alarmId: alarmId, ringtoneId: ringtoneId);
    }
  }

  Future<void> showAlarmPopup({
    required String alarmId,
    String? ringtoneId,
  }) async {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;
    if (ringtoneId != null) {
      AudioPlayerService.instance.playRingtoneLoop(ringtoneId);
    }
    showGeneralDialog(
      context: ctx,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) =>
          AlarmRingDialog(alarmId: alarmId, ringtoneId: ringtoneId),
      transitionBuilder: (_, anim, __, child) =>
          ScaleTransition(scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack), child: child),
    );
  }

  DateTime _adjustToFuture(DateTime dt) {
    final now = DateTime.now();
    if (dt.isBefore(now)) {
      debugPrint('[NotificationService] Adjust past -> +1 day: $dt');
      return dt.add(const Duration(days: 1));
    }
    return dt;
  }

  Future<void> scheduleAlarmNotification(
    DateTime dateTime,
    String alarmId, {
    String title = 'Будильник',
    String? body,
    String? ringtoneId,
  }) async {
    await init();
    final adjusted = _adjustToFuture(dateTime);
    final target = tz.TZDateTime.from(adjusted, tz.local);

    final id = _stableId(alarmId);
    debugPrint('[NotificationService] Schedule: alarmId=$alarmId notifId=$id target=$target now=${DateTime.now()}');

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Будильники',
      channelDescription: 'Уведомления будильников',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm_classic'),
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      enableVibration: true,
      fullScreenIntent: true,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: true);

    await _plugin.zonedSchedule(
      id,
      title,
      body ?? 'Срабатывание будильника',
      target,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: ringtoneId != null ? '$alarmId|$ringtoneId' : alarmId,
    );
  }

  Future<void> scheduleTestInSeconds(int seconds, {String ringtoneId = 'default'}) async {
    final when = DateTime.now().add(Duration(seconds: seconds));
    await scheduleAlarmNotification(
      when,
      'test_${when.millisecondsSinceEpoch}',
      title: 'Тест будильника',
      body: 'Тест через $seconds сек',
      ringtoneId: ringtoneId,
    );
    debugPrint('[NotificationService] Test alarm scheduled in $seconds seconds');
  }

  Future<void> cancelAlarmNotification(String alarmId) async {
    await init();
    final id = _stableId(alarmId);
    debugPrint('[NotificationService] Cancel alarmId=$alarmId notifId=$id');
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await init();
    debugPrint('[NotificationService] Cancel ALL');
    await _plugin.cancelAll();
  }
}