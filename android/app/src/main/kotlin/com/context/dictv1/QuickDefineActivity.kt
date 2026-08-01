package com.context.dictv1

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The lightweight "Define" surface.
 *
 * Selecting text in another app and tapping Define lands here rather than in
 * the full app: this activity uses a translucent dialog theme, so the card
 * floats over whatever the user was reading and dismisses straight back to it.
 * The point is not to yank someone out of their feed to look up one word.
 *
 * It renders the `/quick-define` Flutter route in its own engine — separate
 * from MainActivity's, so opening this never disturbs the main app's state.
 */
class QuickDefineActivity : FlutterActivity() {

    private var selectedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        selectedText = extractProcessText(intent)
        // Nothing to define — don't leave an empty dialog on screen.
        if (selectedText == null) finish()
    }

    /** Renders the compact card instead of the full app shell. */
    override fun getInitialRoute(): String = "/quick-define"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "$packageName/quick_define"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getText" -> result.success(selectedText)
                // Lets the Dart side dismiss the dialog itself (tap-outside,
                // close button, or "open full app").
                "close" -> {
                    finish()
                    result.success(true)
                }
                "openFullApp" -> {
                    startActivity(
                        Intent(this, MainActivity::class.java).apply {
                            action = Intent.ACTION_PROCESS_TEXT
                            type = "text/plain"
                            putExtra(Intent.EXTRA_PROCESS_TEXT, selectedText)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )
                    finish()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun extractProcessText(intent: Intent?): String? {
        if (intent == null || intent.action != Intent.ACTION_PROCESS_TEXT) return null
        return intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
            ?.toString()?.trim()?.takeIf { it.isNotEmpty() }
    }
}
