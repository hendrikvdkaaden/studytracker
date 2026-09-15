import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The streak badge is shown on two screens, so the rules about when it
/// appears live in one widget rather than being spelled out at each site.
///
/// The one that matters: it shows from day one. It used to appear only at two
/// days, which hid it from exactly the new users the streak is meant to hook.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int streak,
    double size = 18,
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [dark ? AppTheme.dark : AppTheme.light],
        ),
        home: Scaffold(
          body: Center(
            // Keyed by theme: re-pumping the same widget type otherwise reuses
            // the element, and a test that pumps light then dark reads the
            // light colour back both times.
            child: StreakBadge(
              key: ValueKey(dark),
              streak: streak,
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a single day is already shown', (tester) async {
    // The regression this widget exists for: the old threshold was >= 2.
    await pump(tester, streak: 1);

    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });

  testWidgets('a longer streak shows its count', (tester) async {
    await pump(tester, streak: 42);

    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('nothing is drawn at zero', (tester) async {
    // An empty box at zero would make the row it sits in jump as the streak
    // comes and goes.
    await pump(tester, streak: 0);

    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('a negative streak draws nothing either', (tester) async {
    // Should not be reachable, but a caller subtracting its way below zero
    // must not produce a flame with a minus sign.
    await pump(tester, streak: -3);

    expect(find.byIcon(Icons.local_fire_department), findsNothing);
  });

  testWidgets('the number follows the icon size', (tester) async {
    await pump(tester, streak: 5, size: 30);

    final icon = tester.widget<Icon>(
      find.byIcon(Icons.local_fire_department),
    );
    final text = tester.widget<Text>(find.text('5'));

    expect(icon.size, 30);
    expect(text.style?.fontSize, 27, reason: 'kept 3pt under the flame');
  });

  // Each theme is asserted against a literal in its own test rather than by
  // pumping light then dark and comparing. MaterialApp does not propagate a
  // changed `theme:` to descendants on a bare re-pump, so the sequential
  // version read the light colour back twice and passed for the wrong reason.
  // Literals also pin the actual shades instead of merely "they differ".
  testWidgets('light mode uses the darker flame', (tester) async {
    await pump(tester, streak: 3, dark: false);

    expect(
      tester.widget<Icon>(find.byIcon(Icons.local_fire_department)).color,
      Colors.orange.shade700,
    );
  });

  testWidgets('dark mode uses the lighter flame', (tester) async {
    // The emoji this replaced could not be tinted at all; following the theme
    // is the whole reason it became an icon.
    await pump(tester, streak: 3, dark: true);

    expect(
      tester.widget<Icon>(find.byIcon(Icons.local_fire_department)).color,
      Colors.orange.shade300,
    );
  });

  testWidgets('the icon and the number share one colour', (tester) async {
    await pump(tester, streak: 7);

    final icon = tester.widget<Icon>(
      find.byIcon(Icons.local_fire_department),
    );
    final text = tester.widget<Text>(find.text('7'));

    expect(text.style?.color, icon.color);
  });
}
