import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vibe_result.dart';
import '../services/llm_service.dart';

class VibeState {
  final bool isLoading;
  final VibeResult? result;
  final String? error;

  VibeState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  factory VibeState.initial() => VibeState();

  factory VibeState.loading() => VibeState(isLoading: true);

  factory VibeState.success(VibeResult result) => VibeState(
    isLoading: false,
    result: result,
    error: null,
  );

  factory VibeState.error(String error) => VibeState(
    isLoading: false,
    result: null,
    error: error,
  );
}

final llmServiceProvider = Provider<LLMService>((ref) => LLMService());

class VibeNotifier extends Notifier<VibeState> {
  late final LLMService _llmService;

  @override
  VibeState build() {
    _llmService = ref.watch(llmServiceProvider);
    return VibeState.initial();
  }

  Future<void> generateVibe(String input, String mode, String context) async {
    state = VibeState.loading();
    try {
      final result = await _llmService.generateVibe(input, mode, context);
      state = VibeState.success(result);
    } catch (e) {
      state = VibeState.error(e.toString());
    }
  }
}

final vibeProvider = NotifierProvider<VibeNotifier, VibeState>(VibeNotifier.new);
