import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  Future<String?> getDefinition(String word) async {
    try {
      final encoded = Uri.encodeComponent(word.toLowerCase().trim());
      final uri = Uri.parse('$_baseUrl/$encoded');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) return null;

        final entry = data[0] as Map<String, dynamic>;
        final meanings = entry['meanings'] as List<dynamic>?;
        if (meanings == null || meanings.isEmpty) return null;

        final buffer = StringBuffer();

        // Grab up to 2 meanings with 1 definition each
        for (int i = 0; i < meanings.length && i < 2; i++) {
          final meaning = meanings[i] as Map<String, dynamic>;
          final partOfSpeech = meaning['partOfSpeech'] as String? ?? '';
          final definitions = meaning['definitions'] as List<dynamic>?;
          if (definitions == null || definitions.isEmpty) continue;

          final def = (definitions[0] as Map<String, dynamic>)['definition'] as String? ?? '';
          if (def.isNotEmpty) {
            buffer.write('[$partOfSpeech] $def');
            if (i < meanings.length - 1) buffer.write(' | ');
          }
        }

        final result = buffer.toString().trim();
        return result.isNotEmpty ? result : null;
      }
    } catch (_) {
      // Silent fail — dictionary lookup is optional grounding
    }
    return null;
  }
}
