package com.harun.vibecoding

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Flutter host Activity. MethodChannel bridges (Termux, ServerLifecycle, Speech, Screenshot)
 * are registered in configureFlutterEngine so the Flutter side can reach them from startup.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        TermuxBridge.register(flutterEngine, this)
        ServerLifecycleService.registerChannel(flutterEngine, this)
        SpeechBridge.register(flutterEngine, this)
        ScreenshotBridge.register(flutterEngine, this)
    }
}
