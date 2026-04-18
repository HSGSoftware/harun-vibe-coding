package com.harun.vibecoding

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * Dispatch helper for cross-process notifications fired by the Go backend
 * via the ServerLifecycleService channel.
 */
object NotificationHelper {
    fun update(context: Context, id: Int, title: String, text: String) {
        val notification = NotificationCompat.Builder(context, ServerLifecycleService.CHANNEL_SERVICE)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        NotificationManagerCompat.from(context).notify(id, notification)
    }

    fun post(context: Context, args: Map<*, *>) {
        val id = (args["id"] as? Number)?.toInt() ?: return
        val title = args["title"] as? String ?: return
        val body = args["body"] as? String ?: ""
        val category = args["category"] as? String ?: "system"
        val channelId = channelForCategory(category)
        val channelName = channelNameFor(context, category)
        val importance = importanceForCategory(category)

        ServerLifecycleService.ensureChannel(context, channelId, channelName, importance)

        val builder = NotificationCompat.Builder(context, channelId)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setAutoCancel(true)
            .setPriority(priorityForCategory(category))

        NotificationManagerCompat.from(context).notify(id, builder.build())
    }

    fun cancel(context: Context, id: Int) {
        NotificationManagerCompat.from(context).cancel(id)
    }

    fun requestBatteryExempt(context: Context) {
        val pkg = context.packageName
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:$pkg")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        try {
            context.startActivity(intent)
        } catch (_: Exception) {
            // Device OEM may block this intent; UI should fall back to a settings hint.
        }
    }

    private fun channelForCategory(category: String): String = when (category) {
        "ai_response" -> ServerLifecycleService.CHANNEL_AI_RESPONSE
        "ai_permission" -> ServerLifecycleService.CHANNEL_AI_PERMISSION
        "server_error" -> ServerLifecycleService.CHANNEL_SERVER_ERROR
        "tunnel" -> ServerLifecycleService.CHANNEL_TUNNEL
        "backup" -> ServerLifecycleService.CHANNEL_BACKUP
        else -> ServerLifecycleService.CHANNEL_SYSTEM
    }

    private fun channelNameFor(context: Context, category: String): String = when (category) {
        "ai_response" -> context.getString(R.string.channel_ai_response_name)
        "ai_permission" -> context.getString(R.string.channel_ai_permission_name)
        "server_error" -> context.getString(R.string.channel_server_error_name)
        "tunnel" -> context.getString(R.string.channel_tunnel_name)
        "backup" -> context.getString(R.string.channel_backup_name)
        else -> context.getString(R.string.channel_system_name)
    }

    private fun importanceForCategory(category: String): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return 0
        return when (category) {
            "ai_permission", "server_error" -> NotificationManager.IMPORTANCE_HIGH
            "backup" -> NotificationManager.IMPORTANCE_LOW
            else -> NotificationManager.IMPORTANCE_DEFAULT
        }
    }

    private fun priorityForCategory(category: String): Int = when (category) {
        "ai_permission", "server_error" -> NotificationCompat.PRIORITY_HIGH
        "backup" -> NotificationCompat.PRIORITY_LOW
        else -> NotificationCompat.PRIORITY_DEFAULT
    }
}
