package com.example.alarm_calendar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarmId") ?: ""
        val ringtoneId = intent.getStringExtra("ringtoneId")
        Log.d("AlarmReceiver", "[AlarmReceiver] Alarm triggered: alarmId=$alarmId, ringtoneId=$ringtoneId, intent=$intent")
        try {
            val nativeIntent = Intent(context, AlarmNativeActivity::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("ringtoneId", ringtoneId)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            Log.d("AlarmReceiver", "[AlarmReceiver] Starting AlarmNativeActivity with intent: $nativeIntent")
            context.startActivity(nativeIntent)
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "[AlarmReceiver] Failed to start AlarmNativeActivity", e)
        }
    }
}
