import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mingle/app/mingle_app.dart';
import 'package:mingle/services/reply_service.dart';
import 'package:mingle/state/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('intro leads into the home screen and reply studio', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      replyService: ReplyService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'provider': 'mock',
              'replies': [
                {'text': 'First', 'approach': 'Warm'},
                {'text': 'Second', 'approach': 'Playful'},
                {'text': 'Third', 'approach': 'Direct'},
              ],
            }),
            200,
          ),
        ),
      ),
    );
    await controller.initialize();

    await tester.pumpWidget(MingleApp(controller: controller));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Make every conversation flow.'), findsOneWidget);
    await tester.ensureVisible(find.text('Let’s get started'));
    await tester.tap(find.text('Let’s get started'));
    await tester.pumpAndSettle();
    expect(find.text('A better way to\nsay it.'), findsOneWidget);

    await tester.tap(find.text('Generate a reply'));
    await tester.pumpAndSettle();
    expect(find.text('Reply studio'), findsOneWidget);
    expect(find.text('THE MESSAGE'), findsOneWidget);
  });
}
