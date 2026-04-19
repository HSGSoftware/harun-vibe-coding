package com.harun.vibecoding

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Long-lived foreground service that keeps the Go backend reachable while the
 * app is backgrounded. MethodChannel: com.harun.vibecoding/service
 *
 * Notification channels created on first use follow plan.md §8.4.
 */
class ServerLifecycleService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: getString(R.string.service_title)
        val text = intent?.getStringExtra(EXTRA_TEXT) ?: getString(R.string.service_text_idle)
        startForeground(NOTIFICATION_ID, buildNotification(title, text))
        return START_STICKY
    }

    private fun buildNotification(title: String, text: String): Notification {
        ensureChannel(this, CHANNEL_SERVICE, getString(R.string.channel_service_name), NotificationManager.IMPORTANCE_LOW)
        return NotificationCompat.Builder(this, CHANNEL_SERVICE)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    companion object {
        const val CHANNEL_SERVICE = "hvc_service"
        const val CHANNEL_AI_RESPONSE = "hvc_ai_response"
        const val CHANNEL_AI_PERMISSION = "hvc_ai_permission"
        const val CHANNEL_SERVER_ERROR = "hvc_server_error"
        const val CHANNEL_TUNNEL = "hvc_tunnel"
        const val CHANNEL_BACKUP = "hvc_backup"
        const val CHANNEL_SYSTEM = "hvc_system"

        private const val CHANNEL = "com.harun.vibecoding/service"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_TEXT = "text"
        private const val NOTIFICATION_ID = 1001

        fun registerChannel(engine: FlutterEngine, context: Context) {
            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "startForeground" -> {
                        val title = call.argument<String>("title") ?: "Harun Vibe Coding"
                        val text = call.argument<String>("text") ?: ""
                        val intent = Intent(context, ServerLifecycleService::class.java).apply {
                            putExtra(EXTRA_TITLE, title)
                            putExtra(EXTRA_TEXT, text)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            context.startForegroundService(intent)
                        } else {
                            context.startService(intent)
                        }
                        result.success(null)
                    }
                    "stopForeground" -> {
                        context.stopService(Intent(context, ServerLifecycleService::class.java))
                        result.success(null)
                    }
                    "updateForeground" -> {
                        val title = call.argument<String>("title") ?: "Harun Vibe Coding"
                        val text = call.argument<String>("text") ?: ""
                        NotificationHelper.update(context, NOTIFICATION_ID, title, text)
                        result.success(null)
                    }
                    "postNotification" -> {
                        NotificationHelper.post(context, call.arguments as? Map<*, *> ?: emptyMap<String, Any>())
                        result.success(null)
                    }
                    "cancelNotification" -> {
                        val id = call.argument<Int>("id") ?: return@setMethodCallHandler result.success(null)
                        NotificationHelper.cancel(context, id)
                        result.success(null)
                    }
                    "requestBatteryExempt" -> {
                        NotificationHelper.requestBatteryExempt(context)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        fun ensureChannel(context: Context, id: String, name: String, importance: Int) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (manager.getNotificationChannel(id) != null) return
            manager.createNotificationChannel(NotificationChannel(id, name, importance))
        }
    }
}
