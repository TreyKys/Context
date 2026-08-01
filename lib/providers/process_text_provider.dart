import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A word/phrase the user selected in another app (via "Define" in Android's
/// text-selection menu), waiting to be looked up.
///
/// Seeded in main.dart with the selection that launched the app, and set again
/// by HomeScreen whenever one arrives while the app is already running.
/// DirectSearchTab consumes it and calls [clear] so the same text is never
/// searched twice.
///
/// Written as a Notifier rather than a StateProvider because StateProvider was
/// removed in Riverpod 3.x — this mirrors QuotaCountNotifier.
class PendingLookupNotifier extends Notifier<String?> {
  PendingLookupNotifier([this._initial]);
  final String? _initial;

  @override
  String? build() => _initial;

  void set(String? value) => state = value;
  void clear() => state = null;
}

final pendingLookupProvider =
    NotifierProvider<PendingLookupNotifier, String?>(PendingLookupNotifier.new);
