// CN: Offline A4 rule and DOI tests; no real ERSP/DOI requests.
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wispar/cn/institution_access.dart';
import 'package:wispar/services/zotero_api.dart';
import 'package:wispar/models/zotero_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const samples = {
    'https://www.sciencedirect.com/journal/journal-of-financial-economics/issues':
        'https://ersp.lib.whu.edu.cn/s/com/sciencedirect/www/G.https/journal/journal-of-financial-economics/issues',
    'https://academic.oup.com/rfs':
        'https://ersp.lib.whu.edu.cn/s/com/oup/academic/G.https/rfs',
    'https://onlinelibrary.wiley.com/doi/pdf/10.1/test?download=true&x=a%2Fb#page=2':
        'https://ersp.lib.whu.edu.cn/s/com/wiley/onlinelibrary/G.https/doi/pdf/10.1/test?download=true&x=a%2Fb#page=2',
    'http://www.example.com/a%2Fb?q=%E4%B8%AD&x=1&x=2#part':
        'https://ersp.lib.whu.edu.cn/s/com/example/www/G.http/a%2Fb?q=%E4%B8%AD&x=1&x=2#part',
    'https://www.journals.uchicago.edu/doi/pdf/10.1/a':
        'https://ersp.lib.whu.edu.cn/s/edu/uchicago/journals/www/G.https/doi/pdf/10.1/a',
    'https://www.aeaweb.org/articles?id=10.1%2Fa':
        'https://ersp.lib.whu.edu.cn/s/org/aeaweb/www/G.https/articles?id=10.1%2Fa',
    'https://example.com': 'https://ersp.lib.whu.edu.cn/s/com/example/G.https',
  };
  for (final sample in samples.entries) {
    test('rewrite, restore and idempotence: ${sample.key}', () {
      final result = whuErspRule.rewrite(sample.key);
      expect(result.warning, isNull);
      expect(result.url, sample.value);
      expect(whuErspRule.original(result.url), sample.key);
      expect(whuErspRule.rewrite(result.url).url, sample.value);
      expect(articleUrlForExport(result.url), sample.key);
    });
  }
  for (final raw in [
    'https://example.com:8443/a',
    'https://ersp.lib.whu.edu.cn:8443/login',
    'http://example.com:8080/a',
    'not a url',
    '/relative',
    'mailto:test@example.com',
    'https://user:password@example.com/a',
    'https://[::1]/a',
    'https://bad..host/a'
  ]) {
    test('unsupported URL stays original with warning: $raw', () {
      final result = whuErspRule.rewrite(raw);
      expect(result.url, raw);
      expect(result.warning, isNotNull);
    });
  }
  test('explicit default ports work', () {
    expect(whuErspRule.rewrite('https://example.com:443/a').url,
        'https://ersp.lib.whu.edu.cn/s/com/example/G.https/a');
    expect(whuErspRule.rewrite('http://example.com:80/a').url,
        'https://ersp.lib.whu.edu.cn/s/com/example/G.http/a');
  });
  test('login and malformed gateway paths never get rewritten or decoded', () {
    for (final raw in [
      'https://ersp.lib.whu.edu.cn/login?next=x',
      'https://ersp.lib.whu.edu.cn/s/com/G.https/a',
      'https://ersp.lib.whu.edu.cn/s/com/example/G.ftp/a',
      'https://ersp.lib.whu.edu.cn.evil.test/s/com/example/G.https/a'
    ]) {
      expect(originalArticleUrl(raw), raw);
    }
    expect(whuErspRule.rewrite('https://ersp.lib.whu.edu.cn/login').url,
        'https://ersp.lib.whu.edu.cn/login');
  });
  test('rule host, prefix and protocol marker are configurable', () {
    const rule = InstitutionRule(
        host: 'gateway.example.edu',
        pathPrefix: '/resource/',
        protocolMarker: 'P.{scheme}');
    final result = rule.rewrite('http://www.example.com/a?q=1');
    expect(result.url,
        'https://gateway.example.edu/resource/com/example/www/P.http/a?q=1');
    expect(rule.original(result.url), 'http://www.example.com/a?q=1');
  });
  test('system VPN unwraps ERSP; legacy EZproxy is untouched', () async {
    const vpn = InstitutionAccess(systemVpnId);
    const legacy = InstitutionAccess('https://proxy.example.edu/login?url=');
    expect((await vpn.open(samples.values.first)).url, samples.keys.first);
    expect((await vpn.open(samples.keys.first)).url, samples.keys.first);
    expect((await legacy.open(samples.keys.first)).url, samples.keys.first);
    expect(legacy.isDomestic, isFalse);
  });
  test('persisted selections and DOI policy reload without migration',
      () async {
    for (final id in [
      whuErspId,
      systemVpnId,
      'https://ezproxy.example.edu/?url='
    ]) {
      SharedPreferences.setMockInitialValues(
          {'institution_url': id, erspProxyDoiKey: false});
      final loaded = await InstitutionAccess.load();
      expect(loaded.selection, id);
      expect(loaded.rule.proxyDoi, isFalse);
    }
    SharedPreferences.setMockInitialValues({});
    expect((await InstitutionAccess.load()).rule.proxyDoi, isTrue);
  });
  test('default DOI assumption rewrites without a resolver request', () async {
    final client =
        MockClient((_) => throw StateError('must not request network'));
    expect(
        (await const InstitutionAccess(whuErspId)
                .open('https://doi.org/10.1/a', client: client))
            .url,
        'https://ersp.lib.whu.edu.cn/s/org/doi/G.https/10.1/a');
  });
  const resolveAccess = InstitutionAccess(whuErspId,
      rule: InstitutionRule(host: 'ersp.lib.whu.edu.cn', proxyDoi: false));
  test('DOI fallback requests exactly one HEAD, never the publisher or PDF',
      () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      expect(request.method, 'HEAD');
      expect(request.url.host, 'doi.org');
      expect(request.followRedirects, isFalse);
      return http.Response('', 302,
          headers: {'location': 'https://academic.oup.com/rfs?a=1'});
    });
    final result =
        await resolveAccess.open('https://doi.org/10.1/a', client: client);
    expect(result.url,
        'https://ersp.lib.whu.edu.cn/s/com/oup/academic/G.https/rfs?a=1');
    expect(requests, 1);
  });
  for (final location in [
    null,
    '/10.1/other',
    'javascript:alert(1)',
    'https://user:secret@example.com/a'
  ]) {
    test('unusable DOI Location falls back visibly: $location', () async {
      final client = MockClient((_) async => http.Response('', 302,
          headers: {if (location != null) 'location': location}));
      final result =
          await resolveAccess.open('https://doi.org/10.1/a', client: client);
      expect(result.url, 'https://doi.org/10.1/a');
      expect(result.warning, isNotNull);
    });
  }
  test('DOI network failure uses original URL', () async {
    final client =
        MockClient((_) async => throw http.ClientException('offline'));
    final result =
        await resolveAccess.open('https://dx.doi.org/10.1/a', client: client);
    expect(result.url, 'https://dx.doi.org/10.1/a');
    expect(result.warning, isNotNull);
  });
  test('DOI with non-default port does not send a resolver request', () async {
    final client =
        MockClient((_) => throw StateError('must not request network'));
    final result =
        await resolveAccess.open('https://doi.org:8443/10.1/a', client: client);
    expect(result.url, 'https://doi.org:8443/10.1/a');
    expect(result.warning, isNotNull);
  });
  test('actual Zotero HTTP payload restores URL without mutating input',
      () async {
    final input = {
      'data': {'url': samples.values.first, 'title': 'A4'}
    };
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      final data = (jsonDecode(request.body) as List).single['data'];
      expect(data['url'], samples.keys.first);
      expect(request.body, isNot(contains('ersp.lib.whu.edu.cn')));
      return http.Response('{}', 200);
    });
    expect(
        await ZoteroService.createZoteroItem(
            'test-token',
            'test-user',
            ZoteroCollection(key: 'test', name: 'test', isGroupLibrary: false),
            input,
            client: client),
        isTrue);
    expect(input['data']!['url'], samples.values.first);
  });
}
