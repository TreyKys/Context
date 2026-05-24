import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/vibe_result.dart';
import 'wikipedia_service.dart';
import 'dictionary_service.dart';

class LLMService {
  late final GenerativeModel _model;
  final WikipediaService _wikipedia = WikipediaService();
  final DictionaryService _dictionary = DictionaryService();

  LLMService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<VibeResult> directSearch(String input, {String? domain}) async {
    // Fetch reference data in parallel — silent fail if unavailable
    final results = await Future.wait([
      _wikipedia.getSummary(input),
      _dictionary.getDefinition(input),
    ]);
    final wikiSummary = results[0];
    final dictDefinition = results[1];
    final isVerified = wikiSummary != null || dictDefinition != null;

    final groundingBlock = _buildGroundingBlock(wikiSummary, dictDefinition);

    final domainLine = (domain != null && domain != 'General / All Topics')
        ? '\nDomain context: "$domain" — frame the definition and etymology specifically within this domain.'
        : '';

    final prompt = '''
You are a hyper-intelligent linguistic and cultural analyst. The user is searching for: '$input'.
$groundingBlock$domainLine
Return a strict JSON object with no markdown backticks containing:
1. literal_meaning: A sharp, strictly factual and objective dictionary definition. Do not use slang here.${isVerified ? ' Cross-reference the REFERENCE DATA above to ensure factual accuracy.' : ''}
2. etymology_context: A breakdown of the word\'s origins, current cultural/professional usage, and its evolution.
3. tags: An array of 4 highly specific string tags (e.g., #Finance, #GenZ).
''';

    return _callLlmAndParse(prompt, isDirectSearch: true, isVerified: isVerified);
  }

  Future<VibeResult> generateVibe(
    String input,
    String mode,
    String vibe,
  ) async {
    // Fetch reference data in parallel — silent fail if unavailable
    final results = await Future.wait([
      _wikipedia.getSummary(input),
      _dictionary.getDefinition(input),
    ]);
    final wikiSummary = results[0];
    final dictDefinition = results[1];
    final isVerified = wikiSummary != null || dictDefinition != null;

    final groundingBlock = _buildGroundingBlock(wikiSummary, dictDefinition);

    final prompt = '''
You are a hyper-intelligent cultural dictionary. The user wants you to process the word/phrase: '$input'.
Action requested (Mode): '$mode'. > Target Persona (Vibe): '$vibe'.
$groundingBlock
Analyze the input and return a strict JSON object with exactly these four keys. Do not use markdown backticks:
1. literal_definition: A short, strictly factual and objective dictionary definition.${isVerified ? ' Cross-reference the REFERENCE DATA above — the literal definition must align with authoritative sources.' : ''} It must be a real definition so the user understands the core meaning before the slang translation.
2. vibe_translation: The definition fully translated into the exact vernacular, tone, and slang of the Target Persona. Fully commit to the bit.
3. example_sentence: A hilarious, highly accurate sentence using the word strictly from the perspective of the Target Persona. To anchor the humor and relativity, the sentence MUST EXACTLY begin with either 'For context...' or 'Well, in context...'
4. tags: An array of 3 relevant strings.
''';

    return _callLlmAndParse(prompt, isDirectSearch: false, isVerified: isVerified);
  }

  String _buildGroundingBlock(String? wikiSummary, String? dictDefinition) {
    if (wikiSummary == null && dictDefinition == null) return '';
    final buffer = StringBuffer('\n[REFERENCE DATA — use to ensure factual accuracy of the literal definition]\n');
    if (wikiSummary != null) buffer.writeln('Wikipedia: $wikiSummary');
    if (dictDefinition != null) buffer.writeln('Dictionary (Wiktionary): $dictDefinition');
    buffer.writeln('[END REFERENCE]\n');
    return buffer.toString();
  }

  Future<VibeResult> _callLlmAndParse(
    String prompt, {
    required bool isDirectSearch,
    required bool isVerified,
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

        String cleanJson = responseText
            .replaceAll(RegExp(r'```(?:json)?'), '')
            .replaceAll('```', '')
            .trim();

        // Extract just the JSON object in case the model added surrounding text
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanJson);
        if (jsonMatch != null) cleanJson = jsonMatch.group(0)!;

        final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);
        return VibeResult.fromJson(
          jsonMap,
          isDirectSearch: isDirectSearch,
          isVerified: isVerified,
        );
      } catch (e) {
        retries++;
        if (retries >= 3) {
          throw Exception(
            'Decryption Failed: Signal Lost or High Network Traffic.',
          );
        }
        await Future.delayed(Duration(seconds: retries == 1 ? 2 : 4));
      }
    }
    throw Exception('Decryption Failed: Signal Lost or High Network Traffic.');
  }
}
