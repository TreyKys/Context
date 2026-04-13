import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // Read .env manually
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('Error: .env file not found.');
    return;
  }

  final lines = await envFile.readAsLines();
  String? apiKey;
  for (final line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.substring('GEMINI_API_KEY='.length).trim();
      break;
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('Error: GEMINI_API_KEY not found in .env.');
    return;
  }

  // Model setup
  String modelName = 'gemini-2.5-flash';
  final model = GenerativeModel(model: modelName, apiKey: apiKey);

  // Test data
  final words = ['Exit Liquidity', 'Diamond Hands', 'Rug Pull', 'FOMO'];

  final modes = ['Explain Like I\'m 5', 'Define', 'Roast'];

  final vibes = [
    'Lagos Uncle / Aunty',
    'Tech Startup Founder',
    'Passive-Aggressive Colleague',
    '90s Hacker',
  ];

  final testCases = [
    (
      word: words[0],
      mode: modes[0],
      vibe: vibes[0],
    ), // Exit Liquidity, ELI5, Lagos
    (
      word: words[1],
      mode: modes[1],
      vibe: vibes[1],
    ), // Diamond Hands, Define, Tech Startup
    (
      word: words[2],
      mode: modes[2],
      vibe: vibes[2],
    ), // Rug Pull, Roast, Passive-Aggressive Colleague
    (word: words[3], mode: modes[0], vibe: vibes[3]), // FOMO, ELI5, 90s Hacker
  ];

  print('============================================');
  print('API DIAGNOSTIC SCRIPT INITIALIZED');
  print('Model: $modelName');
  print('============================================\n');

  for (final testCase in testCases) {
    print('--------------------------------------------');
    print(
      'Testing: [${testCase.word}] | Mode: [${testCase.mode}] | Vibe: [${testCase.vibe}]',
    );

    final prompt =
        '''
You are a hyper-intelligent cultural dictionary. The user wants you to process the word/phrase: '${testCase.word}'.
Action requested (Mode): '${testCase.mode}'. > Target Persona (Vibe): '${testCase.vibe}'.

Analyze the input and return a strict JSON object with exactly these four keys. Do not use markdown backticks:
1. literal_definition: A short, standard dictionary definition.
2. vibe_translation: The definition fully translated into the exact vernacular, tone, and slang of the Target Persona. Fully commit to the bit.
3. example_sentence: A hilarious, highly accurate sentence using the word strictly from the perspective of the Target Persona. To anchor the humor and relativity, the sentence MUST begin with either 'For context...' or 'Well, in context...'
4. tags: An array of 3 relevant strings.
''';

    final stopwatch = Stopwatch()..start();
    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      stopwatch.stop();

      print('\n[SUCCESS]');
      print('Execution Time: ${stopwatch.elapsedMilliseconds} ms');
      print('Raw Response:');
      print(response.text);
    } catch (e) {
      stopwatch.stop();
      print('\n[FAILED]');
      print('Execution Time: ${stopwatch.elapsedMilliseconds} ms');
      print('Raw Exception: $e');
    }
    print('--------------------------------------------\n');

    await Future.delayed(Duration(seconds: 2));
  }
}
