import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vibe_result.dart';
import '../services/llm_service.dart';
import '../services/quota_service.dart';
import 'quota_provider.dart';

class VibeState {
  final bool isLoading;
  final VibeResult? result;
  final String? error;
  final bool isQuotaLocked;

  VibeState({
    this.isLoading = false,
    this.result,
    this.error,
    this.isQuotaLocked = false,
  });

  factory VibeState.initial() => VibeState();
  factory VibeState.loading() => VibeState(isLoading: true);
  factory VibeState.success(VibeResult result) =>
      VibeState(isLoading: false, result: result, error: null);
  factory VibeState.error(String error) =>
      VibeState(isLoading: false, result: null, error: error);
  factory VibeState.quotaLocked() =>
      VibeState(isLoading: false, result: null, error: null, isQuotaLocked: true);
}

final llmServiceProvider = Provider<LLMService>((ref) => LLMService());

class VibeNotifier extends Notifier<VibeState> {
  late final LLMService _llmService;
  late final QuotaService _quotaService;

  @override
  VibeState build() {
    _llmService = ref.watch(llmServiceProvider);
    _quotaService = ref.watch(quotaServiceProvider);
    return VibeState.initial();
  }

  Future<void> generateVibe(String input, String mode, String context) async {
    if (state.isLoading) return;
    if (_quotaService.availableSearches <= 0) {
      state = VibeState.quotaLocked();
      return;
    }

    state = VibeState.loading();
    try {
      final result = await _llmService.generateVibe(input, mode, context);
      await _quotaService.consumeSearch();
      state = VibeState.success(result);
      _postSearchUpdates();
    } catch (e) {
      state = VibeState.error(e.toString());
    }
  }

  Future<void> directSearch(String input, {String? domain}) async {
    if (state.isLoading) return;
    if (_quotaService.availableSearches <= 0) {
      state = VibeState.quotaLocked();
      return;
    }

    state = VibeState.loading();
    try {
      final result = await _llmService.directSearch(input, domain: domain);
      await _quotaService.consumeSearch();
      state = VibeState.success(result);
      _postSearchUpdates();
    } catch (e) {
      state = VibeState.error(e.toString());
    }
  }

  void checkQuotaLock() {
    if (state.isQuotaLocked && _quotaService.availableSearches > 0) {
      state = VibeState.initial();
      // Quota was refreshed (ad watched or premium activated) — sync count
      ref.read(quotaCountProvider.notifier).state = _quotaService.availableSearches;
    }
  }

  void _postSearchUpdates() {
    // Sync reactive quota counter so both tabs show the updated count
    ref.read(quotaCountProvider.notifier).state = _quotaService.availableSearches;

    // Check if this is the 5th lifetime search → show rate-us prompt
    _quotaService.incrementAndCheckRating().then((shouldRate) {
      if (shouldRate) {
        ref.read(showRatingPromptProvider.notifier).state = true;
      }
    });
  }
}

final vibeProvider = NotifierProvider<VibeNotifier, VibeState>(
  VibeNotifier.new,
);

final directSearchProvider = NotifierProvider<VibeNotifier, VibeState>(
  VibeNotifier.new,
);
