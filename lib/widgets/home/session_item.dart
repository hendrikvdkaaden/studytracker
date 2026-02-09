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

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  String _getTimeText() {
    // If completed, show "Completed" instead of time
    if (isCompleted) {
      return 'Completed';
    }

    if (session.actualDuration != null && session.actualDuration! > 0) {
      return '${_formatDuration(session.actualDuration!)} / ${session.formattedDuration} logged';
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

  String _getDisplayTitle() {
    if (session.notes != null && session.notes!.trim().isNotEmpty) {
      return session.notes!;
    }
    return goal?.title ?? 'Unknown Goal';
  }

  String _getSubtitle() {
    if (session.notes != null && session.notes!.trim().isNotEmpty) {
      final goalTitle = goal?.title ?? 'Unknown Goal';
      final subject = goal?.subject;
      if (subject != null && subject.isNotEmpty) {
        return '$subject • $goalTitle';
      }
      return goalTitle;
    }

    final subject = goal?.subject;
    if (subject != null && subject.isNotEmpty) {
      return subject;
    }
    return _getTimeText();
  }

  String _getThirdLine() {
    final hasNotes = session.notes != null && session.notes!.trim().isNotEmpty;
    if (hasNotes) {
      return _getTimeText();
    }

    final subject = goal?.subject;
    if (subject != null && subject.isNotEmpty) {
      return _getTimeText();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasNotes = session.notes != null && session.notes!.trim().isNotEmpty;
    final hasSubject = goal?.subject != null && goal!.subject.isNotEmpty;
    final showThirdLine = hasNotes || hasSubject;

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
                  _getDisplayTitle(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? (isDark ? Colors.grey[500] : Colors.grey[400])
                        : (isDark ? Colors.white : Colors.black87),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: isCompleted
                        ? (isDark ? Colors.grey[600] : Colors.grey[400])
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getSubtitle(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: isCompleted
                        ? (isDark ? Colors.grey[600] : Colors.grey[500])
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showThirdLine) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getThirdLine(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: isCompleted
                          ? (isDark ? Colors.grey[600] : Colors.grey[500])
                          : (isDark ? Colors.grey[500] : Colors.grey[500]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
