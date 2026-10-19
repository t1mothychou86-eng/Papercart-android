// CN: Papercart fork notice; preserve the original author's About credit.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForkCredits extends StatelessWidget {
  const ForkCredits({super.key});

  static final upstream = Uri.parse('https://github.com/Scriptbash/Wispar');

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Papercart 是 Wispar（Scriptbash，GPL-3.0）的 fork。\n'
              'Based on Wispar by Scriptbash (GPL-3.0).'),
          TextButton.icon(
            onPressed: () =>
                launchUrl(upstream, mode: LaunchMode.platformDefault),
            icon: const Icon(Icons.favorite_outline),
            label: const Text('Wispar · Scriptbash · GPL-3.0'),
          ),
        ],
      );
}
