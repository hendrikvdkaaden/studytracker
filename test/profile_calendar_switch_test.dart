import 'dart:io';

import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/product/templates/profile_template.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/app_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// The calendar settings read as plainly on or off, so they are switches
/// rather than rows with a value and a chevron.
///
/// Both the switch and the row report to the same handler, which is what runs
/// the confirmation before anything is enabled or a calendar is deleted.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('profile_cal_switch');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pump(
    WidgetTester tester, {
    required bool syncEnabled,
    bool notificationsEnabled = false,
    VoidCallback? onNotificationsTap,
    bool planAround = false,
    bool premium = true,
    VoidCallback? onSyncTap,
    VoidCallback? onPlanTap,
    VoidCallback? onEditName,
  }) async {
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
          body: ProfileTemplate(
            userName: 'Hendrik',
            notificationsEnabled: notificationsEnabled,
            notificationsBusy: false,
            onNotificationsTap: onNotificationsTap ?? () {},
            sessionReminderMinutes: 15,
            deadlineReminderDays: 1,
            themeModeIndex: 0,
            subjects: const [],
            schoolName: 'Hogeschool Utrecht',
            isPremium: premium,
            showPrivacyOptions: false,
            calendarSyncEnabled: syncEnabled,
            planAroundCalendar: planAround,
            onPlanAroundCalendarTap: onPlanTap ?? () {},
            calendarSyncBusy: false,
            onCalendarSyncTap: onSyncTap ?? () {},
            onPrivacyOptions: () {},
            onSubscriptionTap: () {},
            onEditName: onEditName ?? () {},
            onSessionReminderTap: () {},
            onDeadlineReminderTap: () {},
            onThemeTap: () {},
            onDeleteSessions: () {},
            onDeleteEverything: () {},
            onAddSubject: () {},
            onDeleteSubject: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder switchIn(String label) => find.descendant(
        of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
        matching: find.byType(AppSwitch),
      );

  bool switchValue(WidgetTester tester, String label) =>
      tester.widget<AppSwitch>(switchIn(label)).value;

  testWidgets('reminders is a switch reflecting its state', (tester) async {
    await pump(tester, syncEnabled: false, notificationsEnabled: true);

    expect(switchValue(tester, 'Reminders'), isTrue);
  });

  testWidgets('flipping reminders runs the same handler as the row',
      (tester) async {
    // The handler shows the confirmation, so the switch must not bypass it by
    // writing the setting itself.
    var taps = 0;
    await pump(tester, syncEnabled: false, onNotificationsTap: () => taps++);

    await tester.tap(switchIn('Reminders'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('the reminder timings are hidden while reminders are off',
      (tester) async {
    await pump(tester, syncEnabled: false, notificationsEnabled: false);

    expect(
      find.text('Session reminder'),
      findsNothing,
      reason: 'they configure reminders that cannot fire',
    );
    expect(find.text('Deadline reminder'), findsNothing);
  });

  testWidgets('the reminder timings appear once reminders are on',
      (tester) async {
    await pump(tester, syncEnabled: false, notificationsEnabled: true);

    expect(find.text('Session reminder'), findsOneWidget);
    expect(find.text('Deadline reminder'), findsOneWidget);
  });

  testWidgets('calendar sync is a switch reflecting its state',
      (tester) async {
    await pump(tester, syncEnabled: true);

    expect(switchValue(tester, 'Sync to calendar'), isTrue);
  });

  testWidgets('flipping the switch runs the same handler as the row',
      (tester) async {
    // The handler is what shows the confirmation, so the switch must not
    // bypass it by changing the setting itself.
    var taps = 0;
    await pump(tester, syncEnabled: false, onSyncTap: () => taps++);

    await tester.tap(switchIn('Sync to calendar'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('planning around appointments is hidden while sync is off',
      (tester) async {
    await pump(tester, syncEnabled: false);

    expect(
      find.text('Plan around appointments'),
      findsNothing,
      reason: 'without access there is nothing to plan around',
    );
  });

  testWidgets('tapping the school name edits the profile', (tester) async {
    // The pencil is a small target next to a full-width row, so the name
    // under it opens the same editor. It lost its GestureDetector once.
    var taps = 0;
    await pump(tester, syncEnabled: false, onEditName: () => taps++);

    await tester.tap(find.text('Hogeschool Utrecht'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('planning around appointments appears once sync is on',
      (tester) async {
    var taps = 0;
    await pump(
      tester,
      syncEnabled: true,
      planAround: true,
      onPlanTap: () => taps++,
    );

    expect(find.text('Plan around appointments'), findsOneWidget);

    // It sits below the fold in the test viewport.
    await tester.ensureVisible(switchIn('Plan around appointments'));
    await tester.pumpAndSettle();
    await tester.tap(switchIn('Plan around appointments'));
    await tester.pump();

    expect(taps, 1);
  });
}
