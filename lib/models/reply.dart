class ReplyRequest {
  const ReplyRequest({
    required this.message,
    required this.tone,
    required this.language,
    required this.length,
    this.context = '',
  });

  final String message;
  final String tone;
  final String language;
  final String length;
  final String context;

  Map<String, Object> toJson() => {
    'message': message,
    'tone': tone.toLowerCase(),
    'language': language,
    'length': length.toLowerCase(),
    'context': context,
  };
}

class ReplySuggestion {
  const ReplySuggestion({required this.text, required this.approach});

  final String text;
  final String approach;

  factory ReplySuggestion.fromJson(Map<String, dynamic> json) =>
      ReplySuggestion(
        text: json['text'] as String,
        approach: json['approach'] as String? ?? 'Natural',
      );
}

class GenerationResult {
  const GenerationResult({required this.replies, required this.isMock});

  final List<ReplySuggestion> replies;
  final bool isMock;
}

class SavedReply {
  const SavedReply({
    required this.text,
    required this.tone,
    required this.createdAt,
  });

  final String text;
  final String tone;
  final DateTime createdAt;

  Map<String, Object> toJson() => {
    'text': text,
    'tone': tone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SavedReply.fromJson(Map<String, dynamic> json) => SavedReply(
    text: json['text'] as String,
    tone: json['tone'] as String? ?? 'Friendly',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
