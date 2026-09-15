import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/models/day_status.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/deadlines/cards/study_consistency_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The card falls back to "plan some sessions" when the week holds nothing to
/// report. A frozen day is something to report: the session was planned, it
/// was missed, and a token covered it. Counting it as nothing printed the
/// empty state directly above the snowflakes that contradicted it.
void main() {
  Future<void> pump(WidgetTester tester, Map<int, DayStatus> week) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppTheme.light]),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StudyConsistencyCard(
            weeklyConsistency: week,
            missedSessionsCount: 0,
            studyStreak: 3,
          ),
        ),
      ),
    );
  }

  testWidgets('a week rescued entirely by freezes is not empty',
      (tester) async {
    await pump(tester, {1: DayStatus.frozen, 2: DayStatus.frozen});

    expect(find.text('Start Your Week Strong'), findsNothing);
  });

  testWidgets('a frozen day counts alongside real ones', (tester) async {
    await pump(tester, {
      1: DayStatus.completed,
      2: DayStatus.frozen,
      3: DayStatus.missed,
    });

    expect(find.text('Start Your Week Strong'), findsNothing);
  });

  testWidgets('a week with nothing planned still shows the empty state',
      (tester) async {
    // The guard the fix must not remove: notPlanned and pastNoSession are
    // genuinely nothing to report.
    await pump(tester, {
      1: DayStatus.notPlanned,
      2: DayStatus.pastNoSession,
    });

    expect(find.text('Start Your Week Strong'), findsOneWidget);
  });
}
