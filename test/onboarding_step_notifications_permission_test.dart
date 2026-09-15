import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/onboarding/onboarding_step_notifications_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The step that asks for notification permission.
///
/// App Review (5.1.1(iv)) does not allow steering around a permission prompt,
/// so there is one neutral button and no skip beside it. Declining lands in
/// the refused state, which is what carries someone who says no onward.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool isEnabled,
    required bool isBusy,
    bool isDenied = false,
    VoidCallback? onEnable,
    VoidCallback? onNext,
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
          body: OnboardingStepNotificationsPermission(
            isEnabled: isEnabled,
            isBusy: isBusy,
            isDenied: isDenied,
            onEnableTap: () async => onEnable?.call(),
            onNext: onNext ?? () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('offers one neutral way forward', (tester) async {
    var taps = 0;
    await pump(tester,
        isEnabled: false, isBusy: false, onEnable: () => taps++);

    expect(
      find.text('Continue'),
      findsOneWidget,
      reason: 'a button naming the permission reads as steering toward it',
    );

    await tester.tap(find.text('Continue'));
    expect(taps, 1);
  });

  testWidgets('has no way around the permission prompt', (tester) async {
    await pump(tester, isEnabled: false, isBusy: false);

    // 5.1.1(iv): a skip beside the explanation delays the prompt, which is
    // what got an earlier build rejected. Declining happens in the prompt.
    expect(find.text('Maybe later'), findsNothing);
    expect(find.text('Skip'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('the button is inert while the prompt is open', (tester) async {
    var enables = 0;
    var advanced = false;
    await pump(
      tester,
      isEnabled: false,
      isBusy: true,
      onEnable: () => enables++,
      onNext: () => advanced = true,
    );

    expect(find.text('Enabling...'), findsOneWidget);

    await tester.tap(find.text('Enabling...'));
    await tester.pump();

    expect(enables, 0, reason: 'a second permission prompt must not open');
    expect(advanced, isFalse);
  });

  testWidgets('a refusal is explained and still moves on', (tester) async {
    var enables = 0;
    var advanced = false;
    await pump(
      tester,
      isEnabled: false,
      isBusy: false,
      isDenied: true,
      onEnable: () => enables++,
      onNext: () => advanced = true,
    );

    expect(find.textContaining('No notifications'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(advanced, isTrue, reason: 'a dead end would trap them here');
    expect(enables, 0, reason: 'iOS prompts once — pressing again does nothing');
  });

  testWidgets('confirms a grant and moves on', (tester) async {
    var advanced = false;
    await pump(
      tester,
      isEnabled: true,
      isBusy: false,
      onNext: () => advanced = true,
    );

    expect(find.text('Enabled'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(advanced, isTrue);
  });
}
