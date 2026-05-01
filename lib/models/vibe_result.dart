class VibeResult {
  final String literalDefinition;
  final String vibeTranslation;
  final String exampleSentence;
  final List<String> tags;
  final bool isDirectSearch;
  final bool isVerified;

  VibeResult({
    required this.literalDefinition,
    required this.vibeTranslation,
    required this.exampleSentence,
    required this.tags,
    this.isDirectSearch = false,
    this.isVerified = false,
  });

  factory VibeResult.fromJson(
    Map<String, dynamic> json, {
    bool isDirectSearch = false,
    bool isVerified = false,
  }) {
    if (isDirectSearch) {
      return VibeResult(
        literalDefinition:
            json['literal_meaning'] as String? ?? 'Definition not available.',
        vibeTranslation:
            json['etymology_context'] as String? ??
            'Etymology/Context not available.',
        exampleSentence: '',
        tags:
            (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isDirectSearch: true,
        isVerified: isVerified,
      );
    }

    return VibeResult(
      literalDefinition:
          json['literal_definition'] as String? ?? 'Definition not available.',
      vibeTranslation:
          json['vibe_translation'] as String? ?? 'Translation failed.',
      exampleSentence:
          json['example_sentence'] as String? ?? 'No example available.',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      isDirectSearch: false,
      isVerified: isVerified,
    );
  }
}
