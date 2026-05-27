import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotaCountNotifier extends Notifier<int> {
  QuotaCountNotifier([this._initial = 3]);
  final int _initial;

  @override
  int build() => _initial;

  void set(int value) => state = value;
}

final quotaCountProvider =
    NotifierProvider<QuotaCountNotifier, int>(QuotaCountNotifier.new);

class ShowRatingPromptNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final showRatingPromptProvider =
    NotifierProvider<ShowRatingPromptNotifier, bool>(ShowRatingPromptNotifier.new);
