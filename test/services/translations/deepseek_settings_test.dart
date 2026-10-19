import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wispar/services/translations/deepseek_settings.dart';
import 'package:wispar/services/translations/deepseek_translation_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new users default to deepseek-flash', () async {
    SharedPreferences.setMockInitialValues({});
    expect(
        await DeepSeekSettings.loadModelName(
            await SharedPreferences.getInstance()),
        'deepseek-flash');
  });

  for (final old in ['deepseek-chat', 'deepseek-reasoner']) {
    for (final base in [null, 'https://api.deepseek.com/v1']) {
      test('migrates $old on official endpoint $base and persists once',
          () async {
        SharedPreferences.setMockInitialValues({
          'deepseek_model_name': old,
          'use_custom_deepseek_base_url': base != null,
          if (base != null) 'deepseek_base_url': base,
        });
        final prefs = await SharedPreferences.getInstance();
        expect(await DeepSeekSettings.loadModelName(prefs), 'deepseek-flash');
        expect(prefs.getString('deepseek_model_name'), 'deepseek-flash');
        expect(await DeepSeekSettings.loadModelName(prefs), 'deepseek-flash');
      });
    }
    test('preserves third-party alias $old', () async {
      SharedPreferences.setMockInitialValues({
        'deepseek_model_name': old,
        'use_custom_deepseek_base_url': true,
        'deepseek_base_url': 'https://proxy.example/v1',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(await DeepSeekSettings.loadModelName(prefs), old);
      expect(prefs.getString('deepseek_model_name'), old);
    });
  }

  test('does not migrate a lookalike host', () async {
    SharedPreferences.setMockInitialValues({
      'deepseek_model_name': 'deepseek-chat',
      'use_custom_deepseek_base_url': true,
      'deepseek_base_url': 'https://api.deepseek.com.example/v1',
    });
    expect(
        await DeepSeekSettings.loadModelName(
            await SharedPreferences.getInstance()),
        'deepseek-chat');
  });

  test('an empty custom base URL falls back to the official API', () async {
    SharedPreferences.setMockInitialValues({
      'deepseek_model_name': 'deepseek-reasoner',
      'use_custom_deepseek_base_url': true,
      'deepseek_base_url': '',
    });
    expect(
        await DeepSeekSettings.loadModelName(
            await SharedPreferences.getInstance()),
        'deepseek-flash');
  });

  test('a disabled custom URL does not prevent official migration', () async {
    SharedPreferences.setMockInitialValues({
      'deepseek_model_name': 'deepseek-chat',
      'use_custom_deepseek_base_url': false,
      'deepseek_base_url': 'https://proxy.example/v1',
    });
    expect(
        await DeepSeekSettings.loadModelName(
            await SharedPreferences.getInstance()),
        'deepseek-flash');
  });

  for (final model in ['deepseek-flash', 'deepseek-v4-pro', 'custom-model']) {
    test('preserves explicitly selected model $model', () async {
      SharedPreferences.setMockInitialValues({'deepseek_model_name': model});
      final prefs = await SharedPreferences.getInstance();
      expect(await DeepSeekSettings.loadModelName(prefs), model);
      expect(prefs.getString('deepseek_model_name'), model);
    });
  }

  test('empty stored model uses the default', () async {
    SharedPreferences.setMockInitialValues({'deepseek_model_name': ''});
    expect(
        await DeepSeekSettings.loadModelName(
            await SharedPreferences.getInstance()),
        'deepseek-flash');
  });

  for (final savedModel in [null, 'deepseek-chat', 'deepseek-v4-pro']) {
    test('translation request disables thinking for saved model $savedModel',
        () async {
      SharedPreferences.setMockInitialValues({
        'deepseek_api_key': 'test',
        if (savedModel != null) 'deepseek_model_name': savedModel,
        'deepseek_temperature': 0.4,
      });
      var requests = 0;
      await http.runWithClient(() async {
        final provider = await DeepSeekTranslationProvider.instance;
        final stream = await provider.translateStream(
            text: 'Hello',
            sourceLangName: 'English',
            targetLangName: 'Chinese');
        expect(await stream.toList(), ['你好']);
      },
          () => MockClient((request) async {
                requests++;
                final body = jsonDecode(request.body);
                expect(body['thinking'], {'type': 'disabled'});
                expect(
                    body['model'],
                    savedModel == 'deepseek-v4-pro'
                        ? 'deepseek-v4-pro'
                        : 'deepseek-flash');
                expect(body['stream'], isTrue);
                expect(body['temperature'], 0.4);
                expect(body['messages'][1]['content'], contains('Hello'));
                return http.Response(
                    'data: {"choices":[{"delta":{"content":"你好"}}]}\n'
                    'data: [DONE]\n',
                    200,
                    headers: {
                      'content-type': 'text/event-stream; charset=utf-8'
                    });
              }));
      expect(requests, 1);
    });
  }
}
