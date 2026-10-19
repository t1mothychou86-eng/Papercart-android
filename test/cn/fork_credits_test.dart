// CN: The About credits must name and link the upstream project.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wispar/cn/fork_credits.dart';

void main() {
  testWidgets('About credits show fork, author, license and upstream link',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ForkCredits())),
    );
    expect(find.textContaining('Papercart 是 Wispar'), findsOneWidget);
    expect(find.text('Wispar · Scriptbash · GPL-3.0'), findsOneWidget);
    expect(ForkCredits.upstream.toString(),
        'https://github.com/Scriptbash/Wispar');
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNotNull);
  });
}
