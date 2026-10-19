// CN: Verify Android branding and every generated locale without plugins.
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wispar/generated_l10n/app_localizations.dart';

void main() {
  test('every supported locale welcomes users to Papercart', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = await AppLocalizations.delegate.load(locale);
      expect(strings.welcomeWispar, contains('Papercart'), reason: '$locale');
      expect(strings.sharedMessage, contains('Papercart'), reason: '$locale');
    }
  });

  test('Android package, launcher and native activity agree', () {
    const package = 'io.github.t1mothychou86.papercart';
    final gradle = File('android/app/build.gradle').readAsStringSync();
    expect(gradle, contains('namespace "$package"'));
    expect(gradle, contains('applicationId "$package"'));
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:label="Papercart"'));
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    final activity = File('android/app/src/main/kotlin/'
            'io/github/t1mothychou86/papercart/MainActivity.kt')
        .readAsStringSync();
    expect(activity, contains('package $package'));
    expect(activity, contains('papercart_channel'));
    expect(
        File('android/app/src/main/kotlin/app/wispar/wispar/'
                'MainActivity.kt')
            .existsSync(),
        isFalse);
  });

  test('Papercart icon decodes and differs from upstream artwork', () async {
    final icon = File('assets/cn/papercart.png').readAsBytesSync();
    final codec = await instantiateImageCodec(icon);
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 512);
    expect(frame.image.height, 512);
    expect(icon, isNot(File('assets/icon/icon.png').readAsBytesSync()));
    frame.image.dispose();
    codec.dispose();
  });
}
