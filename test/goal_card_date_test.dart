import 'dart:io';

import 'package:deadly/models/goal.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/utils/format_helpers.dart';
import 'package:deadly/widgets/deadlines/cards/completed_goal_card.dart';
import 'package:deadly/widgets/deadlines/cards/overdue_goal_card.dart';
import 'package:deadly/widgets/deadlines/cards/upcoming_goal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Every card on the dashboard names its deadline's date. A card that only
/// says "3d" leaves the user counting days in their head.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('card_date');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  final date = DateTime(2026, 9, 14);

  Goal goal() => Goal(
        id: 'g1',
        title: 'Verslag',
        subject: 'Wiskunde',
        date: date,
        type: GoalType.exam,
        studyTime: 300,
      );

  Future<void> pump(WidgetTester tester, Widget card) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppTheme.light]),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 310, child: card),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('overdue names the date', (tester) async {
    await pump(tester, OverdueGoalCard(goal: goal(), onTap: () {}));

    expect(find.text(FormatHelpers.formatDate(date)), findsOneWidget);
  });

  testWidgets('completed names the date', (tester) async {
    await pump(tester, CompletedGoalCard(goal: goal(), onTap: () {}));

    expect(find.text(FormatHelpers.formatDate(date)), findsOneWidget);
  });

  testWidgets('upcoming still names the date', (tester) async {
    await pump(
      tester,
      UpcomingGoalCard(goal: goal(), timeSpent: 60, onTap: () {}),
    );

    expect(find.text(FormatHelpers.formatDate(date)), findsOneWidget);
  });

  testWidgets('all three format it the same way', (tester) async {
    // Three cards showing the same deadline three different ways would be
    // worse than none of them showing it.
    final seen = <String>[];

    for (final card in [
      OverdueGoalCard(goal: goal(), onTap: () {}),
      CompletedGoalCard(goal: goal(), onTap: () {}),
      UpcomingGoalCard(goal: goal(), timeSpent: 60, onTap: () {}),
    ]) {
      await pump(tester, card);
      seen.add(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .firstWhere((s) => s == FormatHelpers.formatDate(date)),
      );
    }

    expect(seen.toSet().length, 1);
  });
}
