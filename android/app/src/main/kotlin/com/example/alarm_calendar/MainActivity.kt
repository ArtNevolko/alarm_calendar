package com.example.alarm_calendar

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.app.AlertDialog
import android.content.SharedPreferences
import android.provider.Settings
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
	}

	// Уведомление о SYSTEM_ALERT_WINDOW временно отключено для разработки

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "alarm_calendar/alarm_manager").setMethodCallHandler { call, result ->
			when (call.method) {
				"scheduleAlarm" -> {
					val id = call.argument<Int>("id") ?: 0
					val time = call.argument<Long>("time") ?: 0L
					val alarmId = call.argument<String>("alarmId") ?: ""
					val ringtoneId = call.argument<String>("ringtoneId")
					val context = applicationContext
					val intent = Intent(context, AlarmReceiver::class.java).apply {
						putExtra("alarmId", alarmId)
						putExtra("ringtoneId", ringtoneId)
					}
					val pendingIntent = PendingIntent.getBroadcast(
						context,
						id,
						intent,
						PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0
					)
					val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
						alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pendingIntent)
					} else {
						alarmManager.setExact(AlarmManager.RTC_WAKEUP, time, pendingIntent)
					}
					result.success(null)
				}
				"cancelAlarm" -> {
					val id = call.argument<Int>("id") ?: 0
					val context = applicationContext
					val intent = Intent(context, AlarmReceiver::class.java)
					val pendingIntent = PendingIntent.getBroadcast(
						context,
						id,
						intent,
						PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0
					)
					val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
					alarmManager.cancel(pendingIntent)
					result.success(null)
				}
				else -> result.notImplemented()
			}
		}
	}
}
