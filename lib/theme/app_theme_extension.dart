import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'accent_palette.dart';

/// Theme extension carrying every color token that varies between light and
/// dark mode, plus the accent the user picked. Colors that vary with neither
/// (status, icon tints, premium) stay as constants in [AppColors].
///
/// Consume via the [AppThemeX] extension: `context.colors.card`.
@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  final Color background;
  final Color card;
  final Color cardBorder;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color fieldBackground;
  final Color modalBackground;
  final Color sectionBackground;

  /// Solid fill behind [onAccent] text, and the foreground on light surfaces.
  final Color accent;

  /// Foreground on dark surfaces, where [accent] reads too dark.
  final Color accentStrong;

  /// Pale fill for chips and tints. Fill only -- see [AccentPalette].
  final Color accentSoft;

  /// Text and icons drawn on [accent].
  final Color onAccent;

  /// Drag-handle pill on bottom sheets/modals.
  final Color dragHandle;

  /// The accent as a *foreground on the app's own surfaces* — headings,
  /// badge labels, icons drawn on [card]/[background]. Dark mode needs the
  /// pale [accentSoft]; light mode wants the solid [accent]. Reach for this
  /// instead of branching on [isDark] at the call site.
  final Color accentOnSurface;

  /// Fill and hairline for neutral pills and chips (subject chips, input
  /// fields on the onboarding cards) — a step off [card], unlike
  /// [fieldBackground] which is the deeper form-input surface.
  final Color chipBackground;
  final Color chipBorder;

  /// Placeholder text inside inputs. Dimmer than [textTertiary].
  final Color hintText;

  /// Frozen-day status (streak freeze): icon foreground, tinted fill, and
  /// ring. Shared by the week circles and the celebration dialog, so the two
  /// cannot drift apart.
  final Color frozenIcon;
  final Color frozenFill;
  final Color frozenBorder;

  /// Missed-day status, same three roles as the frozen set.
  final Color missedIcon;
  final Color missedFill;
  final Color missedBorder;

  /// Hairline around a card sitting on [background]. Dark mode draws a
  /// translucent white so the card reads as lit from above; light mode draws
  /// a solid grey.
  final Color cardHairline;

  /// Surface of the stat cards on the dashboard (consistency, weekly
  /// progress) — a tinted panel, distinct from the plain [card].
  final Color statCardBackground;

  /// The amber of the "best week" style badges.
  final Color badgeAmber;

  /// Fill and hairline for a small inert control — stepper buttons, an
  /// unselected plan tile. Subtler than [chipBackground].
  final Color controlSurface;

  /// An unselected option tile in a picker (type chips, wizard buttons) and
  /// its hairline. Light mode is plain white so the selected accent tile
  /// stands out; dark mode lifts it slightly off the sheet.
  final Color optionSurface;
  final Color optionBorder;

  /// The premium upgrade card: its gradient stops, hairline, and the two
  /// text tints that sit on it. A fixed blue palette — it does not follow
  /// the user's accent, because the badge should read as "premium", not as
  /// whatever colour they picked.
  final List<Color> premiumGradient;
  final Color premiumBorder;
  final Color premiumLabel;
  final Color premiumTitle;

  /// Hairline around an *unselected* plan tile in the paywall. Distinct from
  /// [premiumBorder], which outlines the upgrade card itself.
  final Color premiumTileBorder;

  /// Divider inside an accent-tinted list (the planned-sessions list).
  final Color tintedDivider;

  /// The weekday letters above the calendar grid — a calendar-specific
  /// accent that does not follow the user's chosen one.
  final Color calendarWeekday;

  /// The accent used as *normal-size text*. Dark mode falls back to plain
  /// ink: the mid-tone the accent resolves to there only reaches 2.06-2.92
  /// against a dark surface, well under the 4.5:1 body text needs. Large
  /// display text on [background] uses [headingOnBackground] instead.
  final Color accentText;

  /// A heading drawn large on [background]. The accent is only readable at
  /// that size on a light surface, so dark mode falls back to plain ink.
  final Color headingOnBackground;

  /// The streak flame's orange — shared by the badge and the celebration
  /// dialog's rolling digits.
  final Color streakFlame;

  /// Fill of an empty/unplanned day circle — a hole punched in the card, so
  /// it darkens in dark mode and lightens in light mode.
  final Color emptyFill;

  /// Whether this instance represents the dark theme.
  ///
  /// Prefer a token over reading this. It exists for the two things a color
  /// token cannot express: a per-brightness *alpha* (see [iconChipBackground],
  /// [overlay], [accentAlpha]) and the Cupertino/Material [brightness] that
  /// framework widgets ask for (see [brightness]). Anything else — a color
  /// that differs between modes — belongs here as a field.
  final bool isDark;

  const AppTheme({
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.fieldBackground,
    required this.modalBackground,
    required this.sectionBackground,
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.onAccent,
    required this.dragHandle,
    required this.accentOnSurface,
    required this.chipBackground,
    required this.chipBorder,
    required this.hintText,
    required this.frozenIcon,
    required this.frozenFill,
    required this.frozenBorder,
    required this.missedIcon,
    required this.missedFill,
    required this.missedBorder,
    required this.emptyFill,
    required this.streakFlame,
    required this.cardHairline,
    required this.statCardBackground,
    required this.badgeAmber,
    required this.headingOnBackground,
    required this.accentText,
    required this.calendarWeekday,
    required this.controlSurface,
    required this.tintedDivider,
    required this.optionSurface,
    required this.optionBorder,
    required this.premiumGradient,
    required this.premiumBorder,
    required this.premiumLabel,
    required this.premiumTitle,
    required this.premiumTileBorder,
    required this.isDark,
  });

  static const AppTheme light = AppTheme(
    background: Color(0xFFF9F9FF),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1A1F2E),
    textSecondary: Color(0xFF5B6B7F),
    textTertiary: Color(0xFF94A3B8),
    fieldBackground: Color(0xFFF8FAFC),
    modalBackground: Color(0xFFFFFFFF),
    sectionBackground: Color(0xFFF8FAFC),
    // Seeded with the palette the app shipped on; main.dart swaps in the
    // user's choice via [withAccent].
    accent: Color(0xFF0F766E),
    accentStrong: Color(0xFF14B8A6),
    accentSoft: Color(0xFF99F6E4),
    onAccent: Color(0xFFFFFFFF),
    dragHandle: Color(0xFFCBD5E1),
    accentOnSurface: Color(0xFF0F766E),
    chipBackground: Color(0xFFF8FAFC),
    chipBorder: Color(0xFFE2E8F0),
    hintText: Color(0xFF94A3B8),
    // Colors.lightBlue shade600 / shade50@60% / shade200.
    frozenIcon: Color(0xFF039BE5),
    frozenFill: Color(0x99E1F5FE),
    frozenBorder: Color(0xFF81D4FA),
    // Colors.red shade400 / shade50@50% / shade200.
    missedIcon: Color(0xFFEF5350),
    missedFill: Color(0x80FFEBEE),
    missedBorder: Color(0xFFEF9A9A),
    emptyFill: Color(0x80FFFFFF),
    streakFlame: Color(0xFFF57C00), // Colors.orange.shade700
    cardHairline: Color(0xFFE2E8F0),
    statCardBackground: Color(0xFFF3EDF7),
    badgeAmber: Color(0xFFFFA000), // Colors.amber.shade700
    headingOnBackground: Color(0xFF0F766E),
    accentText: Color(0xFF0F766E),
    calendarWeekday: Color(0xFF499C95),
    controlSurface: Color(0xFFF5F5F5), // Colors.grey[100]
    tintedDivider: Color(0xFFCEE8E6),
    optionSurface: Color(0xFFFFFFFF),
    optionBorder: Color(0xFFEEEEEE), // Colors.grey[200]
    premiumGradient: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
    premiumBorder: Color(0x333B82F6),
    premiumLabel: Color(0xFF1E3A8A),
    premiumTitle: Color(0xFF1D4ED8),
    premiumTileBorder: Color(0xFFC3C5D8), // AppColors.premiumCardBorder
    isDark: false,
  );

  static const AppTheme dark = AppTheme(
    background: Color(0xFF0F172A),
    card: Color(0xFF1E293B),
    cardBorder: Color(0xFF1E293B),
    // Lighter than fieldBackground (0xFF334155) so a border drawn around a
    // field/card fill stays visible in dark mode.
    border: Color(0xFF3E4C63),
    divider: Color(0xFF3E4C63),
    textPrimary: Color(0xFFF8FAFC),
    // On dark surfaces muted text must stay light enough to read, so
    // secondary is slate-400. Tertiary is slate-500 — one step dimmer than
    // secondary (a real hierarchy) but still legible, unlike the original
    // token which pushed it to the barely-visible 0xFF64748B on 0xFF0F172A.
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF7C899E),
    // Distinct, lighter than the modal/card background (0xFF1E293B) so
    // input fields stay visible against modal surfaces in dark mode.
    fieldBackground: Color(0xFF334155),
    modalBackground: Color(0xFF1E293B),
    sectionBackground: Color(0xFF1E293B),
    // Dark mode draws the light-mode accent unchanged, by explicit choice:
    // one accent means one colour. See AccentPalette.accentStrong for what
    // that costs in contrast on dark cards.
    accent: Color(0xFF0F766E),
    accentStrong: Color(0xFF0F766E),
    accentSoft: Color(0xFF99F6E4),
    onAccent: Color(0xFFFFFFFF),
    dragHandle: Color(0xFF475569),
    // Dark cards need the pale accent as a foreground; the solid one
    // (0xFF0F766E) is too dark to read on 0xFF1E293B.
    accentOnSurface: Color(0xFF99F6E4),
    chipBackground: Color(0xFF2D3449),
    chipBorder: Color(0xFF334155),
    hintText: Color(0x4DFFFFFF),
    // Colors.lightBlue shade200 / shade900@15% / shade900@60%.
    frozenIcon: Color(0xFF81D4FA),
    frozenFill: Color(0x2601579B),
    frozenBorder: Color(0x9901579B),
    // Colors.red shade400 / shade900@10% / shade900@50%.
    missedIcon: Color(0xFFEF5350),
    missedFill: Color(0x1AB71C1C),
    missedBorder: Color(0x80B71C1C),
    emptyFill: Color(0x33000000),
    streakFlame: Color(0xFFFFB74D), // Colors.orange.shade300
    cardHairline: Color(0x0FFFFFFF),
    statCardBackground: Color(0xFF2B2930),
    badgeAmber: Color(0xFFFFCA28), // Colors.amber.shade400
    headingOnBackground: Color(0xFFF8FAFC),
    accentText: Color(0xFFF8FAFC),
    calendarWeekday: Color(0xB30DF2DF), // 0xFF0DF2DF at 70%
    controlSurface: Color(0x14FFFFFF), // white at 8%
    tintedDivider: Color(0xFF2D4A48),
    optionSurface: Color(0x0FFFFFFF), // white at 6%
    optionBorder: Color(0x1AFFFFFF), // white at 10%
    premiumGradient: [Color(0xFF1E2A4A), Color(0xFF1A1F3A)],
    premiumBorder: Color(0x1A3B82F6),
    premiumLabel: Color(0xFFBFD7FF),
    premiumTitle: Color(0xFFDDE9FF),
    premiumTileBorder: Color(0x14FFFFFF), // white at 8%
    isDark: true,
  );

  /// This theme with [palette]'s colours in place of the accent.
  ///
  /// Dark mode swaps the roles: it draws the light accent as its foreground,
  /// because the solid one is too dark to read against a dark card. Text on
  /// it flips to the dark ink for the same reason.
  ///
  /// [background] moves too, but only barely -- see [AccentPalette.backgroundTint].
  /// [card] deliberately does not: keeping cards a flat white (or flat dark)
  /// is what stops the tint from reaching the text that sits on them.
  AppTheme withAccent(AccentPalette palette) {
    return copyWith(
      accent: isDark ? palette.accentStrong : palette.accent,
      accentStrong: palette.accentStrong,
      accentSoft: palette.accentSoft,
      // White in both modes. The dark ink here made sense while dark mode
      // drew a light mid-tone accent; now that it draws the light-mode accent
      // unchanged, that ink sits on a dark saturated fill and scores 2.51-3.56
      // across the palettes, where white scores 5.02-7.10.
      onAccent: palette.onAccent,
      background:
          isDark ? palette.backgroundTintDark : palette.backgroundTint,
      // Same swap as [accent], but for the pale end: on a dark card only
      // [accentSoft] carries; on a light one it would wash out, so light
      // mode keeps the solid accent.
      accentOnSurface: isDark ? palette.accentSoft : palette.accent,
      // Light mode only: dark mode's plain ink does not depend on the accent.
      headingOnBackground: isDark ? headingOnBackground : palette.accent,
      accentText: isDark ? accentText : palette.accent,
    );
  }

  /// Background tint for a small icon chip given its [accent] color.
  /// Dark mode uses a translucent accent (default alpha 0.15, override via
  /// [darkAlpha] to preserve an exact value); light mode uses the pale
  /// [lightBackground] (typically one of the AppColors.iconBg* pastels).
  Color iconChipBackground(
    Color accent,
    Color lightBackground, {
    double darkAlpha = 0.15,
  }) {
    return isDark ? accent.withValues(alpha: darkAlpha) : lightBackground;
  }

  /// Translucent hairline/overlay tint used for borders and dividers that
  /// sit on top of a surface. White in dark mode, black in light mode.
  Color overlay({double darkAlpha = 0.06, double lightAlpha = 0.06}) {
    return isDark
        ? Colors.white.withValues(alpha: darkAlpha)
        : Colors.black.withValues(alpha: lightAlpha);
  }

  /// The [Brightness] framework widgets ask for — `CupertinoThemeData`,
  /// `SystemUiOverlayStyle`, nested `ThemeData`. Saves every call site
  /// writing out `isDark ? Brightness.dark : Brightness.light`.
  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  /// [color] at the alpha that reads correctly per mode. Dark surfaces
  /// swallow translucency, so tints there need to be pushed harder; the
  /// defaults are the border/hairline pair used across the app.
  Color accentAlpha(Color color,
      {double darkAlpha = 0.3, double lightAlpha = 0.2}) {
    return color.withValues(alpha: isDark ? darkAlpha : lightAlpha);
  }

  /// [color] as a translucent status tint — the pale fill behind a status
  /// icon or pill. Dark surfaces need slightly more of it to register.
  Color statusTint(Color color,
      {double darkAlpha = 0.1, double lightAlpha = 0.08}) {
    return color.withValues(alpha: isDark ? darkAlpha : lightAlpha);
  }

  /// Drop shadow lifting a card off [background]. Dark mode draws none: a
  /// black shadow on a near-black background is invisible, and the card
  /// already separates by its own lighter fill.
  List<BoxShadow>? cardShadow({
    double alpha = 0.06,
    double blurRadius = 16,
    Offset offset = const Offset(0, 4),
  }) {
    if (isDark) return null;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: alpha),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  /// Hairline around a card. Null in dark mode for the same reason
  /// [cardShadow] is: the fill alone already separates it.
  BoxBorder? cardOutline({double alpha = 0.5}) {
    if (isDark) return null;
    return Border.all(color: chipBorder.withValues(alpha: alpha));
  }

  @override
  AppTheme copyWith({
    Color? background,
    Color? card,
    Color? cardBorder,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? fieldBackground,
    Color? modalBackground,
    Color? sectionBackground,
    Color? accent,
    Color? accentStrong,
    Color? accentSoft,
    Color? onAccent,
    Color? dragHandle,
    Color? accentOnSurface,
    Color? chipBackground,
    Color? chipBorder,
    Color? hintText,
    Color? frozenIcon,
    Color? frozenFill,
    Color? frozenBorder,
    Color? missedIcon,
    Color? missedFill,
    Color? missedBorder,
    Color? emptyFill,
    Color? streakFlame,
    Color? cardHairline,
    Color? statCardBackground,
    Color? badgeAmber,
    Color? headingOnBackground,
    Color? accentText,
    Color? calendarWeekday,
    Color? controlSurface,
    Color? tintedDivider,
    Color? optionSurface,
    Color? optionBorder,
    List<Color>? premiumGradient,
    Color? premiumBorder,
    Color? premiumLabel,
    Color? premiumTitle,
    Color? premiumTileBorder,
    bool? isDark,
  }) {
    return AppTheme(
      background: background ?? this.background,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      fieldBackground: fieldBackground ?? this.fieldBackground,
      modalBackground: modalBackground ?? this.modalBackground,
      sectionBackground: sectionBackground ?? this.sectionBackground,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      dragHandle: dragHandle ?? this.dragHandle,
      accentOnSurface: accentOnSurface ?? this.accentOnSurface,
      chipBackground: chipBackground ?? this.chipBackground,
      chipBorder: chipBorder ?? this.chipBorder,
      hintText: hintText ?? this.hintText,
      frozenIcon: frozenIcon ?? this.frozenIcon,
      frozenFill: frozenFill ?? this.frozenFill,
      frozenBorder: frozenBorder ?? this.frozenBorder,
      missedIcon: missedIcon ?? this.missedIcon,
      missedFill: missedFill ?? this.missedFill,
      missedBorder: missedBorder ?? this.missedBorder,
      emptyFill: emptyFill ?? this.emptyFill,
      streakFlame: streakFlame ?? this.streakFlame,
      cardHairline: cardHairline ?? this.cardHairline,
      statCardBackground: statCardBackground ?? this.statCardBackground,
      badgeAmber: badgeAmber ?? this.badgeAmber,
      headingOnBackground: headingOnBackground ?? this.headingOnBackground,
      accentText: accentText ?? this.accentText,
      calendarWeekday: calendarWeekday ?? this.calendarWeekday,
      controlSurface: controlSurface ?? this.controlSurface,
      tintedDivider: tintedDivider ?? this.tintedDivider,
      optionSurface: optionSurface ?? this.optionSurface,
      optionBorder: optionBorder ?? this.optionBorder,
      premiumGradient: premiumGradient ?? this.premiumGradient,
      premiumBorder: premiumBorder ?? this.premiumBorder,
      premiumLabel: premiumLabel ?? this.premiumLabel,
      premiumTitle: premiumTitle ?? this.premiumTitle,
      premiumTileBorder: premiumTileBorder ?? this.premiumTileBorder,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      fieldBackground: Color.lerp(fieldBackground, other.fieldBackground, t)!,
      modalBackground: Color.lerp(modalBackground, other.modalBackground, t)!,
      sectionBackground:
          Color.lerp(sectionBackground, other.sectionBackground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      dragHandle: Color.lerp(dragHandle, other.dragHandle, t)!,
      accentOnSurface:
          Color.lerp(accentOnSurface, other.accentOnSurface, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      frozenIcon: Color.lerp(frozenIcon, other.frozenIcon, t)!,
      frozenFill: Color.lerp(frozenFill, other.frozenFill, t)!,
      frozenBorder: Color.lerp(frozenBorder, other.frozenBorder, t)!,
      missedIcon: Color.lerp(missedIcon, other.missedIcon, t)!,
      missedFill: Color.lerp(missedFill, other.missedFill, t)!,
      missedBorder: Color.lerp(missedBorder, other.missedBorder, t)!,
      emptyFill: Color.lerp(emptyFill, other.emptyFill, t)!,
      streakFlame: Color.lerp(streakFlame, other.streakFlame, t)!,
      cardHairline: Color.lerp(cardHairline, other.cardHairline, t)!,
      statCardBackground:
          Color.lerp(statCardBackground, other.statCardBackground, t)!,
      badgeAmber: Color.lerp(badgeAmber, other.badgeAmber, t)!,
      headingOnBackground:
          Color.lerp(headingOnBackground, other.headingOnBackground, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      calendarWeekday: Color.lerp(calendarWeekday, other.calendarWeekday, t)!,
      controlSurface: Color.lerp(controlSurface, other.controlSurface, t)!,
      tintedDivider: Color.lerp(tintedDivider, other.tintedDivider, t)!,
      optionSurface: Color.lerp(optionSurface, other.optionSurface, t)!,
      optionBorder: Color.lerp(optionBorder, other.optionBorder, t)!,
      premiumGradient: [
        for (var i = 0; i < premiumGradient.length; i++)
          Color.lerp(premiumGradient[i], other.premiumGradient[i], t)!,
      ],
      premiumBorder: Color.lerp(premiumBorder, other.premiumBorder, t)!,
      premiumLabel: Color.lerp(premiumLabel, other.premiumLabel, t)!,
      premiumTitle: Color.lerp(premiumTitle, other.premiumTitle, t)!,
      premiumTileBorder:
          Color.lerp(premiumTileBorder, other.premiumTileBorder, t)!,
      // `isDark` is a boolean flag, not a lerp-able color, so it flips at the
      // animation midpoint. Helpers that branch on it (iconChipBackground,
      // overlay) therefore switch formulas at t=0.5 rather than cross-fading;
      // acceptable for the small translucent tints they produce.
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTheme &&
        other.background == background &&
        other.card == card &&
        other.cardBorder == cardBorder &&
        other.border == border &&
        other.divider == divider &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.textTertiary == textTertiary &&
        other.fieldBackground == fieldBackground &&
        other.modalBackground == modalBackground &&
        other.sectionBackground == sectionBackground &&
        other.accent == accent &&
        other.accentStrong == accentStrong &&
        other.accentSoft == accentSoft &&
        other.onAccent == onAccent &&
        other.dragHandle == dragHandle &&
        other.accentOnSurface == accentOnSurface &&
        other.chipBackground == chipBackground &&
        other.chipBorder == chipBorder &&
        other.hintText == hintText &&
        other.frozenIcon == frozenIcon &&
        other.frozenFill == frozenFill &&
        other.frozenBorder == frozenBorder &&
        other.missedIcon == missedIcon &&
        other.missedFill == missedFill &&
        other.missedBorder == missedBorder &&
        other.emptyFill == emptyFill &&
        other.streakFlame == streakFlame &&
        other.cardHairline == cardHairline &&
        other.statCardBackground == statCardBackground &&
        other.badgeAmber == badgeAmber &&
        other.headingOnBackground == headingOnBackground &&
        other.accentText == accentText &&
        other.calendarWeekday == calendarWeekday &&
        other.controlSurface == controlSurface &&
        other.tintedDivider == tintedDivider &&
        other.optionSurface == optionSurface &&
        other.optionBorder == optionBorder &&
        listEquals(other.premiumGradient, premiumGradient) &&
        other.premiumBorder == premiumBorder &&
        other.premiumLabel == premiumLabel &&
        other.premiumTitle == premiumTitle &&
        other.premiumTileBorder == premiumTileBorder &&
        other.isDark == isDark;
  }

  @override
  // hashAll rather than hash: the token list passed 20 fields, which is
  // Object.hash's positional limit.
  int get hashCode => Object.hashAll([
        background,
        card,
        cardBorder,
        border,
        divider,
        textPrimary,
        textSecondary,
        textTertiary,
        fieldBackground,
        modalBackground,
        sectionBackground,
        accent,
        accentStrong,
        accentSoft,
        onAccent,
        dragHandle,
        accentOnSurface,
        chipBackground,
        chipBorder,
        hintText,
        frozenIcon,
        frozenFill,
        frozenBorder,
        missedIcon,
        missedFill,
        missedBorder,
        emptyFill,
        streakFlame,
        cardHairline,
        statCardBackground,
        badgeAmber,
        headingOnBackground,
        accentText,
        calendarWeekday,
        controlSurface,
        tintedDivider,
        optionSurface,
        optionBorder,
        Object.hashAll(premiumGradient),
        premiumBorder,
        premiumLabel,
        premiumTitle,
        premiumTileBorder,
        isDark,
      ]);
}

/// Shorthand for reading the [AppTheme] tokens: `context.colors.card`.
extension AppThemeX on BuildContext {
  AppTheme get colors => Theme.of(this).extension<AppTheme>()!;
}
