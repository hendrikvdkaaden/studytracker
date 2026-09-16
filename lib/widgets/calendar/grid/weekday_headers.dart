import 'package:flutter/material.dart';
import '../../../theme/app_theme_extension.dart';

/// Displays the weekday abbreviations (S M T W T F S) at the top of the calendar
class WeekdayHeaders extends StatelessWidget {
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
            color: context.colors.calendarWeekday,
          ),
        ),
      ),
    );
  }
}
