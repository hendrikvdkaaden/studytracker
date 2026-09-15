import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/onboarding/onboarding_progress_indicator.dart';
import 'package:deadly/widgets/onboarding/onboarding_step_notifications.dart';
import 'package:deadly/widgets/onboarding/onboarding_step_notifications_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adding the notification step made the flow five steps. The count lives in
/// a default that no call site overrides, so it is easy to add a step and
/// leave the counter saying four.
void main() {
  Future<void> pump(WidgetTester tester, int step) async {
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
        home: Scaffold(body: OnboardingProgressIndicator(step: step)),
      ),
    );
    await tester.pump();
  }

  testWidgets('counts out of five', (tester) async {
    await pump(tester, 4);

    expect(find.text('Step 4 of 5'), findsOneWidget);
  });

  testWidgets('draws one bar per step', (tester) async {
    await pump(tester, 1);

    final bars = find.descendant(
      of: find.byType(Row),
      matching: find.byType(Container),
    );

    expect(tester.widgetList(bars).length, 5);
  });

  testWidgets('the calendar step is the last one', (tester) async {
    await pump(tester, 5);

    expect(find.text('Step 5 of 5'), findsOneWidget);
  });

  _orderTests();
}

/// Which widget carries which step number.
///
/// The counter tests above drive OnboardingProgressIndicator directly with a
/// literal step, so they pass no matter which screen shows which number.
/// These pin the order the user actually walks through: permission is asked
/// before the offsets, because how early to be reminded is a meaningless
/// question until it is settled whether reminders arrive at all.
void _orderTests() {
  testWidgets('permission is asked before the reminder offsets',
      (tester) async {
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
        home: Scaffold(
          body: OnboardingStepNotificationsPermission(
            isEnabled: false,
            isBusy: false,
            isDenied: false,
            onEnableTap: () async {},
            onNext: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Step 3 of 5'), findsOneWidget);
  });

  testWidgets('the reminder offsets come after it', (tester) async {
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
        home: Scaffold(
          body: OnboardingStepNotifications(
            sessionReminderMinutes: 15,
            deadlineReminderDays: 1,
            onNext: () {},
            onSessionReminderTap: () async {},
            onDeadlineReminderTap: () async {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Step 4 of 5'), findsOneWidget);
  });
}
