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
    _model = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);
  }

  Future<VibeResult> directSearch(String input) async {
    final prompt =
        '''
You are a hyper-intelligent linguistic and cultural analyst. The user is searching for: '$input'.
Return a strict JSON object with no markdown backticks containing:
1. literal_meaning: A sharp, factual definition.
2. etymology_context: A breakdown of the word's origins or current cultural/professional usage.
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
1. literal_definition: A short, standard dictionary definition.
2. vibe_translation: The definition fully translated into the exact vernacular, tone, and slang of the Target Persona. Fully commit to the bit.
3. example_sentence: A hilarious, highly accurate sentence using the word strictly from the perspective of the Target Persona. To anchor the humor and relativity, the sentence MUST begin with either 'For context...' or 'Well, in context...'
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

        if (responseText == null) {
          throw Exception('Empty response from API');
        }

        // Strip markdown backticks if present (JSON parsing helper)
        String cleanJson = responseText.trim();
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.substring(7);
        } else if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.substring(3);
        }
        if (cleanJson.endsWith('```')) {
          cleanJson = cleanJson.substring(0, cleanJson.length - 3);
        }

        final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);
        return VibeResult.fromJson(jsonMap, isDirectSearch: isDirectSearch);
      } catch (e) {
        if (e is GenerativeAIException) {
          retries++;
          if (retries >= 3) {
            throw Exception(
              'Decryption Failed: Signal Lost or High Network Traffic.',
            );
          }
          // Exponential backoff
          await Future.delayed(Duration(seconds: retries == 1 ? 2 : 4));
        } else {
          // JSON parsing error or other
          throw Exception(
            'Decryption Failed: Signal Lost or High Network Traffic.',
          );
        }
      }
    }
    throw Exception('Decryption Failed: Signal Lost or High Network Traffic.');
  }
}
