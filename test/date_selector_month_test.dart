import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/utils/format_helpers.dart';
import 'package:deadly/widgets/home/date_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scrolling the week strip several weeks out used to leave nothing on screen
/// saying which month you had reached.
void main() {
  Future<void> pump(WidgetTester tester, {required DateTime selected}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppTheme.light]),
        home: Scaffold(
          body: DateSelector(
            selectedDate: selected,
            onDateSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  DateTime mondayOf(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  testWidgets('names the month of the week on screen', (tester) async {
    final today = DateTime.now();
    await pump(tester, selected: today);

    final monday = mondayOf(today);
    final expected = FormatHelpers.formatWeekMonth(
      monday,
      monday.add(const Duration(days: 6)),
    );

    expect(find.text(expected), findsOneWidget);
  });

  testWidgets('the month follows the strip when it is scrolled',
      (tester) async {
    final today = DateTime.now();
    await pump(tester, selected: today);

    final monday = mondayOf(today);
    final thisWeek = FormatHelpers.formatWeekMonth(
      monday,
      monday.add(const Duration(days: 6)),
    );

    // Six weeks on is far enough to land in a different month whenever today
    // falls, so the heading has to have changed. fling rather than drag: a
    // drag of this distance does not reliably settle a full page over.
    for (var i = 0; i < 6; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
    }

    final laterMonday = monday.add(const Duration(days: 42));
    final laterWeek = FormatHelpers.formatWeekMonth(
      laterMonday,
      laterMonday.add(const Duration(days: 6)),
    );

    expect(find.text(laterWeek), findsOneWidget);
    expect(
      thisWeek == laterWeek || find.text(thisWeek).evaluate().isEmpty,
      isTrue,
      reason: 'the old heading must not still be on screen',
    );
  });
}
