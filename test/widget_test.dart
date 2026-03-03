import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/main.dart';
import 'package:myapp/providers/vibe_provider.dart';
import 'package:myapp/services/llm_service.dart';
import 'package:myapp/models/vibe_result.dart';

class MockLLMService implements LLMService {
  @override
  Future<VibeResult> generateVibe(String input, String mode, String vibe) async {
    return VibeResult(
      literalDefinition: 'Test',
      vibeTranslation: 'Test',
      exampleSentence: 'Test',
      tags: [],
    );
  }
}

void main() {
  testWidgets('App launches and shows greeting', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        llmServiceProvider.overrideWithValue(MockLLMService()),
      ],
      child: const ContextDictionaryApp(),
    ));

    // Verify that the greeting part of the text is present.
    // Since the greeting is dynamic ("Good Morning", etc.), we might not know exactly which one.
    // But we know "What would you like to know?" is static.
    expect(find.text('What would you like to know?'), findsOneWidget);
  });
}
