// CN: Exercise real card copy/share actions with an already rewritten article.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wispar/generated_l10n/app_localizations.dart';
import 'package:wispar/models/crossref_journals_works_models.dart';
import 'package:wispar/widgets/publication_card/publication_card.dart';

// Skip the unrelated favorite database lookup; retain real UI and export actions.
class _ArticleCard extends PublicationCard {
  _ArticleCard()
      : super(
            title: 'A4 article',
            abstract: 'Abstract',
            journalTitle: 'Journal',
            issn: const ['1234-5678'],
            doi: '10.1/a',
            authors: [PublicationAuthor(given: 'Test', family: 'Author')],
            url:
                'https://ersp.lib.whu.edu.cn/s/com/oup/academic/G.https/rfs?x=1',
            license: '',
            licenseName: '',
            showFavoriteButton: false);
  @override
  PublicationCardState createState() => _ArticleCardState();
}

class _ArticleCardState extends PublicationCardState {
  @override
  void checkIfLiked() {}
}

void main() {
  testWidgets('copy and share use original article URL with no gateway',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    String? copied;
    String? shared;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(shareChannel,
        (call) async {
      shared = (call.arguments as Map)['text'] as String?;
      return 'test';
    });
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(shareChannel, null);
    });
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: _ArticleCard())));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(_ArticleCard));
    final strings = AppLocalizations.of(context)!;
    await tester.tap(find.byType(PopupMenuButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.copy));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.copyUrl));
    await tester.pumpAndSettle();
    expect(copied, 'https://academic.oup.com/rfs?x=1');
    await tester.tap(find.byType(PopupMenuButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.shareArticle));
    await tester.pumpAndSettle();
    expect(shared, contains('https://academic.oup.com/rfs?x=1'));
    expect(shared, isNot(contains('ersp.lib.whu.edu.cn')));
  });
}
