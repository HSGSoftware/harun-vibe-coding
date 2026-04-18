package com.harun.vibecoding

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Bridge from Flutter to Termux. MethodChannel: com.harun.vibecoding/termux
 *
 * Methods (Flutter -> Native):
 *   isInstalled()                         -> Boolean
 *   isAllowExternalAppsSet()              -> Boolean
 *   runScript({workdir, scriptPath, background}) -> Map
 *   openTermux()                          -> null
 *   openPlayStore()                       -> null
 *
 * The runScript path sends a RUN_COMMAND intent to Termux's RunCommandService
 * with the exact extras Termux expects (see plan.md §8.3).
 */
object TermuxBridge {
    private const val CHANNEL = "com.harun.vibecoding/termux"

    private const val TERMUX_PACKAGE = "com.termux"
    private const val RUN_COMMAND_SERVICE = "com.termux.app.RunCommandService"
    private const val ACTION_RUN_COMMAND = "com.termux.RUN_COMMAND"
    private const val EXTRA_PATH = "com.termux.RUN_COMMAND_PATH"
    private const val EXTRA_ARGS = "com.termux.RUN_COMMAND_ARGUMENTS"
    private const val EXTRA_WORKDIR = "com.termux.RUN_COMMAND_WORKDIR"
    private const val EXTRA_BACKGROUND = "com.termux.RUN_COMMAND_BACKGROUND"
    private const val EXTRA_SESSION_ACTION = "com.termux.RUN_COMMAND_SESSION_ACTION"

    private const val PROPERTIES_FILE = "/data/data/com.termux/files/home/.termux/termux.properties"

    fun register(engine: FlutterEngine, context: Context) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isInstalled" -> result.success(isInstalled(context))
                "isAllowExternalAppsSet" -> result.success(isAllowExternalAppsSet())
                "runScript" -> {
                    val workdir = call.argument<String>("workdir") ?: ""
                    val scriptPath = call.argument<String>("scriptPath") ?: ""
                    val background = call.argument<Boolean>("background") ?: false
                    runScript(context, scriptPath, workdir, background, result)
                }
                "openTermux" -> {
                    openTermux(context)
                    result.success(null)
                }
                "openPlayStore" -> {
                    openPlayStore(context)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isInstalled(context: Context): Boolean {
        return try {
            @Suppress("DEPRECATION")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.packageManager.getPackageInfo(TERMUX_PACKAGE, PackageManager.PackageInfoFlags.of(0))
            } else {
                context.packageManager.getPackageInfo(TERMUX_PACKAGE, 0)
            }
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun isAllowExternalAppsSet(): Boolean {
        val file = File(PROPERTIES_FILE)
        if (!file.exists()) return false
        return try {
            file.readLines()
                .asSequence()
                .map { it.trim() }
                .filterNot { it.startsWith("#") }
                .any { line ->
                    val normalized = line.replace(" ", "").lowercase()
                    normalized == "allow-external-apps=true"
                }
        } catch (_: Exception) {
            false
        }
    }

    private fun runScript(
        context: Context,
        scriptPath: String,
        workdir: String,
        background: Boolean,
        result: MethodChannel.Result,
    ) {
        val intent = Intent(ACTION_RUN_COMMAND).apply {
            setClassName(TERMUX_PACKAGE, RUN_COMMAND_SERVICE)
            putExtra(EXTRA_PATH, scriptPath)
            putExtra(EXTRA_ARGS, emptyArray<String>())
            putExtra(EXTRA_WORKDIR, workdir)
            putExtra(EXTRA_BACKGROUND, background)
            putExtra(EXTRA_SESSION_ACTION, 0)
        }
        try {
            val component: ComponentName? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
            result.success(
                mapOf(
                    "dispatched" to (component != null),
                    "service" to "${intent.component?.packageName}/${intent.component?.className}",
                ),
            )
        } catch (e: SecurityException) {
            result.error("SECURITY", "RUN_COMMAND permission missing", e.message)
        } catch (e: Exception) {
            result.error("DISPATCH_FAIL", e.message, null)
        }
    }

    private fun openTermux(context: Context) {
        val launch = context.packageManager.getLaunchIntentForPackage(TERMUX_PACKAGE)
        if (launch != null) {
            launch.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(launch)
        } else {
            openPlayStore(context)
        }
    }

    private fun openPlayStore(context: Context) {
        val uri = Uri.parse("https://f-droid.org/packages/com.termux/")
        val intent = Intent(Intent.ACTION_VIEW, uri).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }
}
