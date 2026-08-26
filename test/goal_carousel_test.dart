import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/deadlines/goal_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dashboard lays each section out sideways so a pile of deadlines cannot
/// push the sections below it off the screen. What matters is that the row
/// scrolls rather than overflowing, and that cards keep a fixed width.
void main() {
  Widget host(List<Widget> cards) => MaterialApp(
        theme: ThemeData(extensions: const [AppTheme.light]),
        home: Scaffold(body: GoalCarousel(cards: cards)),
      );

  Widget stubCard(String label) => Container(
        color: const Color(0xFFEEEEEE),
        padding: const EdgeInsets.all(14),
        child: Text(label),
      );

  testWidgets('lays cards out side by side at a fixed width', (tester) async {
    await tester.pumpWidget(host([stubCard('A'), stubCard('B')]));

    final a = tester.getRect(find.text('A'));
    final b = tester.getRect(find.text('B'));

    expect(b.left, greaterThan(a.left), reason: 'B sits beside A, not below');
    expect(a.top, b.top, reason: 'cards share a baseline');
  });

  testWidgets('scrolls instead of overflowing when there are many',
      (tester) async {
    // Twelve cards at 280pt each is far wider than any phone.
    await tester.pumpWidget(
      host([for (var i = 0; i < 12; i++) stubCard('card $i')]),
    );

    // An overflow would have thrown by now.
    expect(tester.takeException(), isNull);

    final before = tester.getRect(find.text('card 0')).left;
    await tester.drag(find.byType(GoalCarousel), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.text('card 0')).left,
      lessThan(before),
      reason: 'dragging sideways moves the row',
    );
  });

  testWidgets('a single card still renders', (tester) async {
    await tester.pumpWidget(host([stubCard('only')]));

    expect(find.text('only'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stretches cards to a shared height', (tester) async {
    // Cards in a section carry different amounts of text; a row of ragged
    // heights looks broken, so they stretch to the tallest.
    await tester.pumpWidget(
      host([
        stubCard('short'),
        Container(
          color: const Color(0xFFEEEEEE),
          padding: const EdgeInsets.all(14),
          child: const Text('much\nmore\ntext\nhere'),
        ),
      ]),
    );

    final heights = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .where((b) => b.width == GoalCarousel.cardWidth)
        .map((b) => tester.getSize(find.byWidget(b)).height)
        .toSet();

    expect(heights.length, 1, reason: 'both cards end up the same height');
  });
}
