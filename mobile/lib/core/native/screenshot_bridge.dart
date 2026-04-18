import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Captures in-app screenshots or picks images. Returns base64 PNG.
class ScreenshotBridge {
  ScreenshotBridge() : _channel = const MethodChannel('com.harun.vibecoding/screenshot');
  final MethodChannel _channel;

  Future<String?> captureWindow() => _channel.invokeMethod<String>('captureWindow');
  Future<String?> captureScreen() => _channel.invokeMethod<String>('captureScreen');
  Future<String?> pickFromGallery() => _channel.invokeMethod<String>('pickFromGallery');
  Future<String?> pickFromCamera() => _channel.invokeMethod<String>('pickFromCamera');
}

final screenshotBridgeProvider = Provider<ScreenshotBridge>((ref) => ScreenshotBridge());
