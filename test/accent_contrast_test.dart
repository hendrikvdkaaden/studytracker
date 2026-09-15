import 'dart:math' as math;

import 'package:deadly/theme/accent_palette.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The user's one hard requirement for choosable colours was that everything
/// stays readable. This is what holds them to it: add a palette that is too
/// light and the suite goes red instead of the button going unreadable.
///
/// Ratios are WCAG 2.1 relative luminance. 4.5 is the threshold for normal
/// text, 3.0 for large text and UI elements.
void main() {
  double luminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  double contrast(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  const white = Color(0xFFFFFFFF);

  test('the contrast maths matches known values', () {
    // Black on white is the textbook maximum; a colour against itself is 1.
    expect(contrast(const Color(0xFF000000), white), closeTo(21, 0.01));
    expect(contrast(white, white), closeTo(1, 0.001));
  });

  group('every palette stays readable', () {
    for (final palette in AccentPalette.all) {
      test('${palette.id}: white text on the accent', () {
        expect(
          contrast(palette.accent, palette.onAccent),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id} is too light to carry white text',
        );
      });

      test('${palette.id}: the accent on a light background', () {
        // Measured against the tinted page the palette actually paints, not
        // the untinted default: each palette shifts its own background, and
        // checking the wrong one would miss a tint that drifts far enough to
        // swallow its accent.
        expect(
          contrast(
            palette.accent,
            AppTheme.light.withAccent(palette).background,
          ),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id} disappears into the light background',
        );
      });

      test('${palette.id}: normal accent text needs a light card', () {
        // Where accent-coloured text sits on a card at normal size -- the
        // session-progress label, the "Today" chip, the section count -- it
        // is only used in light mode. Dark mode resolves accent to the strong
        // mid-tone, which misses 4.5:1 there, so those widgets switch to the
        // normal ink instead. This pins the half that is actually shipped.
        expect(
          contrast(
            AppTheme.light.withAccent(palette).accent,
            AppTheme.light.card,
          ),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id} cannot carry normal text on a light card',
        );
      });

      test('${palette.id}: large accent text works on a light card', () {
        // The 72px timer readout is large text, so the bar is 3.0 rather
        // than 4.5.
        //
        // Light mode only. This used to cover both, on the premise that the
        // accent held in either mode; dark mode now reuses the light-mode
        // colour outright and lands at 2.67 or below, so that half of the
        // guarantee is gone by choice. See the exemption test below.
        expect(
          contrast(
            AppTheme.light.withAccent(palette).accent,
            AppTheme.light.card,
          ),
          greaterThanOrEqualTo(3.0),
          reason: '${palette.id} fails even large text on a light card',
        );
      });

      test('${palette.id}: dark mode draws the light-mode accent', () {
        // Not a contrast check. Dark mode deliberately reuses the exact
        // light-mode colour so one accent means one colour, which puts every
        // palette under the 3.0 a UI element would normally need (teal 2.67,
        // blue 2.18, green 2.92, purple 2.06, orange 2.82, pink 2.42).
        //
        // A threshold slid down to fit those numbers would assert nothing, so
        // this asserts the actual decision instead: the two are identical.
        // Change that and this fails, which is the point.
        expect(palette.accentStrong, palette.accent);
      });

      test('${palette.id}: is documented as dim on a dark card', () {
        // The readability requirement has not gone away, it has been traded
        // away here on purpose. This records the trade so nobody later reads
        // the missing check as an oversight: the accent is not legible as
        // foreground on a dark card, and text there uses textPrimary instead.
        expect(
          contrast(palette.accentStrong, AppTheme.dark.card),
          lessThan(3.0),
          reason: '${palette.id} unexpectedly clears 3.0 -- if the palette '
              'changed, revisit whether the exemption is still needed',
        );
      });

      test('${palette.id}: the soft tint carries the primary text', () {
        // accentSoft is a fill, and the text on it is the normal ink rather
        // than the accent -- which would fail for orange and green.
        expect(
          contrast(palette.accentSoft, AppTheme.light.textPrimary),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id} soft tint cannot carry text',
        );
      });
    }
  });

  group('palette lookup', () {
    test('returns each palette in stored order', () {
      for (var i = 0; i < AccentPalette.all.length; i++) {
        expect(AccentPalette.byId(i), AccentPalette.all[i]);
      }
    });

    test('an unknown index falls back rather than crashing', () {
      // A stored index from a build with more palettes must survive a
      // downgrade.
      expect(AccentPalette.byId(-1), AccentPalette.all.first);
      expect(AccentPalette.byId(99), AccentPalette.all.first);
    });

    test('the first palette is the one the app shipped with', () {
      expect(AccentPalette.byId(0).accent, AppTheme.light.accent);
    });
  });

  group('withAccent', () {
    test('light mode takes the solid accent', () {
      final themed = AppTheme.light.withAccent(AccentPalette.pink);

      expect(themed.accent, AccentPalette.pink.accent);
      expect(themed.onAccent, AccentPalette.pink.onAccent);
    });

    test('dark mode draws the light-mode accent unchanged', () {
      // This once swapped in a lighter variant and checked the ink on it
      // cleared 4.5. Both halves are gone: the variant is now the same colour,
      // and pink against the dark ink measures 2.42. Dark mode keeping the
      // exact light-mode colour is the deliberate replacement.
      final themed = AppTheme.dark.withAccent(AccentPalette.pink);

      expect(themed.accent, AccentPalette.pink.accent);
      // White, not the 0xFF0F172A this used to assert. That dark ink suited a
      // light mid-tone accent; on the solid light-mode accent it scores
      // 2.51-3.56 across the palettes where white scores 5.02-7.10, and it
      // showed up as black label text on the timer's Start button.
      expect(themed.onAccent, const Color(0xFFFFFFFF));
    });

    test('it leaves the card and the ink alone', () {
      // The background moves now (see the tint group), but cards must not:
      // keeping them flat is what stops the tint reaching the text on them.
      final themed = AppTheme.light.withAccent(AccentPalette.green);

      expect(themed.card, AppTheme.light.card);
      expect(themed.textPrimary, AppTheme.light.textPrimary);
      expect(themed.isDark, isFalse);
    });
  });

  group('the background tint', () {
    test('every palette tints the page differently', () {
      // A tint that silently computed to 0% would still pass every contrast
      // check below -- it is only caught by the backgrounds being distinct.
      for (final base in [AppTheme.light, AppTheme.dark]) {
        final seen = <Color>{};
        for (final p in AccentPalette.all) {
          final bg = base.withAccent(p).background;
          expect(bg, isNot(base.background),
              reason: '${p.id} left the page untinted');
          expect(seen.add(bg), isTrue, reason: '${p.id} duplicates another');
        }
      }
    });

    test('the tint is faint, not a coloured screen', () {
      // "Barely visible" was the requirement; a tint that drifts far from the
      // base is the failure this guards against.
      for (final p in AccentPalette.all) {
        expect(contrast(AppTheme.light.withAccent(p).background,
            AppTheme.light.background), lessThan(1.1),
            reason: '${p.id} tints the light page too strongly');
      }
    });

    test('text stays readable on every tinted page', () {
      // The standing guarantee of the readability requirement: a seventh
      // colour that tints too far turns this red instead of shipping.
      for (final base in [AppTheme.light, AppTheme.dark]) {
        for (final p in AccentPalette.all) {
          final t = base.withAccent(p);
          expect(contrast(t.textPrimary, t.background),
              greaterThanOrEqualTo(4.5),
              reason: 'primary text on ${p.id}');
          expect(contrast(t.textSecondary, t.background),
              greaterThanOrEqualTo(4.5),
              reason: 'secondary text on ${p.id}');
        }
      }
    });
  });
}
