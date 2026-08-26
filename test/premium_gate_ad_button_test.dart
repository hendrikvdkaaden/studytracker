import 'dart:io';

import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/premium_gate_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// The ad button used to appear only once the ad had loaded, so anyone who
/// glanced at the sheet saw "Upgrade" alone and never learned the option was
/// there. It now shows from the start, disabled, in a loading state.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gate_ad');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> openSheet(WidgetTester tester, {required bool allowAd}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppTheme.light]),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showPremiumGateSheet(
                  context,
                  title: 'Deadline Limit Reached',
                  message: 'Limit reached.',
                  allowAdReward: allowAd,
                  adRewardLabel: 'Watch an ad for one more',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    // One frame: the sheet is up, the ad load has not resolved.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('offers the ad option before the ad has loaded', (tester) async {
    await openSheet(tester, allowAd: true);

    expect(
      find.text('Loading ad...'),
      findsOneWidget,
      reason: 'the option must be visible at a glance, not after a wait',
    );
  });

  testWidgets('the loading button cannot be pressed yet', (tester) async {
    await openSheet(tester, allowAd: true);

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));

    expect(
      button.onPressed,
      isNull,
      reason: 'pressing before the ad is ready would do nothing',
    );
  });

  testWidgets('the sheet opens without waiting on the ad', (tester) async {
    // Consent used to be settled before the sheet was shown, so a first-run
    // user could tap and watch nothing happen for as long as that took.
    await openSheet(tester, allowAd: true);

    expect(find.text('Deadline Limit Reached'), findsOneWidget);
  });

  testWidgets('no ad button at all when the gate does not allow one',
      (tester) async {
    await openSheet(tester, allowAd: false);

    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('Loading ad...'), findsNothing);
  });
}
