import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Receives text the user selected in *another* app via Android's
/// ACTION_PROCESS_TEXT ("Define" in the selection menu).
///
/// This is the counterpart to the floating overlay: the overlay can't be drawn
/// over FLAG_SECURE apps (banking, streaming) and needs an OEM-specific extra
/// permission on MIUI/ColorOS, whereas this path needs no permission at all and
/// works everywhere the system text selection menu appears.
class ProcessTextService {
  ProcessTextService._();
  static final ProcessTextService instance = ProcessTextService._();

  static const MethodChannel _channel =
      MethodChannel('com.context.dictv1/process_text');

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// Emits each time the user shares a selection while the app is already open.
  Stream<String> get textStream => _controller.stream;

  bool _listening = false;

  /// Starts listening for selections that arrive while the app is running, and
  /// returns the selection that launched it (null on a normal cold start).
  Future<String?> start() async {
    if (!_listening) {
      _listening = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onText') {
          final text = call.arguments as String?;
          if (text != null && text.trim().isNotEmpty) {
            _controller.add(_normalize(text));
          }
        }
        return null;
      });
    }

    try {
      final initial = await _channel.invokeMethod<String>('getInitialText');
      if (initial == null || initial.trim().isEmpty) return null;
      return _normalize(initial);
    } on MissingPluginException {
      // Non-Android platform, or the engine isn't wired up — not fatal.
      return null;
    } catch (e) {
      debugPrint('ProcessTextService.start failed: $e');
      return null;
    }
  }

  /// Users often select a whole phrase or sentence. Trim it to something the
  /// lookup can actually work with rather than sending a paragraph to the model.
  String _normalize(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    const maxChars = 120;
    if (cleaned.length <= maxChars) return cleaned;
    return '${cleaned.substring(0, maxChars).trimRight()}…';
  }
}
