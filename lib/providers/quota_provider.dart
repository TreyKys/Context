import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive search quota count — updated by VibeNotifier after every search.
/// UI reads this to show "X searches left today".
final quotaCountProvider = StateProvider<int>((ref) => 3);

/// Fires true once after the user's 5th lifetime search, then resets to false.
/// HomeScreen watches this and shows the rate-us SnackBar.
final showRatingPromptProvider = StateProvider<bool>((ref) => false);
