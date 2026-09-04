import 'package:flutter/material.dart';
import '../../models/study_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/format_helpers.dart';

class PlannedSessionItem extends StatelessWidget {
  final StudySession session;

  /// Shown as title when notes is null. Use goalTitle for the details screen,
  /// or leave null to fall back to "Session [index + 1]".
  final String? title;

  /// 0-based index used for the "Session N" fallback title.
  final int index;

  /// Optional callbacks — only needed in add/edit flows.
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlannedSessionItem({
    super.key,
    required this.session,
    required this.index,
    this.title,
    this.onEdit,
    this.onDelete,
  });

  bool get _isCompleted => session.isCompleted;

  String _getDateText(DateTime today) {
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate =
        DateTime(session.date.year, session.date.month, session.date.day);

    if (sessionDate == today) return 'Today';
    if (sessionDate == tomorrow) return 'Tomorrow';

    return FormatHelpers.formatDateShort(session.date);
  }

  String _getTimeText() {
    final start = session.startTime;
    if (start == null) return '';
    return FormatHelpers.formatTimeOfDay(start.hour, start.minute);
  }

  String _resolveTitle() {
    if (session.notes?.isNotEmpty == true) return session.notes!;
    if (title != null) return title!;
    return 'Session ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateText = _getDateText(today);
    final timeText = _getTimeText();
    final subtleColor = context.colors.textSecondary;

    return Opacity(
      opacity: _isCompleted ? 0.75 : 1.0,
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          color: context.colors.card,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + badge/delete row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _resolveTitle(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (onDelete != null)
                    // A bigger icon and padding around it, but the target is
                    // kept from growing taller than the row: an 18pt icon with
                    // an 18pt hit area was far under the 44pt a fingertip
                    // needs, and missing it opened the editor instead.
                    SizedBox(
                      height: 20,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onDelete,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.delete_outline,
                              size: 22,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    _buildStatusBadge(context, today),
                ],
              ),
              const SizedBox(height: 8),
              // Date + time + duration row
              Row(
                children: [
                  Icon(Icons.event_outlined, size: 14, color: subtleColor),
                  const SizedBox(width: 4),
                  Text(
                    dateText,
                    style: TextStyle(fontSize: 12, color: subtleColor),
                  ),
                  if (timeText.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.schedule_outlined,
                        size: 14, color: subtleColor),
                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: TextStyle(fontSize: 12, color: subtleColor),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    session.formattedDuration,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, DateTime today) {
    final isDark = context.colors.isDark;
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.calendarAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 12,
                color:
                    isDark ? AppColors.calendarAccent : AppColors.upcoming),
            const SizedBox(width: 3),
            Text(
              'DONE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.calendarAccent : AppColors.upcoming,
              ),
            ),
          ],
        ),
      );
    }

    final sessionDate =
        DateTime(session.date.year, session.date.month, session.date.day);
    final isToday = sessionDate == today;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.calendarAccent.withValues(alpha: isToday ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isToday ? 'TODAY' : 'UPCOMING',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.calendarAccent : context.colors.textPrimary,
        ),
      ),
    );
  }
}
