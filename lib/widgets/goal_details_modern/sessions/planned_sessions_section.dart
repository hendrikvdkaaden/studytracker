import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import 'planned_session_item.dart';

class PlannedSessionsSection extends StatefulWidget {
  final List<StudySession> sessions;
  final String goalTitle;
  final VoidCallback onAddSession;

  const PlannedSessionsSection({
    super.key,
    required this.sessions,
    required this.goalTitle,
    required this.onAddSession,
  });

  @override
  State<PlannedSessionsSection> createState() => _PlannedSessionsSectionState();
}

class _PlannedSessionsSectionState extends State<PlannedSessionsSection> {
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedCount = widget.sessions.where((s) => s.isCompleted).length;
    final visibleSessions = _showCompleted
        ? widget.sessions
        : widget.sessions.where((s) => !s.isCompleted).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0d1c1b),
                ),
              ),
              const Spacer(),
              if (completedCount > 0)
                GestureDetector(
                  onTap: () => setState(() => _showCompleted = !_showCompleted),
                  child: Text(
                    _showCompleted ? 'Hide Completed' : 'Show Completed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFa0cbc8)
                          : AppColors.upcoming,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Session list as one card with dividers
          if (visibleSessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.calendarDarkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 48,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No sessions planned yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add a study session',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    for (int i = 0; i < visibleSessions.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: isDark
                              ? const Color(0xFF2d4a48)
                              : const Color(0xFFcee8e6),
                        ),
                      PlannedSessionItem(
                        session: visibleSessions[i],
                        goalTitle: widget.goalTitle,
                      ),
                    ],
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Add button below list
          GestureDetector(
            onTap: widget.onAddSession,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.calendarAccent.withOpacity(0.08)
                    : AppColors.calendarAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.calendarAccent.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: isDark
                        ? AppColors.calendarAccent
                        : AppColors.upcoming,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add session',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.calendarAccent
                          : AppColors.upcoming,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
