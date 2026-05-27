import 'package:flutter_test/flutter_test.dart';
import 'package:context_dictionary/models/vibe_result.dart';

void main() {
  group('VibeResult', () {
    test('fromJson parses correct JSON', () {
      final json = {
        'literal_definition': 'A test definition',
        'vibe_translation': 'A test vibe',
        'example_sentence': 'A test example',
        'tags': ['tag1', 'tag2', 'tag3'],
      };

      final result = VibeResult.fromJson(json);

      expect(result.literalDefinition, 'A test definition');
      expect(result.vibeTranslation, 'A test vibe');
      expect(result.exampleSentence, 'A test example');
      expect(result.tags, ['tag1', 'tag2', 'tag3']);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final result = VibeResult.fromJson(json);

      expect(result.literalDefinition, 'Definition not available.');
      expect(result.vibeTranslation, 'Translation failed.');
      expect(result.exampleSentence, 'No example available.');
      expect(result.tags, isEmpty);
    });

    test('fromJson handles non-string tags', () {
      final json = {
        'tags': [1, 2, 'three'],
      };

      final result = VibeResult.fromJson(json);

      expect(result.tags, ['1', '2', 'three']);
    });
  });
}
