import 'package:deadly/models/study_session.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/planned_session_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A finished session has to read as finished wherever it appears.
///
/// The goal-details list dimmed the whole row to 75% opacity but left the
/// title in full primary ink with no strikethrough, while the home screen
/// struck it through and muted it. The same session looked different depending
/// on which list you opened it from.
void main() {
  StudySession session({required bool completed}) => StudySession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 9, 14),
        duration: 60,
        startTime: DateTime(2026, 9, 14, 14),
        isCompleted: completed,
        completedAt:
            completed ? DateTime(2026, 9, 14, 15) : null,
      );

  Future<void> pump(
    WidgetTester tester, {
    required bool completed,
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [dark ? AppTheme.dark : AppTheme.light],
        ),
        home: Scaffold(
          body: PlannedSessionItem(
            session: session(completed: completed),
            index: 0,
            title: 'Chapter 7',
          ),
        ),
      ),
    );
    await tester.pump();
  }

  TextStyle titleStyle(WidgetTester tester) =>
      tester.widget<Text>(find.text('Chapter 7')).style!;

  testWidgets('a completed session is struck through', (tester) async {
    await pump(tester, completed: true);

    expect(titleStyle(tester).decoration, TextDecoration.lineThrough);
  });

  testWidgets('an unfinished session is not', (tester) async {
    await pump(tester, completed: false);

    expect(titleStyle(tester).decoration, isNot(TextDecoration.lineThrough));
  });

  testWidgets('a completed title is muted, not full primary ink',
      (tester) async {
    await pump(tester, completed: true);

    expect(titleStyle(tester).color, AppTheme.light.textTertiary);
    expect(
      titleStyle(tester).color,
      isNot(AppTheme.light.textPrimary),
      reason: 'primary ink makes a done session read as still outstanding',
    );
  });

  testWidgets('an unfinished title keeps primary ink', (tester) async {
    await pump(tester, completed: false);

    expect(titleStyle(tester).color, AppTheme.light.textPrimary);
  });

  testWidgets('the strike follows the theme in dark mode', (tester) async {
    await pump(tester, completed: true, dark: true);

    expect(titleStyle(tester).decoration, TextDecoration.lineThrough);
    expect(titleStyle(tester).color, AppTheme.dark.textTertiary);
  });
}
