import 'dart:io';

import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/models/day_status.dart';
import 'package:deadly/models/goal.dart';
import 'package:deadly/product/templates/dashboard_template.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Finished deadlines pile up forever, so the section can be folded away.
/// What matters is that folding actually removes the cards and that the
/// section still says what is behind it.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('dash_completed');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Goal done(String title) => Goal(
        id: title,
        title: title,
        subject: 'Wiskunde',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: GoalType.exam,
        isCompleted: true,
        studyTime: 120,
      );

  Future<void> pump(
    WidgetTester tester, {
    required bool collapsed,
    VoidCallback? onToggle,
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
          body: DashboardTemplate(
            weeklyConsistency: const <int, DayStatus>{},
            missedSessionsCount: 0,
            studyStreak: 0,
            overdueGoals: const [],
            upcomingGoals: const [],
            completedGoals: [done('Verslag'), done('Toets')],
            goalsTimeSpent: const {},
            onGoalTap: (_) {},
            completedCollapsed: collapsed,
            onToggleCompleted: onToggle ?? () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the cards and offers to hide them', (tester) async {
    await pump(tester, collapsed: false);

    expect(find.text('Verslag'), findsOneWidget);
    expect(find.text('Toets'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);
  });

  testWidgets('folding removes the cards but keeps the section',
      (tester) async {
    await pump(tester, collapsed: true);

    expect(find.text('Verslag'), findsNothing);
    expect(find.text('Toets'), findsNothing);
    expect(find.text('Show'), findsOneWidget);
    expect(
      find.text('2 deadlines'),
      findsOneWidget,
      reason: 'a folded section must not read as an empty one',
    );
  });

  testWidgets('the button reports the toggle', (tester) async {
    var taps = 0;
    await pump(tester, collapsed: false, onToggle: () => taps++);

    await tester.tap(find.text('Hide'));
    expect(taps, 1);
  });

  testWidgets('other sections are unaffected', (tester) async {
    // Only completed folds; overdue and upcoming have no button.
    await pump(tester, collapsed: true);

    expect(find.text('Hide'), findsNothing);
    expect(find.text('Show'), findsOneWidget);
  });
}
