import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_word.dart';
import '../models/vibe_result.dart';
import '../services/library_service.dart';
import '../services/quota_service.dart';

final libraryServiceProvider = Provider<LibraryService>((ref) => LibraryService());

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, List<SavedWord>>(
  LibraryNotifier.new,
);

final isWordSavedProvider = FutureProvider.family<bool, String>((ref, word) async {
  final service = ref.watch(libraryServiceProvider);
  return service.isWordSaved(word);
});

class LibraryNotifier extends AsyncNotifier<List<SavedWord>> {
  // NOT `late final`: build() re-runs on the same notifier instance after
  // ref.invalidateSelf(), and re-assigning a `late final` throws
  // LateInitializationError — which silently put the whole library into an
  // error state the moment a word was saved, until the app was restarted.
  LibraryService get _service => ref.read(libraryServiceProvider);

  @override
  Future<List<SavedWord>> build() async {
    ref.watch(libraryServiceProvider);
    return _service.getSavedWords();
  }

  Future<String?> saveWord(VibeResult result, String word) async {
    final quotaService = ref.read(quotaServiceProvider);
    final error = await _service.saveWord(
      result,
      word,
      isPremium: quotaService.isPremium,
    );
    if (error == null) {
      ref.invalidateSelf();
      ref.invalidate(isWordSavedProvider(word.trim().toLowerCase()));
    }
    return error;
  }

  Future<void> deleteWord(int id, String word) async {
    await _service.deleteWord(id);
    ref.invalidateSelf();
    ref.invalidate(isWordSavedProvider(word.trim().toLowerCase()));
  }

  Future<void> deleteByWord(String word) async {
    await _service.deleteByWord(word);
    ref.invalidateSelf();
    ref.invalidate(isWordSavedProvider(word.trim().toLowerCase()));
  }

  Future<List<SavedWord>> search(String query) async {
    return _service.searchLibrary(query);
  }
}
