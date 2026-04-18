package com.harun.vibecoding

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.util.Base64
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/**
 * Screenshot + gallery/camera bridge. MethodChannel: com.harun.vibecoding/screenshot
 *
 * captureScreen uses MediaProjection and requires user consent. captureWindow
 * draws the current activity root view, so it needs no permission.
 */
object ScreenshotBridge {
    private const val CHANNEL = "com.harun.vibecoding/screenshot"

    fun register(engine: FlutterEngine, activity: FlutterActivity) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "captureWindow" -> result.success(captureWindow(activity))
                "captureScreen" -> result.error("UNSUPPORTED", "MediaProjection flow pending Faz 6", null)
                "pickFromGallery" -> result.error("UNSUPPORTED", "Gallery picker wired in Faz 6", null)
                "pickFromCamera" -> result.error("UNSUPPORTED", "Camera picker wired in Faz 6", null)
                else -> result.notImplemented()
            }
        }
    }

    private fun captureWindow(activity: FlutterActivity): String? {
        val root: View = activity.window?.decorView ?: return null
        val bitmap = Bitmap.createBitmap(root.width, root.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        root.draw(canvas)
        val bytes = ByteArrayOutputStream().apply {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, this)
        }.toByteArray()
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }
}
