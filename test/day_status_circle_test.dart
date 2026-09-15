import 'package:deadly/models/day_status.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/deadlines/cards/day_status_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The week circles say what happened on each day.
///
/// The one worth guarding is `frozen`: a day a streak freeze covered. It must
/// read as neither missed nor completed -- the first would contradict a streak
/// that visibly carried on, the second would claim study that never happened.
void main() {
  Future<void> pump(
    WidgetTester tester,
    DayStatus status, {
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [dark ? AppTheme.dark : AppTheme.light],
        ),
        home: Scaffold(
          body: Center(child: DayStatusCircle(status: status)),
        ),
      ),
    );
  }

  testWidgets('a frozen day shows a snowflake', (tester) async {
    await pump(tester, DayStatus.frozen);

    expect(find.byIcon(Icons.ac_unit), findsOneWidget);
  });

  testWidgets('a frozen day is not shown as missed', (tester) async {
    await pump(tester, DayStatus.frozen);

    expect(
      find.byIcon(Icons.close),
      findsNothing,
      reason: 'a red cross beside a surviving streak contradicts itself',
    );
  });

  testWidgets('a frozen day is not shown as completed', (tester) async {
    await pump(tester, DayStatus.frozen);

    expect(
      find.byIcon(Icons.check),
      findsNothing,
      reason: 'the day was not studied; a tick would be a lie',
    );
  });

  testWidgets('frozen is visually distinct from missed', (tester) async {
    await pump(tester, DayStatus.frozen);
    final frozen = tester.widget<Container>(find.byType(Container).first);

    await pump(tester, DayStatus.missed);
    final missed = tester.widget<Container>(find.byType(Container).first);

    expect(
      (frozen.decoration as BoxDecoration).color,
      isNot((missed.decoration as BoxDecoration).color),
    );
  });

  testWidgets('frozen renders in dark mode too', (tester) async {
    await pump(tester, DayStatus.frozen, dark: true);

    expect(find.byIcon(Icons.ac_unit), findsOneWidget);
  });

  group('the other states still behave', () {
    testWidgets('completed shows a tick', (tester) async {
      await pump(tester, DayStatus.completed);

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsNothing);
    });

    testWidgets('missed shows a cross', (tester) async {
      await pump(tester, DayStatus.missed);

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsNothing);
    });

    testWidgets('an unplanned day carries no mark', (tester) async {
      await pump(tester, DayStatus.notPlanned);

      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byIcon(Icons.ac_unit), findsNothing);
    });
  });
}
