import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/format_helpers.dart';
import '../../../utils/l10n_extension.dart';
import '../../common/planned_session_item.dart';

class PlannedSessionsSection extends StatefulWidget {
  final List<StudySession> sessions;
  final String goalTitle;
  final VoidCallback onAddSession;
  final void Function(StudySession session)? onEditSession;

  const PlannedSessionsSection({
    super.key,
    required this.sessions,
    required this.goalTitle,
    required this.onAddSession,
    this.onEditSession,
  });

  @override
  State<PlannedSessionsSection> createState() => _PlannedSessionsSectionState();
}

class _PlannedSessionsSectionState extends State<PlannedSessionsSection> {
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    final incomplete = widget.sessions.where((s) => !s.isCompleted).toList();
    final completedCount = widget.sessions.length - incomplete.length;
    final visibleSessions = _showCompleted ? widget.sessions : incomplete;

    final totalMinutes = widget.sessions.fold(0, (s, e) => s + e.duration);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF7C3AED).withValues(alpha: 0.15)
                      : const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt, size: 17, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.goalInfoSessionsLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: subtleText,
                  ),
                ),
              ),
              if (completedCount > 0)
                GestureDetector(
                  onTap: () => setState(() => _showCompleted = !_showCompleted),
                  child: Text(
                    _showCompleted ? context.l10n.goalDetailsHideCompleted : context.l10n.goalDetailsShowCompleted,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.9)
                          : AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Session list
          if (visibleSessions.isEmpty && widget.sessions.isEmpty)
            GestureDetector(
              onTap: widget.onAddSession,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkFieldBackground
                      : AppColors.lightFieldBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.goalDetailsAddSession,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                    Icon(Icons.add, color: subtleText, size: 20),
                  ],
                ),
              ),
            )
          else if (visibleSessions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkFieldBackground
                    : AppColors.lightFieldBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.goalDetailsAllSessionsCompleted,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.goalDetailsShowCompletedHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtleText,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkFieldBackground : AppColors.lightFieldBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    for (int i = 0; i < visibleSessions.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFE5E7EB),
                        ),
                      PlannedSessionItem(
                        session: visibleSessions[i],
                        index: i,
                        title: widget.goalTitle,
                        onEdit: !visibleSessions[i].isCompleted &&
                                widget.onEditSession != null
                            ? () => widget.onEditSession!(visibleSessions[i])
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Summary + add button
            Row(
              children: [
                Text(
                  context.l10n.goalDetailsSessionCount(widget.sessions.length),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  FormatHelpers.formatTime(totalMinutes),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onAddSession,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 14,
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.9)
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.goalDetailsAddSessionShort,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.9)
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
    );
  }
}
