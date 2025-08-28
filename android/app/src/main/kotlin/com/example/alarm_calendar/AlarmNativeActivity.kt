package com.example.alarm_calendar

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Vibrator
import android.os.VibrationEffect
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
// import com.example.alarm_calendar.R

class AlarmNativeActivity : Activity() {
    private var fallbackHandler: android.os.Handler? = null
    private var fallbackRunnable: Runnable? = null
    private var fallbackAnim = 0f
    private var released = false
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private lateinit var icon: android.widget.ImageView
    private lateinit var gradientDrawable: android.graphics.drawable.ColorDrawable
    private lateinit var time: TextView
    private lateinit var title: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val alarmId = intent.getStringExtra("alarmId")
        val ringtoneId = intent.getStringExtra("ringtoneId")
        android.util.Log.d("AlarmNativeActivity", "[AlarmNativeActivity] onCreate: alarmId=$alarmId, ringtoneId=$ringtoneId, intent=$intent")
        // Экран и блокировка
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }

        // Цвета и тема
        val isDark = (resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES
        val bgColor = if (isDark) 0xFF23232A.toInt() else 0xFFF7F6FF.toInt()
        val textColor = if (isDark) 0xFFFFFFFF.toInt() else 0xFF23232A.toInt()
        val accentColor = 0xFF7C3AED.toInt()
        val root = android.widget.FrameLayout(this)
        root.setBackgroundColor(bgColor)
        gradientDrawable = android.graphics.drawable.ColorDrawable(0xFFF7F6FF.toInt())

        // Fallback-анимация
        fallbackHandler = android.os.Handler(mainLooper)
        fallbackRunnable = object : Runnable {
            override fun run() {
                fallbackAnim += 0.03f
                if (fallbackAnim > 1f) fallbackAnim = 0f
                val scale = 1f + 0.05f * kotlin.math.sin(fallbackAnim * 2 * Math.PI).toFloat()
                if (::icon.isInitialized) {
                    icon.scaleX = scale
                    icon.scaleY = scale
                }
                if (::time.isInitialized) {
                    val glow = 16f + 16f * kotlin.math.abs(kotlin.math.sin(fallbackAnim * Math.PI)).toFloat()
                    time.setShadowLayer(glow, 0f, 0f, 0x66FFFFFF)
                }
                if (::title.isInitialized) {
                    val titleShadow = 2f + 2f * kotlin.math.abs(kotlin.math.cos(fallbackAnim * Math.PI)).toFloat()
                    title.setShadowLayer(titleShadow, 0f, 0f, 0x33000000)
                }
                fallbackHandler?.postDelayed(this, 30)
            }
        }
        fallbackHandler?.postDelayed(fallbackRunnable!!, 30)

        // Blur (Android 12+)
        val blurView = if (Build.VERSION.SDK_INT >= 31) {
            val view = android.view.View(this)
            view.setLayerType(android.view.View.LAYER_TYPE_HARDWARE, null)
            view.background = null
            view.setWillNotDraw(false)
            view.setBackgroundColor(0x00FFFFFF)
            view.setRenderEffect(android.graphics.RenderEffect.createBlurEffect(60f, 60f, android.graphics.Shader.TileMode.CLAMP))
            view
        } else null

        // Карточка
        val card = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setPadding(32, 32, 32, 32)
            background = null
            elevation = 0f
            gravity = android.view.Gravity.CENTER
            alpha = 1f
            scaleX = 1f
            scaleY = 1f
        }

        // Иконка
        icon = android.widget.ImageView(this).apply {
            val resId = resources.getIdentifier("ic_alarm_custom", "drawable", packageName)
            setImageResource(resId)
            val params = android.widget.LinearLayout.LayoutParams(140, 140)
            params.bottomMargin = 16
            layoutParams = params
            setColorFilter(if (isDark) 0xFFFFFFFF.toInt() else accentColor)
        }
        // Анимация пульсации
        val iconPulse = android.animation.ValueAnimator.ofFloat(1f, 1.05f, 1f).apply {
            duration = 1200
            repeatCount = android.animation.ValueAnimator.INFINITE
            addUpdateListener {
                val scale = it.animatedValue as Float
                icon.scaleX = scale
                icon.scaleY = scale
            }
        }
        icon.post { iconPulse.start() }
        card.addView(icon, 0)

        // Заголовок
        title = TextView(this).apply {
            text = "Будильник!"
            textSize = 30f
            setTextColor(textColor)
            setTypeface(null, android.graphics.Typeface.BOLD)
            gravity = android.view.Gravity.CENTER
            setShadowLayer(6f, 0f, 0f, accentColor and 0x33FFFFFF)
            val params = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = 8
            layoutParams = params
        }

        // Время
        time = TextView(this).apply {
            val now = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault()).format(java.util.Date())
            text = now
            textSize = 68f
            setTextColor(textColor)
            setTypeface(null, android.graphics.Typeface.BOLD)
            gravity = android.view.Gravity.CENTER
            setShadowLayer(24f, 0f, 0f, accentColor)
            val params = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = 36
            layoutParams = params
        }

        // Ripple drawable
        fun rippleDrawable(strokeColor: Int, fillColor: Int): android.graphics.drawable.Drawable {
            val content = android.graphics.drawable.GradientDrawable().apply {
                setColor(fillColor)
                setStroke(3, strokeColor)
                cornerRadius = 32f
            }
            return android.graphics.drawable.RippleDrawable(
                android.content.res.ColorStateList.valueOf(0x22000000),
                content, content
            )
        }

        // Snooze
        val btnSnooze = Button(this).apply {
            text = "Отложить на 5 минут"
            textSize = 20f
            setTextColor(0xFF7C3AED.toInt())
            setTypeface(null, android.graphics.Typeface.BOLD)
            background = rippleDrawable(0xFF7C3AED.toInt(), 0xFFFFFFFF.toInt())
            val params = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.bottomMargin = 14
            layoutParams = params
            alpha = 0f
            translationY = 40f
            setOnClickListener {
                safeReleaseMedia()
                vibrator?.cancel()
                finish()
            }
        }
        btnSnooze.post {
            btnSnooze.animate().alpha(1f).translationY(0f).setDuration(500).setStartDelay(350)
                .setInterpolator(android.view.animation.BounceInterpolator()).start()
        }

        // Stop
        val btnStop = Button(this).apply {
            text = "Отключить"
            textSize = 20f
            setTextColor(0xFF888888.toInt())
            setTypeface(null, android.graphics.Typeface.BOLD)
            background = rippleDrawable(0xFF888888.toInt(), 0xFFFFFFFF.toInt())
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
            alpha = 0f
            translationY = 40f
            setOnClickListener {
                safeReleaseMedia()
                vibrator?.cancel()
                finish()
            }
        }
        btnStop.post {
            btnStop.animate().alpha(1f).translationY(0f).setDuration(500).setStartDelay(600)
                .setInterpolator(android.view.animation.DecelerateInterpolator()).start()
        }

        card.addView(title)
        card.addView(time)
        card.addView(btnSnooze)
        card.addView(btnStop)

        // Плавное появление
        icon.alpha = 0f; icon.translationY = 40f
        title.alpha = 0f; title.translationY = 40f
        time.alpha = 0f; time.translationY = 40f
        icon.post {
            icon.animate().alpha(1f).translationY(0f).setDuration(500).setStartDelay(100).start()
            title.animate().alpha(1f).translationY(0f).setDuration(500).setStartDelay(200).start()
            time.animate().alpha(1f).translationY(0f).setDuration(500).setStartDelay(300).start()
        }

        // Центрируем карточку
        val cardParams = android.widget.FrameLayout.LayoutParams(
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
            android.widget.FrameLayout.LayoutParams.WRAP_CONTENT
        )
        cardParams.gravity = android.view.Gravity.CENTER
        card.layoutParams = cardParams
        if (blurView != null) {
            val blurParams = android.widget.FrameLayout.LayoutParams(
                android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
                android.widget.FrameLayout.LayoutParams.MATCH_PARENT
            )
            blurView.layoutParams = blurParams
            root.addView(blurView)
        }
        root.addView(card)
        setContentView(root)

        // Анимация появления
        card.post {
            card.animate().alpha(1f).scaleX(1f).scaleY(1f).setDuration(500).setStartDelay(100)
                .setInterpolator(android.view.animation.DecelerateInterpolator()).start()
        }

        // Звук
        val alarmResId = resources.getIdentifier("alarm_classic", "raw", packageName)
        mediaPlayer = MediaPlayer.create(this, alarmResId)
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()

        // Вибрация
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            applicationContext.getSystemService(Vibrator::class.java)
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 1000, 1000), 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(longArrayOf(0, 1000, 1000), 0)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        safeReleaseMedia()
        vibrator?.cancel()
        fallbackHandler?.removeCallbacks(fallbackRunnable!!)
    }

    private fun safeReleaseMedia() {
        if (released) return
        try {
            if (mediaPlayer != null) {
                if (mediaPlayer!!.isPlaying) {
                    mediaPlayer!!.stop()
                }
                mediaPlayer!!.release()
            }
        } catch (_: Exception) {}
        released = true
    }
}
