import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A word/phrase the user selected in another app (via the "Define" entry in
/// Android's text-selection menu), waiting to be looked up.
///
/// Overridden at startup in main.dart with the selection that launched the app,
/// and set again by HomeScreen whenever one arrives while the app is running.
/// DirectSearchTab consumes it and clears it back to null so the same text is
/// never searched twice.
final pendingLookupProvider = StateProvider<String?>((ref) => null);
