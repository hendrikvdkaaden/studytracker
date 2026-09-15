import 'package:flutter/material.dart';

/// One choosable accent colour, in the three roles the app needs.
///
/// Every value here is contrast-checked against the surfaces it lands on, and
/// `test/accent_contrast_test.dart` fails the build if a palette drops below
/// the readable threshold. Add a colour there before adding one here.
@immutable
class AccentPalette {
  /// Solid fill behind white text, and the foreground colour on light
  /// surfaces. Must clear 4.5:1 against white.
  final Color accent;

  /// Foreground on dark surfaces. Deliberately identical to [accent].
  ///
  /// Dark mode draws the exact light-mode colour, by explicit choice: one
  /// accent means one colour, and any lighter shade reads as a different,
  /// washed-out one.
  ///
  /// The cost, measured against the dark card (0xFF1E293B): teal 2.67, blue
  /// 2.18, green 2.92, purple 2.06, orange 2.82, pink 2.42 -- all under the
  /// 3.0 a UI element normally needs. Where the accent is drawn as foreground
  /// on a dark card (calendar day cells, the timer, progress circles,
  /// onboarding icons) it is correspondingly dim. Accent-coloured *text* on a
  /// dark card is therefore off the table; that ink is textPrimary.
  final Color accentStrong;

  /// Pale fill for chips and tints, light mode only.
  ///
  /// Fill only -- never put accent-coloured text on it. Orange manages just
  /// 3.83 and green 4.14 that way, both unreadable.
  final Color accentSoft;

  /// Text and icons drawn on top of [accent].
  final Color onAccent;

  /// The page background, faintly tinted toward this accent.
  ///
  /// Stored outright rather than mixed at runtime: a literal value is what
  /// the contrast test can check, and it keeps the tint from drifting if the
  /// base background ever changes.
  ///
  /// Light is 2% toward [accent], dark 6% toward [accentStrong] -- dark
  /// surfaces swallow more tint before it reads as a colour. Cards do not
  /// follow this; only the page beneath them does.
  final Color backgroundTint;

  /// The dark-mode counterpart of [backgroundTint].
  final Color backgroundTintDark;

  final String id;

  const AccentPalette({
    required this.id,
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.backgroundTint,
    required this.backgroundTintDark,
    this.onAccent = const Color(0xFFFFFFFF),
  });

  static const AccentPalette teal = AccentPalette(
    id: 'teal',
    accent: Color(0xFF0F766E),
    // The shade the app shipped on, not the tone-300 the other palettes use.
    // Those are lightened because tone-500 fails on a dark card (blue 3.98,
    // purple 3.45, pink 4.15); teal clears it at 5.88 and needs no such help,
    // and lightening it anyway visibly changed the colour in dark mode.
    accentStrong: Color(0xFF0F766E),
    accentSoft: Color(0xFF99F6E4),
    backgroundTint: Color(0xFFF4F6FC),
    backgroundTintDark: Color(0xFF0F1D2E),
  );

  static const AccentPalette blue = AccentPalette(
    id: 'blue',
    accent: Color(0xFF1D4ED8),
    accentStrong: Color(0xFF1D4ED8),
    accentSoft: Color(0xFFBFDBFE),
    backgroundTint: Color(0xFFF5F6FE),
    backgroundTintDark: Color(0xFF101A34),
  );

  static const AccentPalette green = AccentPalette(
    id: 'green',
    accent: Color(0xFF15803D),
    accentStrong: Color(0xFF15803D),
    accentSoft: Color(0xFFBBF7D0),
    backgroundTint: Color(0xFFF4F7FB),
    backgroundTintDark: Color(0xFF0F1D2B),
  );

  static const AccentPalette purple = AccentPalette(
    id: 'purple',
    accent: Color(0xFF6D28D9),
    accentStrong: Color(0xFF6D28D9),
    accentSoft: Color(0xFFE9D5FF),
    backgroundTint: Color(0xFFF6F5FE),
    backgroundTintDark: Color(0xFF151834),
  );

  static const AccentPalette orange = AccentPalette(
    id: 'orange',
    accent: Color(0xFFC2410C),
    accentStrong: Color(0xFFC2410C),
    accentSoft: Color(0xFFFED7AA),
    backgroundTint: Color(0xFFF8F5FA),
    backgroundTintDark: Color(0xFF1A1A28),
  );

  static const AccentPalette pink = AccentPalette(
    id: 'pink',
    accent: Color(0xFFBE185D),
    accentStrong: Color(0xFFBE185D),
    accentSoft: Color(0xFFFBCFE8),
    backgroundTint: Color(0xFFF8F4FC),
    backgroundTintDark: Color(0xFF1A172D),
  );

  /// Every palette, in the order they are stored and shown.
  ///
  /// The stored setting is an index into this list, so the order is
  /// append-only: reordering would silently change what everyone already
  /// picked. New colours go on the end.
  static const List<AccentPalette> all = [
    teal,
    blue,
    green,
    purple,
    orange,
    pink,
  ];

  /// The palette at [index], falling back to the default.
  ///
  /// Total over every int: a stored index from a build that had more palettes
  /// must not crash the app on downgrade.
  static AccentPalette byId(int index) {
    if (index < 0 || index >= all.length) return all.first;
    return all[index];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccentPalette &&
          other.id == id &&
          other.accent == accent &&
          other.accentStrong == accentStrong &&
          other.accentSoft == accentSoft &&
          other.backgroundTint == backgroundTint &&
          other.backgroundTintDark == backgroundTintDark &&
          other.onAccent == onAccent;

  @override
  int get hashCode =>
      Object.hash(id, accent, accentStrong, accentSoft, backgroundTint,
          backgroundTintDark, onAccent);
}
