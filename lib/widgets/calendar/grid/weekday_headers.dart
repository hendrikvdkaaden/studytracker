import 'package:flutter/material.dart';

/// Displays the weekday abbreviations (S M T W T F S) at the top of the calendar
class WeekdayHeaders extends StatelessWidget {
  static const _accentColor = Color(0xFF0DF2DF);
  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const WeekdayHeaders({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: _weekdayLabels
          .map((label) => _buildWeekdayHeader(label, isDark))
          .toList(),
    );
  }

  Widget _buildWeekdayHeader(String label, bool isDark) {
    return Expanded(
      child: Container(
        height: 32,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _getHeaderColor(isDark),
          ),
        ),
      ),
    );
  }

  Color _getHeaderColor(bool isDark) {
    return isDark
        ? _accentColor.withValues(alpha: 0.7)
        : const Color(0xFF499C95);
  }
}
