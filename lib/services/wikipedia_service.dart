import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static const String _baseUrl =
      'https://en.wikipedia.org/api/rest_v1/page/summary';

  Future<String?> getSummary(String term) async {
    try {
      final encoded = Uri.encodeComponent(term);
      final uri = Uri.parse('$_baseUrl/$encoded');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final extract = data['extract'] as String?;
        if (extract != null && extract.isNotEmpty) {
          // Return first ~400 chars — enough for grounding context
          return extract.length > 400 ? '${extract.substring(0, 400)}...' : extract;
        }
      }
    } catch (_) {
      // Silent fail — Wikipedia is optional grounding, not required
    }
    return null;
  }
}
