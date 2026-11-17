import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mingle/models/reply.dart';
import 'package:mingle/services/reply_service.dart';
import 'package:mingle/state/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'conversation messages are not saved to local history by default',
    () async {
      final controller = await _controller();

      await controller.generate(
        const ReplyRequest(
          message: 'A private incoming message',
          tone: 'Friendly',
          language: 'English',
          length: 'Medium',
        ),
      );

      expect(controller.replies, hasLength(3));
      expect(controller.history, isEmpty);
      expect(controller.lastResultIsMock, isFalse);
      controller.dispose();
    },
  );

  test(
    'history stores generated replies only when explicitly enabled',
    () async {
      final controller = await _controller();
      await controller.setSaveHistory(true);

      await controller.generate(
        const ReplyRequest(
          message: 'A private incoming message',
          tone: 'Friendly',
          language: 'English',
          length: 'Medium',
        ),
      );

      final preferences = await SharedPreferences.getInstance();
      expect(controller.history, hasLength(3));
      expect(
        preferences.getString('history'),
        isNot(contains('private incoming')),
      );

      await controller.setSaveHistory(false);
      expect(controller.history, isEmpty);
      expect(preferences.getString('history'), isNull);
      controller.dispose();
    },
  );

  test('favorites can be saved and removed locally', () async {
    final controller = await _controller();

    await controller.toggleFavorite('A reply worth keeping', 'Friendly');
    expect(controller.isFavorite('A reply worth keeping'), isTrue);
    await controller.toggleFavorite('A reply worth keeping', 'Friendly');

    expect(controller.favorites, isEmpty);
    controller.dispose();
  });
}

Future<AppController> _controller() async {
  final client = MockClient((request) async {
    expect(request.url.path, '/api/v1/replies/generate');
    return http.Response(
      jsonEncode({
        'provider': 'openai',
        'replies': [
          {'text': 'First reply', 'approach': 'Warm'},
          {'text': 'Second reply', 'approach': 'Playful'},
          {'text': 'Third reply', 'approach': 'Direct'},
        ],
      }),
      200,
    );
  });
  final controller = AppController(replyService: ReplyService(client: client));
  await controller.initialize();
  return controller;
}
