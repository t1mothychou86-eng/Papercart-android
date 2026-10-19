import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wispar/services/translations/chatgpt_translation_provider.dart';
import 'package:wispar/services/translations/deepseek_translation_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final provider in ['chatgpt', 'deepseek']) {
    test('$provider emits only string content from an SSE response', () async {
      SharedPreferences.setMockInitialValues({'${provider}_api_key': 'test'});
      final deltas = <Map<String, dynamic>>[
        {'role': 'assistant'},
        {'content': null},
        {'content': 42},
        {'content': false},
        {'content': <dynamic>[]},
        {
          'content': {'text': 'ignore'}
        },
        {'reasoning_content': 'ignore', 'content': null},
        {'content': ''},
        {'content': '译文'},
        {'content': 'null'}, // A literal string must not be filtered out.
        {}, // Finish delta.
      ];
      final body = [
        ': keepalive',
        for (final delta in deltas)
          'data: ${jsonEncode({
                'choices': [
                  {'delta': delta}
                ]
              })}',
        'data: ${jsonEncode({'choices': []})}',
        'data: [DONE]',
        '',
      ].join('\n');
      final client = MockClient((request) async {
        expect(jsonDecode(request.body)['stream'], isTrue);
        return http.Response(body, 200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'});
      });
      final chunks = await http.runWithClient(() async {
        final Stream<String> stream;
        if (provider == 'chatgpt') {
          final instance = await ChatgptTranslationProvider.instance;
          stream = await instance.translateStream(
              text: 'text',
              sourceLangName: 'English',
              targetLangName: 'Chinese');
        } else {
          final instance = await DeepSeekTranslationProvider.instance;
          stream = await instance.translateStream(
              text: 'text',
              sourceLangName: 'English',
              targetLangName: 'Chinese');
        }
        return stream.toList();
      }, () => client);
      expect(chunks, ['译文', 'null']);
    });
  }
}
