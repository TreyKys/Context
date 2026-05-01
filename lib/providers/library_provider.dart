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
  late final LibraryService _service;

  @override
  Future<List<SavedWord>> build() async {
    _service = ref.watch(libraryServiceProvider);
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
