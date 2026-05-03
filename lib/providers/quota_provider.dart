import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotaCountNotifier extends Notifier<int> {
  final int? _initialValue;

  QuotaCountNotifier([this._initialValue]);

  @override
  int build() => _initialValue ?? 3;

  @override
  set state(int value) => super.state = value;
}

/// Reactive search quota count — updated by VibeNotifier after every search.
/// UI reads this to show "X searches left today".
final quotaCountProvider = NotifierProvider<QuotaCountNotifier, int>(QuotaCountNotifier.new);

class ShowRatingPromptNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  @override
  set state(bool value) => super.state = value;
}

/// Fires true once after the user's 5th lifetime search, then resets to false.
/// HomeScreen watches this and shows the rate-us SnackBar.
final showRatingPromptProvider = NotifierProvider<ShowRatingPromptNotifier, bool>(ShowRatingPromptNotifier.new);
