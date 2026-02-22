class VibeResult {
  final String literalDefinition;
  final String vibeTranslation;
  final String exampleSentence;
  final List<String> tags;

  VibeResult({
    required this.literalDefinition,
    required this.vibeTranslation,
    required this.exampleSentence,
    required this.tags,
  });

  factory VibeResult.fromJson(Map<String, dynamic> json) {
    return VibeResult(
      literalDefinition: json['literal_definition'] as String? ?? 'Definition not available.',
      vibeTranslation: json['vibe_translation'] as String? ?? 'Translation failed.',
      exampleSentence: json['example_sentence'] as String? ?? 'No example available.',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
