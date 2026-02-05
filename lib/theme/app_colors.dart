import 'package:flutter/material.dart';

/// Centralized color definitions for the entire app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF135BEC);

  // Calendar/Plan Screen Colors
  static const Color calendarAccent = Color(0xFF0DF2DF);
  static const Color calendarDarkBackground = Color(0xFF102221);
  static const Color calendarLightBackground = Color(0xFFF5F8F8);
  static const Color calendarDarkCard = Color(0xFF1A2F2E);

  // Background Colors
  static const Color darkBackground = Color(0xFF101622);
  static const Color lightBackground = Color(0xFFF6F6F8);

  // Status Colors
  static const Color overdue = Color(0xFFFF5252);
  static const Color upcoming = Color(0xFF499C95);
  static const Color completed = Color(0xFF078830);
  static const Color success = Colors.green;
  static const Color error = Colors.red;

  // Text Colors
  static const Color darkText = Color(0xFF0D1C1B);
  static const Color lightText = Color(0xFFF8FCFB);

  // Border Colors
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color darkBorder = Color(0xFF374151);
  static const Color lightCardBorder = Color(0xFFF3F4F6);
  static const Color darkCardBorder = Color(0xFF1F2937);

  // Card Colors
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF1F2937);

  // Opacity helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
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
}
