import 'package:deadly/theme/accent_palette.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Proof that a chosen palette actually reaches what is drawn.
///
/// The contrast tests check the colours themselves and the settings test
/// checks they persist; neither would notice if the theme never reached a
/// widget. This closes that gap.
void main() {
  Widget host(AccentPalette palette, {required bool dark}) {
    final base = dark ? AppTheme.dark : AppTheme.light;
    return MaterialApp(
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        extensions: [base.withAccent(palette)],
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Container(
            key: const Key('swatch'),
            color: context.colors.accent,
            child: Text('x', style: TextStyle(color: context.colors.onAccent)),
          ),
        ),
      ),
    );
  }

  testWidgets('a widget paints the chosen accent', (tester) async {
    await tester.pumpWidget(host(AccentPalette.pink, dark: false));

    final box = tester.widget<Container>(find.byKey(const Key('swatch')));
    expect(box.color, AccentPalette.pink.accent);
  });

  testWidgets('switching palette repaints in the new colour', (tester) async {
    await tester.pumpWidget(host(AccentPalette.teal, dark: false));
    expect(
      tester.widget<Container>(find.byKey(const Key('swatch'))).color,
      AccentPalette.teal.accent,
    );

    await tester.pumpWidget(host(AccentPalette.orange, dark: false));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Container>(find.byKey(const Key('swatch'))).color,
      AccentPalette.orange.accent,
      reason: 'the choice has to reach the widget, not just the setting',
    );
  });

  testWidgets('dark mode uses the lighter variant', (tester) async {
    // The solid accent is too dark to read on a dark surface, so dark mode
    // swaps in the strong one.
    await tester.pumpWidget(host(AccentPalette.purple, dark: true));

    expect(
      tester.widget<Container>(find.byKey(const Key('swatch'))).color,
      AccentPalette.purple.accentStrong,
    );
  });

  testWidgets('every palette reaches the widget in both modes',
      (tester) async {
    for (final palette in AccentPalette.all) {
      for (final dark in [false, true]) {
        await tester.pumpWidget(host(palette, dark: dark));
        await tester.pumpAndSettle();

        final painted =
            tester.widget<Container>(find.byKey(const Key('swatch'))).color;
        expect(
          painted,
          dark ? palette.accentStrong : palette.accent,
          reason: '${palette.id} in ${dark ? "dark" : "light"} mode',
        );
      }
    }
  });
}
