import 'package:flutter/material.dart';
import '../../../theme/app_theme_extension.dart';

/// Displays the weekday abbreviations (S M T W T F S) at the top of the calendar
class WeekdayHeaders extends StatelessWidget {
  // Calendar-specific header accents (invariant, kept 1:1 with the original).
  static const _darkAccent = Color(0xFF0DF2DF);
  static const _lightAccent = Color(0xFF499C95);
  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const WeekdayHeaders({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _weekdayLabels
          .map((label) => _buildWeekdayHeader(context, label))
          .toList(),
    );
  }

  Widget _buildWeekdayHeader(BuildContext context, String label) {
    return Expanded(
      child: Container(
        height: 32,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _getHeaderColor(context),
          ),
        ),
      ),
    );
  }

  Color _getHeaderColor(BuildContext context) {
    return context.colors.isDark
        ? _darkAccent.withValues(alpha: 0.7)
        : _lightAccent;
  }
}
