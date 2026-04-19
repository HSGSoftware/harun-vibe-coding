package com.harun.vibecoding

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Speech-to-text bridge backed by Android SpeechRecognizer.
 * MethodChannel:  com.harun.vibecoding/speech
 * EventChannel:   com.harun.vibecoding/speech_events
 */
object SpeechBridge {
    private const val METHOD_CHANNEL = "com.harun.vibecoding/speech"
    private const val EVENT_CHANNEL = "com.harun.vibecoding/speech_events"

    private var recognizer: SpeechRecognizer? = null
    private var eventSink: EventChannel.EventSink? = null

    fun register(engine: FlutterEngine, context: Context) {
        val method = MethodChannel(engine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        method.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(SpeechRecognizer.isRecognitionAvailable(context))
                "start" -> {
                    val locale = call.argument<String>("locale") ?: "tr-TR"
                    start(context, locale)
                    result.success(null)
                }
                "stop" -> {
                    recognizer?.stopListening()
                    result.success(null)
                }
                "cancel" -> {
                    recognizer?.cancel()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(engine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            },
        )
    }

    private fun start(context: Context, locale: String) {
        recognizer?.cancel()
        recognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
            setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) { emit("ready", null) }
                override fun onBeginningOfSpeech() { emit("begin", null) }
                override fun onRmsChanged(rmsdB: Float) {}
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() { emit("end", null) }
                override fun onError(error: Int) { emit("error", error.toString()) }
                override fun onResults(results: Bundle?) {
                    val text = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull()
                    emit("final", text)
                }
                override fun onPartialResults(partialResults: Bundle?) {
                    val text = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull()
                    emit("partial", text)
                }
                override fun onEvent(eventType: Int, params: Bundle?) {}
            })
        }
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        }
        recognizer?.startListening(intent)
    }

    private fun emit(kind: String, text: String?) {
        eventSink?.success(mapOf("kind" to kind, "text" to text))
    }
}
