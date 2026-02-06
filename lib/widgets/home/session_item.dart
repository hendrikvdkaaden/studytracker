import 'package:flutter/material.dart';
import '../../models/study_session.dart';
import '../../models/goal.dart';
import '../../theme/app_colors.dart';

class HomeSessionItem extends StatelessWidget {
  final StudySession session;
  final Goal? goal;
  final bool isCompleted;
  final VoidCallback? onTap;

  const HomeSessionItem({
    super.key,
    required this.session,
    required this.goal,
    this.isCompleted = false,
    this.onTap,
  });

  String _getTimeText() {
    if (session.actualDuration != null && session.actualDuration! > 0) {
      return '${session.actualDuration}m / ${session.formattedDuration} logged';
    }

    if (session.startTime != null) {
      final start = session.startTime!;
      final end = start.add(Duration(minutes: session.duration));

      String formatTime(DateTime time) {
        final hour = time.hour;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }

      return '${formatTime(start)} - ${formatTime(end)}';
    }
    return 'Planned for ${session.formattedDuration}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalTitle = goal?.title ?? 'Unknown Goal';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: isCompleted
            ? (isDark
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.05))
            : (isDark ? Colors.grey[850] : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? (isDark
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1))
              : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isCompleted
                  ? null
                  : Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      width: 2,
                    ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : (session.actualDuration != null && session.actualDuration! > 0)
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTimeText(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted
                        ? AppColors.primary
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
