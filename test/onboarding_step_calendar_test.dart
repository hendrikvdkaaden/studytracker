import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/onboarding/onboarding_step_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The calendar step is the one place a new user can turn sync on.
///
/// App Review (5.1.1(iv)) does not allow steering around a permission prompt,
/// so there is one neutral button and no skip beside it. Declining lands in
/// the refused state, which is what finishes onboarding for someone who says
/// no.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool isConnected,
    required bool isBusy,
    bool isDenied = false,
    VoidCallback? onConnect,
    VoidCallback? onComplete,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        // The app supplies AppTheme through a ThemeData extension; without it
        // `context.colors` throws.
        theme: ThemeData(extensions: const [AppTheme.light]),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: OnboardingStepCalendar(
            isConnected: isConnected,
            isBusy: isBusy,
            isDenied: isDenied,
            onConnectTap: () async => onConnect?.call(),
            onComplete: () async => onComplete?.call(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('offers one neutral way forward', (tester) async {
    var taps = 0;
    await pump(tester,
        isConnected: false, isBusy: false, onConnect: () => taps++);

    expect(
      find.text('Continue'),
      findsOneWidget,
      reason: 'a button naming the permission reads as steering toward it',
    );

    await tester.tap(find.text('Continue'));
    expect(taps, 1);
  });

  testWidgets('declining in the prompt still finishes onboarding',
      (tester) async {
    // With the skip gone this is the only way past the step for someone who
    // says no, so a dead end here would trap them in onboarding.
    var completed = false;
    await pump(
      tester,
      isConnected: false,
      isBusy: false,
      isDenied: true,
      onComplete: () => completed = true,
    );

    await tester.ensureVisible(find.text("Let's go!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Let's go!"));
    await tester.pump();

    expect(completed, isTrue);
  });

  testWidgets('has no way around the permission prompt', (tester) async {
    await pump(tester, isConnected: false, isBusy: false);

    // 5.1.1(iv): a skip beside the explanation delays the prompt, which is
    // what got this rejected. Declining happens in the prompt itself.
    expect(find.text('Maybe later'), findsNothing);
    expect(find.text('Skip'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('the button is inert while the prompt is open', (tester) async {
    var connects = 0;
    var completed = false;
    await pump(
      tester,
      isConnected: false,
      isBusy: true,
      onConnect: () => connects++,
      onComplete: () => completed = true,
    );

    expect(find.text('Connecting...'), findsOneWidget);

    await tester.tap(find.text('Connecting...'));
    await tester.pump();

    expect(connects, 0, reason: 'a second permission prompt must not open');
    expect(completed, isFalse);
  });

  testWidgets('explains a refusal instead of offering a dead button',
      (tester) async {
    var connects = 0;
    var completed = false;
    await pump(
      tester,
      isConnected: false,
      isBusy: false,
      isDenied: true,
      onConnect: () => connects++,
      onComplete: () => completed = true,
    );

    expect(find.textContaining('No calendar access'), findsOneWidget);
    expect(find.text('Continue'), findsNothing,
        reason: 'iOS prompts once — a second press would do nothing');

    await tester.ensureVisible(find.text("Let's go!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Let's go!"));
    await tester.pump();
    expect(completed, isTrue);
    expect(connects, 0);
  });

  testWidgets('confirms the connection and offers the way out',
      (tester) async {
    var completed = false;
    await pump(
      tester,
      isConnected: true,
      isBusy: false,
      onComplete: () => completed = true,
    );

    expect(find.text('Connected'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Continue'), findsNothing,
        reason: 'connecting again would only re-prompt for nothing');

    await tester.ensureVisible(find.text("Let's go!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Let's go!"));
    await tester.pump();
    expect(completed, isTrue);
  });
}
