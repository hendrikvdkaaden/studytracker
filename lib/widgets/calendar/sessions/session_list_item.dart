import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/format_helpers.dart';

class SessionListItem extends StatelessWidget {
  final StudySession session;
  final Goal goal;
  final bool isCompleted;
  final VoidCallback? onTap;

  const SessionListItem({
    super.key,
    required this.session,
    required this.goal,
    this.isCompleted = false,
    this.onTap,
  });

  bool get _hasNotes => session.notes?.trim().isNotEmpty == true;

  bool get _hasSubject => goal.subject.isNotEmpty;

  String _getTimeText() {
    if (isCompleted) return 'Completed';
    if (session.startTime != null) {
      final start = session.startTime!;
      final end = start.add(Duration(minutes: session.duration));
      return '${FormatHelpers.formatTimeOfDay(start.hour, start.minute)} - ${FormatHelpers.formatTimeOfDay(end.hour, end.minute)}';
    }
    return 'Planned for ${session.formattedDuration}';
  }

  String _getDisplayTitle() {
    if (_hasNotes) return session.notes!;
    return goal.title;
  }

  String _getSubtitle() {
    if (_hasNotes) {
      if (_hasSubject) return '${goal.subject} • ${goal.title}';
      return goal.title;
    }
    if (_hasSubject) return goal.subject;
    return _getTimeText();
  }

  String? _getThirdLine() {
    if (_hasNotes || _hasSubject) return _getTimeText();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thirdLine = _getThirdLine();

    final titleColor = isCompleted
        ? (isDark ? Colors.grey[500] : Colors.grey[400])
        : (isDark ? Colors.white : Colors.black87);

    final subtitleColor = isCompleted
        ? (isDark ? Colors.grey[600] : Colors.grey[500])
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    final thirdLineColor = isDark ? Colors.grey[600] : Colors.grey[500];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850]! : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayTitle(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSubtitle(),
                      style: TextStyle(fontSize: 11, color: subtitleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (thirdLine != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        thirdLine,
                        style: TextStyle(fontSize: 10, color: thirdLineColor),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
