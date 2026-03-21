import 'package:flutter/material.dart';

/// Centralized color definitions for the entire app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF0F766E);      // Teal Dark
  static const Color primaryLight = Color(0xFF14B8A6); // Teal Light
  static const Color primaryVeryLight = Color(0xFF99F6E4); // Teal Very Light

  // Calendar/Plan Screen Colors
  static const Color calendarAccent = Color(0xFF14B8A6);
  static const Color calendarDarkBackground = Color(0xFF0D2626);
  static const Color calendarLightBackground = Color(0xFFF0FDFA);
  static const Color calendarDarkCard = Color(0xFF134E4A);

  // Background Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color lightBackground = Color(0xFFF8FAFC);

  // Status Colors
  static const Color overdue = Color(0xFFEF4444);
  static const Color upcoming = Color(0xFF0F766E);
  static const Color completed = Color(0xFF22C55E);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Text Colors
  static const Color darkText = Color(0xFF0F172A);
  static const Color lightText = Color(0xFFF8FAFC);

  // Border Colors
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color darkBorder = Color(0xFF334155);
  static const Color lightCardBorder = Color(0xFFF1F5F9);
  static const Color darkCardBorder = Color(0xFF1E293B);

  // Card Colors
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF1E293B);

  // Accent Color (light grey-blue for subtle icons, dividers, inactive elements)
  static const Color accent = Color(0xFFE2E8F0);

  // Field Background Colors
  static const Color darkFieldBackground = Color(0xFF1E293B);
  static const Color lightFieldBackground = Color(0xFFF8FAFC);

  // Semantic UI icon colors
  static const Color iconBgBlue = Color(0xFFEFF6FF);
  static const Color iconBgGreen = Color(0xFFECFDF5);
  static const Color iconBgOrange = Color(0xFFFFF7ED);
  static const Color iconBgPurple = Color(0xFFF5F3FF);
  static const Color iconBgTeal = Color(0xFFF0FDFA);
  static const Color iconGreen = Color(0xFF059669);
  static const Color iconOrange = Color(0xFFEA580C);
  static const Color iconPurple = Color(0xFF7C3AED);
  static const Color iconTeal = Color(0xFF0F766E);

  // Text secondary/tertiary
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Divider colors
  static const Color dividerDark = Color(0xFF334155);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Section backgrounds
  static const Color sectionDarkBg = Color(0xFF1E293B);
  static const Color sectionLightBg = Color(0xFFF8FAFC);

  // Opacity helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // Context-aware color getters
  static Color getBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : lightBackground;
  }

  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCard : lightCard;
  }

  static Color getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBorder : lightBorder;
  }

  static Color getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? lightText : darkText;
  }

  static Color getCalendarBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? calendarDarkBackground : calendarLightBackground;
  }

  static Color getFieldBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkFieldBackground : lightFieldBackground;
  }

  static Color getModalBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? sectionDarkBg : Colors.white;
  }

  static Color getSecondaryText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF94A3B8) : textSecondary;
  }
}
