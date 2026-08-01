package com.context.dictv1

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Handles ACTION_PROCESS_TEXT so "Context Dictionary" appears in the text
 * selection menu of every app. Unlike the floating overlay this needs no
 * permission at all, and it works inside FLAG_SECURE apps (banking, streaming)
 * where the OS refuses to draw overlays.
 *
 * The selected text can arrive two ways:
 *  - cold start: the intent is on the activity before Flutter is attached, so
 *    it is stashed and handed over when Dart asks for it.
 *  - already running (launchMode=singleTop): it arrives via onNewIntent and is
 *    pushed straight to Dart.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "com.context.dictv1/process_text"
    private var methodChannel: MethodChannel? = null

    /** Text captured before the Dart side was ready to receive it. */
    private var pendingText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingText = extractProcessText(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Device info + settings shortcut, used to guide users on OEM skins
        // (MIUI/ColorOS/FuntouchOS) that gate overlays behind a vendor-specific
        // permission which has no manifest tag and cannot be requested via API.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "$packageName/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "manufacturer" -> result.success(Build.MANUFACTURER)
                    "openAppSettings" -> {
                        val intent = Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.fromParts("package", packageName, null)
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).apply {
                setMethodCallHandler { call, result ->
                    when (call.method) {
                        // Dart polls this once at startup. Returns null when the
                        // app was opened normally rather than from a selection.
                        "getInitialText" -> {
                            result.success(pendingText)
                            pendingText = null
                        }
                        else -> result.notImplemented()
                    }
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val text = extractProcessText(intent) ?: return
        val channel = methodChannel
        if (channel != null) {
            channel.invokeMethod("onText", text)
        } else {
            // Engine not attached yet — hand it over on the next poll.
            pendingText = text
        }
    }

    private fun extractProcessText(intent: Intent?): String? {
        if (intent == null || intent.action != Intent.ACTION_PROCESS_TEXT) return null
        val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        return text?.trim()?.takeIf { it.isNotEmpty() }
    }
}
