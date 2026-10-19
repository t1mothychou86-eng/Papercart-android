// CN: Rule-based institutional access; never handles school credentials.
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const whuErspId = 'cn:whu-ersp';
const systemVpnId = 'cn:system-vpn';
const erspProxyDoiKey = 'cn_ersp_proxy_doi';

class AccessResult {
  final String url;
  final String? warning;
  const AccessResult(this.url, [this.warning]);
}

Uri? _webUri(String value) {
  try {
    final uri = Uri.parse(value);
    if (!['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        !RegExp(r'^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$').hasMatch(uri.host) ||
        uri.host
            .split('.')
            .any((part) => part.startsWith('-') || part.endsWith('-'))) {
      return null;
    }
    return uri;
  } on FormatException {
    return null;
  }
}

class InstitutionRule {
  final String host;
  final String pathPrefix;
  final String protocolMarker;
  final bool proxyDoi;
  const InstitutionRule({
    required this.host,
    this.pathPrefix = '/s/',
    this.protocolMarker = 'G.{scheme}',
    this.proxyDoi = true,
  });

  String original(String value) {
    final uri = _webUri(value);
    if (uri == null ||
        uri.host != host ||
        uri.port != 443 ||
        uri.scheme != 'https' ||
        !uri.path.startsWith(pathPrefix)) {
      return value;
    }
    final tail = uri.path.substring(pathPrefix.length);
    final parts = tail.split('/');
    final markerIndex = parts.indexWhere((part) => ['http', 'https'].any(
        (scheme) => part == protocolMarker.replaceAll('{scheme}', scheme)));
    if (markerIndex < 2) return value;
    final scheme = ['http', 'https'].firstWhere((scheme) =>
        parts[markerIndex] == protocolMarker.replaceAll('{scheme}', scheme));
    final hostname = parts.take(markerIndex).toList().reversed.join('.');
    final path = parts.skip(markerIndex + 1).join('/');
    final restored =
        '$scheme://$hostname${parts.length > markerIndex + 1 ? '/$path' : ''}'
        '${uri.hasQuery ? '?${uri.query}' : ''}${uri.hasFragment ? '#${uri.fragment}' : ''}';
    return _webUri(restored) == null ? value : restored;
  }

  AccessResult rewrite(String value) {
    final uri = _webUri(value);
    if (uri == null) return AccessResult(value, '网址无法按机构规则解析，已使用原网址。');
    if (uri.port != (uri.scheme == 'https' ? 443 : 80)) {
      return AccessResult(value, '机构规则尚不支持非默认端口，已使用原网址。');
    }
    // Includes login paths: never rewrite the gateway into itself.
    if (uri.host == host) return AccessResult(value);
    final reversed = uri.host.split('.').reversed.join('/');
    final marker = protocolMarker.replaceAll('{scheme}', uri.scheme);
    return AccessResult('https://$host$pathPrefix$reversed/$marker${uri.path}'
        '${uri.hasQuery ? '?${uri.query}' : ''}${uri.hasFragment ? '#${uri.fragment}' : ''}');
  }
}

const whuErspRule = InstitutionRule(host: 'ersp.lib.whu.edu.cn');
String originalArticleUrl(String value) => whuErspRule.original(value);
// Used at all three outbound boundaries, regardless of selected institution.
String articleUrlForExport(String value) => originalArticleUrl(value);

class InstitutionAccess {
  final String selection;
  final InstitutionRule rule;
  const InstitutionAccess(this.selection, {this.rule = whuErspRule});
  bool get isErsp => selection == whuErspId;
  bool get isDomestic => isErsp || selection == systemVpnId;

  static Future<InstitutionAccess> load() async {
    final prefs = await SharedPreferences.getInstance();
    return InstitutionAccess(prefs.getString('institution_url') ?? '',
        rule: InstitutionRule(
            host: whuErspRule.host,
            proxyDoi: prefs.getBool(erspProxyDoiKey) ?? true));
  }

  Future<AccessResult> open(String value, {http.Client? client}) async {
    if (!isDomestic) {
      return AccessResult(value); // Legacy EZproxy handled upstream.
    }
    final original = originalArticleUrl(value);
    if (!isErsp) return AccessResult(original);
    // Keep gateway login/resource URLs exactly as received.
    if (Uri.tryParse(value)?.host == rule.host) return rule.rewrite(value);
    final uri = _webUri(original);
    if (uri != null && uri.port != (uri.scheme == 'https' ? 443 : 80)) {
      return rule.rewrite(original);
    }
    if (!rule.proxyDoi &&
        uri != null &&
        ['doi.org', 'dx.doi.org'].contains(uri.host)) {
      final owned = client == null;
      final resolver = client ?? http.Client();
      try {
        final request = http.Request('HEAD', uri)..followRedirects = false;
        final response =
            await resolver.send(request).timeout(const Duration(seconds: 8));
        await response.stream.drain<void>().timeout(const Duration(seconds: 8));
        final location = response.headers['location'];
        final target =
            location == null ? null : _webUri(uri.resolve(location).toString());
        if ([301, 302, 303, 307, 308].contains(response.statusCode) &&
            target != null &&
            !['doi.org', 'dx.doi.org', rule.host].contains(target.host)) {
          return rule.rewrite(target.toString());
        }
      } catch (_) {
        // Failure is deliberately visible, without logging URLs or credentials.
      } finally {
        if (owned) resolver.close();
      }
      return AccessResult(original, 'DOI 出版商地址解析失败，已使用原 DOI 网址。');
    }
    return rule.rewrite(original);
  }
}
