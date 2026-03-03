import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LLMService {
  late final GenerativeModel _model;

  LLMService({GenerativeModel? model}) {
    if (model != null) {
      _model = model;
    } else {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      );
    }
  }

  Future<String?> generateContent(String prompt, {String? systemInstruction}) async {
    final modelToUse = systemInstruction != null
        ? GenerativeModel(
            model: 'gemini-1.5-flash',
            apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
            systemInstruction: Content.system(systemInstruction),
            generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
            ),
          )
        : _model;

    int attempt = 0;
    while (attempt < 3) {
      try {
        final content = [Content.text(prompt)];
        final response = await modelToUse.generateContent(content);
        return response.text;
      } on GenerativeAIException catch (_) {
        attempt++;
        if (attempt == 1) {
          await Future.delayed(const Duration(seconds: 2));
        } else if (attempt == 2) {
          await Future.delayed(const Duration(seconds: 4));
        } else {
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    }
    return null;
  }
}
