import 'package:flutter/material.dart';

/// Theme extension carrying every color token that varies between
/// light and dark mode. Theme-invariant colors (brand teal, status,
/// icon tints, premium) stay as constants in [AppColors].
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
  final Color calendarBackground;
  final Color calendarCard;

  /// Drag-handle pill on bottom sheets/modals.
  final Color dragHandle;

  /// Whether this instance represents the dark theme. Lets widgets pick
  /// per-brightness alpha values (e.g. icon tints) without calling
  /// `Theme.of(context).brightness` themselves.
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
    required this.calendarBackground,
    required this.calendarCard,
    required this.dragHandle,
    required this.isDark,
  });

  static const AppTheme light = AppTheme(
    background: Color(0xFFF9F9FF),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1A1F2E),
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    fieldBackground: Color(0xFFF8FAFC),
    modalBackground: Color(0xFFFFFFFF),
    sectionBackground: Color(0xFFF8FAFC),
    calendarBackground: Color(0xFFF0FDFA),
    calendarCard: Color(0xFFFFFFFF),
    dragHandle: Color(0xFFCBD5E1),
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
    calendarBackground: Color(0xFF0D2626),
    calendarCard: Color(0xFF134E4A),
    dragHandle: Color(0xFF475569),
    isDark: true,
  );

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
    Color? calendarBackground,
    Color? calendarCard,
    Color? dragHandle,
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
      calendarBackground: calendarBackground ?? this.calendarBackground,
      calendarCard: calendarCard ?? this.calendarCard,
      dragHandle: dragHandle ?? this.dragHandle,
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
      calendarBackground:
          Color.lerp(calendarBackground, other.calendarBackground, t)!,
      calendarCard: Color.lerp(calendarCard, other.calendarCard, t)!,
      dragHandle: Color.lerp(dragHandle, other.dragHandle, t)!,
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
        other.calendarBackground == calendarBackground &&
        other.calendarCard == calendarCard &&
        other.dragHandle == dragHandle &&
        other.isDark == isDark;
  }

  @override
  int get hashCode => Object.hash(
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
        calendarBackground,
        calendarCard,
        dragHandle,
        isDark,
      );
}

/// Shorthand for reading the [AppTheme] tokens: `context.colors.card`.
extension AppThemeX on BuildContext {
  AppTheme get colors => Theme.of(this).extension<AppTheme>()!;
}
