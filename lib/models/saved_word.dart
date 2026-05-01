import 'dart:convert';

class SavedWord {
  final int? id;
  final String word;
  final String literalDefinition;
  final String vibeTranslation;
  final String exampleSentence;
  final List<String> tags;
  final bool isDirectSearch;
  final bool isVerified;
  final DateTime savedAt;

  SavedWord({
    this.id,
    required this.word,
    required this.literalDefinition,
    required this.vibeTranslation,
    required this.exampleSentence,
    required this.tags,
    required this.isDirectSearch,
    required this.isVerified,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'word': word,
      'literal_definition': literalDefinition,
      'vibe_translation': vibeTranslation,
      'example_sentence': exampleSentence,
      'tags_json': jsonEncode(tags),
      'is_direct_search': isDirectSearch ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  factory SavedWord.fromMap(Map<String, dynamic> map) {
    return SavedWord(
      id: map['id'] as int?,
      word: map['word'] as String,
      literalDefinition: map['literal_definition'] as String,
      vibeTranslation: map['vibe_translation'] as String,
      exampleSentence: map['example_sentence'] as String,
      tags: List<String>.from(jsonDecode(map['tags_json'] as String)),
      isDirectSearch: (map['is_direct_search'] as int) == 1,
      isVerified: (map['is_verified'] as int) == 1,
      savedAt: DateTime.parse(map['saved_at'] as String),
    );
  }
}
