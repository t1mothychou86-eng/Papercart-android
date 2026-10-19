import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wispar/services/translations/gemini_translation_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Gemini skips non-text parts and preserves valid text in order',
      () async {
    SharedPreferences.setMockInitialValues({'gemini_api_key': 'test'});
    final body = 'data: ${jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': null},
                  {'text': 42},
                  {'text': false},
                  {'text': <dynamic>[]},
                  {
                    'text': {'value': 'ignore'}
                  },
                  {
                    'inlineData': {'mimeType': 'image/png'}
                  },
                  null,
                  42,
                  {'text': ''},
                  {'text': '译文'},
                  {'text': 'null'},
                  {'text': '。'},
                ]
              }
            }
          ]
        })}\n';
    final chunks = await http.runWithClient(() async {
      final instance = await GeminiTranslationProvider.instance;
      final stream = await instance.translateStream(
          text: 'text', sourceLangName: 'English', targetLangName: 'Chinese');
      return stream.toList();
    },
        () => MockClient((_) async => http.Response(body, 200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'})));
    expect(chunks, ['译文null。']);
  });
}
