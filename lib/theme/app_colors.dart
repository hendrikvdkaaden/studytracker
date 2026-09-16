import 'package:flutter/material.dart';

/// Colors that are the same in light and dark mode.
///
/// Anything that *differs* between the two belongs on [AppTheme] as a token,
/// not here — a `light*`/`dark*` pair in this file is an invitation to write
/// `isDark ? AppColors.lightX : AppColors.darkX` at the call site, which is
/// exactly what the theme extension exists to prevent. Reach the varying
/// colors with `context.colors.<token>`.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // The accent lives on the AppTheme extension now, because the user picks
  // it at runtime -- see AccentPalette. Reach it with context.colors.accent /
  // .accentStrong / .accentSoft. It is deliberately absent here so a missed
  // reference is a compile error rather than a stray teal next to a green
  // button, which nothing would catch.

  // Status Colors
  static const Color overdue = Color(0xFFEF4444);
  static const Color completed = Color(0xFF22C55E);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Card Colors — the seed values MaterialApp's ThemeData is built from.
  // Widgets should read context.colors.card instead.
  static const Color darkCard = Color(0xFF1E293B);

  // Semantic UI icon colors. The iconBg* pastels are the *light* half of an
  // icon chip; pass them to context.colors.iconChipBackground(), which picks
  // the translucent dark equivalent for you.
  static const Color iconBgBlue = Color(0xFFEFF6FF);
  static const Color iconBgGreen = Color(0xFFECFDF5);
  static const Color iconBgOrange = Color(0xFFFFF7ED);
  static const Color iconBgPurple = Color(0xFFF5F3FF);
  static const Color iconBgTeal = Color(0xFFF0FDFA);
  static const Color iconGreen = Color(0xFF059669);
  static const Color iconOrange = Color(0xFFEA580C);
  static const Color iconPurple = Color(0xFF7C3AED);

  // Premium gradient
  static const Color premiumBlue = Color(0xFF135BEC);
  static const Color premiumGradientEnd = Color(0xFF4648D4);
  static const Color premiumDark = Color(0xFF0045BD);
  static const Color premiumText = Color(0xFF161C28);
  static const Color premiumCardBorder = Color(0xFFC3C5D8);

  // Premium badge — gold pill with dark amber text for contrast
  static const Color premiumGold = Color(0xFFF5C542);
  static const Color premiumGoldLight = Color(0xFFFDE68A);
  static const Color premiumGoldText = Color(0xFF78350F);

  // Opacity helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
