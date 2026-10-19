// CN: Offline domestic choices shared by onboarding and institutional settings.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'institution_access.dart';

class DomesticInstitutionChoices extends StatefulWidget {
  final void Function(String name, String value) onSelected;
  const DomesticInstitutionChoices({super.key, required this.onSelected});
  @override
  State<DomesticInstitutionChoices> createState() =>
      _DomesticInstitutionChoicesState();
}

class _DomesticInstitutionChoicesState
    extends State<DomesticInstitutionChoices> {
  bool proxyDoi = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => proxyDoi = prefs.getBool(erspProxyDoiKey) ?? true);
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
            title: const Text('武汉大学（图书馆 ERSP）'),
            subtitle: const Text('在内置浏览器中自行登录'),
            onTap: () => widget.onSelected('武汉大学（图书馆 ERSP）', whuErspId)),
        ListTile(
            title: const Text('系统 VPN（不改写，适用于 aTrust）'),
            subtitle: const Text('请先连接系统 VPN；与 ERSP 分开使用'),
            onTap: () =>
                widget.onSelected('系统 VPN（不改写，适用于 aTrust）', systemVpnId)),
        SwitchListTile(
            title: const Text('ERSP 直接打开 DOI'),
            subtitle: const Text('待真机验证；关闭后先解析一次出版商地址'),
            value: proxyDoi,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(erspProxyDoiKey, value);
              if (mounted) setState(() => proxyDoi = value);
            }),
        const Divider(),
      ]);
}
