import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/reply.dart';

class ReplyService {
  ReplyService({http.Client? client})
    : _client = client ?? http.Client(),
      _baseUrl = const String.fromEnvironment(
        'MINGLE_API_URL',
        defaultValue: 'http://localhost:8000',
      );

  final http.Client _client;
  final String _baseUrl;

  Future<GenerationResult> generate(ReplyRequest request) async {
    late http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl/api/v1/replies/generate'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 18));
    } on SocketException {
      return _offlineResult(request);
    } on TimeoutException {
      return _offlineResult(request);
    } on http.ClientException {
      return _offlineResult(request);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ReplyServiceException(
        'The reply service returned ${response.statusCode}.',
      );
    }
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final replies = (body['replies'] as List<dynamic>)
          .map((item) => ReplySuggestion.fromJson(item as Map<String, dynamic>))
          .toList();
      if (replies.length != 3) {
        throw const ReplyServiceException(
          'The reply service did not return three suggestions.',
        );
      }
      return GenerationResult(
        replies: replies,
        isMock: body['provider'] == 'mock',
      );
    } on FormatException catch (error) {
      throw ReplyServiceException(
        'The reply service returned invalid JSON: $error',
      );
    } on TypeError catch (error) {
      throw ReplyServiceException(
        'The reply service returned invalid data: $error',
      );
    }
  }

  GenerationResult _offlineResult(ReplyRequest request) =>
      GenerationResult(replies: _mockReplies(request), isMock: true);

  List<ReplySuggestion> _mockReplies(ReplyRequest request) {
    final topic = request.message.trim().replaceAll(RegExp(r'\s+'), ' ');
    final clipped = topic.length > 72 ? '${topic.substring(0, 69)}...' : topic;
    final context = request.context.trim();
    return [
      ReplySuggestion(
        approach: 'Warm & natural',
        text: _localized(
          request.language,
          "That sounds good! Tell me a little more about $clipped",
        ),
      ),
      ReplySuggestion(
        approach: 'Playful',
        text: context.isEmpty
            ? "I was hoping you'd bring that up 😊 What did you have in mind?"
            : "I like where this is going 😊 $context",
      ),
      ReplySuggestion(
        approach: 'Straightforward',
        text: request.length.toLowerCase() == 'short'
            ? 'I’m in! What’s the plan?'
            : 'Thanks for asking! I’d love to hear more and figure out a plan that works for us.',
      ),
    ];
  }

  String _localized(String language, String fallback) {
    switch (language.toLowerCase()) {
      case 'hindi':
        return 'यह अच्छा लग रहा है! इसके बारे में थोड़ा और बताओ?';
      case 'marathi':
        return 'हे छान वाटतंय! याबद्दल थोडं अजून सांगशील?';
      case 'hinglish':
        return 'Sounds good yaar! Iske baare mein thoda aur batao?';
      default:
        return fallback;
    }
  }
}

class ReplyServiceException implements Exception {
  const ReplyServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
