import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/vibe_result.dart';

class LLMService {
  late final GenerativeModel _model;

  LLMService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<VibeResult> directSearch(String input) async {
    final prompt =
        '''
You are a hyper-intelligent linguistic and cultural analyst. The user is searching for: '$input'.
Return a strict JSON object with no markdown backticks containing:
1. literal_meaning: A sharp, strictly factual and objective dictionary definition. Do not use slang here.
2. etymology_context: A breakdown of the word's origins, current cultural/professional usage, and its evolution.
3. tags: An array of 4 highly specific string tags (e.g., #Finance, #GenZ).
''';
    return _callLlmAndParse(prompt, isDirectSearch: true);
  }

  Future<VibeResult> generateVibe(
    String input,
    String mode,
    String vibe,
  ) async {
    final prompt =
        '''
You are a hyper-intelligent cultural dictionary. The user wants you to process the word/phrase: '$input'.
Action requested (Mode): '$mode'. > Target Persona (Vibe): '$vibe'.

Analyze the input and return a strict JSON object with exactly these four keys. Do not use markdown backticks:
1. literal_definition: A short, strictly factual and objective dictionary definition. It must be a real definition so the user understands the core meaning before the slang translation.
2. vibe_translation: The definition fully translated into the exact vernacular, tone, and slang of the Target Persona. Fully commit to the bit.
3. example_sentence: A hilarious, highly accurate sentence using the word strictly from the perspective of the Target Persona. To anchor the humor and relativity, the sentence MUST EXACTLY begin with either 'For context...' or 'Well, in context...'
4. tags: An array of 3 relevant strings.
''';

    return _callLlmAndParse(prompt, isDirectSearch: false);
  }

  Future<VibeResult> _callLlmAndParse(
    String prompt, {
    required bool isDirectSearch,
  }) async {
    int retries = 0;
    while (retries < 3) {
      try {
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        final responseText = response.text;

        if (responseText == null || responseText.isEmpty) {
          throw Exception('Empty response from API');
        }

        // Strip markdown backticks if present (JSON parsing helper)
        String cleanJson = responseText
            .replaceAll(RegExp(r'```(?:json)?'), '')
            .replaceAll('```', '')
            .trim();

        final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);
        return VibeResult.fromJson(jsonMap, isDirectSearch: isDirectSearch);
      } catch (e) {
        retries++;
        if (retries >= 3) {
          throw Exception(
            'Decryption Failed: Signal Lost or High Network Traffic.',
          );
        }
        // Exponential backoff
        await Future.delayed(Duration(seconds: retries == 1 ? 2 : 4));
      }
    }
    throw Exception('Decryption Failed: Signal Lost or High Network Traffic.');
  }
}
