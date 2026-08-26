import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/onboarding/onboarding_step_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The calendar step is the one place a new user can turn sync on. Connecting
/// has to read as the offer, and skipping has to stay possible — these check
/// both, plus that neither button fires twice while the prompt is open.
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

  testWidgets('leads with connecting as the primary action', (tester) async {
    var taps = 0;
    await pump(tester,
        isConnected: false, isBusy: false, onConnect: () => taps++);

    expect(find.text('Connect calendar'), findsOneWidget);
    expect(find.text('Maybe later'), findsOneWidget);

    await tester.tap(find.text('Connect calendar'));
    expect(taps, 1);
  });

  testWidgets('skipping finishes onboarding without connecting',
      (tester) async {
    var connects = 0;
    var completed = false;
    await pump(
      tester,
      isConnected: false,
      isBusy: false,
      onConnect: () => connects++,
      onComplete: () => completed = true,
    );

    await tester.tap(find.text('Maybe later'));
    await tester.pump();

    expect(completed, isTrue);
    expect(connects, 0);
  });

  testWidgets('both buttons are inert while the prompt is open',
      (tester) async {
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
    await tester.tap(find.text('Maybe later'));
    await tester.pump();

    expect(connects, 0, reason: 'a second permission prompt must not open');
    expect(completed, isFalse,
        reason: 'leaving mid-prompt would strand the request');
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
    expect(find.text('Connect calendar'), findsNothing,
        reason: 'iOS prompts once — a second press would do nothing');

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
    expect(find.text('Connect calendar'), findsNothing,
        reason: 'connecting again would only re-prompt for nothing');

    await tester.tap(find.text("Let's go!"));
    await tester.pump();
    expect(completed, isTrue);
  });
}
