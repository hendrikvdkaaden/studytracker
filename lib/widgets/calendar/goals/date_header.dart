import 'package:flutter/material.dart';

class DateHeader extends StatelessWidget {
  final DateTime selectedDate;

  static const _darkBorder = Color(0xFF1F2937);
  static const _lightBorder = Color(0xFFF3F4F6);
  static const _darkText = Color(0xFFF8FCFB);
  static const _lightText = Color(0xFF0D1C1B);

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  const DateHeader({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? _darkBorder : _lightBorder),
        ),
      ),
      child: Text(
        _formatSelectedDate(selectedDate),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.015,
          color: isDark ? _darkText : _lightText,
        ),
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }
}
