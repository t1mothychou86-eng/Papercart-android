// CN: Domestic choices and persistence work without a remote institution list.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wispar/cn/institution_access.dart';
import 'package:wispar/cn/institution_choices.dart';

void main() {
  testWidgets('domestic choices return identifiers and DOI switch persists',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final selections = <String>[];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DomesticInstitutionChoices(
                onSelected: (name, id) => selections.add(id)))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('武汉大学（图书馆 ERSP）'));
    await tester.tap(find.text('系统 VPN（不改写，适用于 aTrust）'));
    expect(selections, [whuErspId, systemVpnId]);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect((await InstitutionAccess.load()).rule.proxyDoi, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DomesticInstitutionChoices(onSelected: (name, id) {}))));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });
}
