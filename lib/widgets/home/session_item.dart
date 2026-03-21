import 'package:flutter/material.dart';
import '../../models/study_session.dart';
import '../../models/goal.dart';
import '../../theme/app_colors.dart';
import '../../utils/format_helpers.dart';

class HomeSessionItem extends StatelessWidget {
  final StudySession session;
  final Goal? goal;
  final bool isCompleted;
  final bool isLast;
  final VoidCallback? onTap;

  const HomeSessionItem({
    super.key,
    required this.session,
    required this.goal,
    this.isCompleted = false,
    this.isLast = false,
    this.onTap,
  });

  bool get _isActive =>
      !isCompleted &&
      ((session.actualDuration ?? 0) > 0 || (session.elapsedSeconds ?? 0) > 0);

  bool get _hasNotes => session.notes?.trim().isNotEmpty == true;

  bool get _hasSubject => goal?.subject.isNotEmpty == true;

  String _getTimeText() {
    if (isCompleted) return 'Completed';
    final actual = session.actualDuration;
    if (actual != null && actual > 0) {
      return '${FormatHelpers.formatTime(actual)} / ${session.formattedDuration} logged';
    }
    if (session.startTime != null) {
      final start = session.startTime!;
      final end = start.add(Duration(minutes: session.duration));
      return '${FormatHelpers.formatTimeOfDay(start.hour, start.minute)} - ${FormatHelpers.formatTimeOfDay(end.hour, end.minute)}';
    }
    return 'Planned for ${session.formattedDuration}';
  }

  String _getDisplayTitle() {
    if (_hasNotes) {
      return session.notes!;
    }
    return goal?.title ?? 'Unknown Deadline';
  }

  String _getSubtitle() {
    if (_hasNotes) {
      final goalTitle = goal?.title ?? 'Unknown Deadline';
      if (_hasSubject) return '${goal!.subject} • $goalTitle';
      return goalTitle;
    }
    if (_hasSubject) return goal!.subject;
    return _getTimeText();
  }

  String? _getThirdLine() {
    if (_hasNotes || _hasSubject) return _getTimeText();
    return null;
  }

  Widget _buildCircle(bool isDark) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    }

    if (_isActive) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[350]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Planned
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[350]!,
          width: 2,
        ),
      ),
    );
  }

  Color _getLineColor(bool isDark) {
    return isDark ? Colors.grey[700]! : Colors.grey[300]!;
  }

  Widget _buildCard(BuildContext context, bool isDark) {
    Color cardColor;
    Border cardBorder;
    List<BoxShadow>? cardShadow;

    if (isCompleted) {
      cardColor = isDark
          ? Colors.grey[850]!
          : AppColors.lightCard;
      cardBorder = Border.all(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      );
    } else if (_isActive) {
      cardColor = isDark ? Colors.grey[850]! : AppColors.lightCard;
      cardBorder = Border.all(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      );
    } else {
      cardColor = isDark ? Colors.grey[850]! : AppColors.lightCard;
      cardBorder = Border.all(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      );
    }

    final titleColor = isCompleted
        ? (isDark ? Colors.grey[500] : Colors.grey[400])
        : (isDark ? Colors.white : Colors.black87);

    final subtitleColor = isCompleted
        ? (isDark ? Colors.grey[600] : Colors.grey[500])
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    final thirdLineColor = isDark ? Colors.grey[600] : Colors.grey[500];

    final thirdLine = _getThirdLine();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: cardBorder,
          boxShadow: cardShadow,
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
                    style: TextStyle(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (thirdLine != null) ...[
                    const SizedBox(height: 2),
                    Text(thirdLine, style: TextStyle(fontSize: 10, color: thirdLineColor)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  _buildCircle(isDark),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLineColor(isDark),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildCard(context, isDark)),
          ],
        ),
      ),
    );
  }
}
