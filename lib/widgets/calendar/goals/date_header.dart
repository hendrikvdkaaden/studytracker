import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/calendar_helpers.dart';
import '../../../utils/l10n_extension.dart';

class DateHeader extends StatelessWidget {
  final DateTime selectedDate;

  const DateHeader({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = CalendarHelpers.isSameDay(selectedDate, DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.border),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.calendarAccent.withValues(
              alpha: context.colors.isDark ? 0.16 : 0.12,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.calendarAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatSelectedDate(selectedDate),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.01,
                  color: context.colors.textPrimary,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 6),
                Text(
                  '·',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.calendarTodayButton,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.calendarAccent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    // TODO: use ambient locale once non-English locales are added (requires initializeDateFormatting()).
    return DateFormat('EEE, MMM d', 'en_US').format(date);
  }
}
