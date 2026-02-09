import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import 'planned_session_item.dart';

class PlannedSessionsSection extends StatelessWidget {
  final List<StudySession> sessions;
  final VoidCallback onAddSession;

  const PlannedSessionsSection({
    super.key,
    required this.sessions,
    required this.onAddSession,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note,
                size: 20,
                color: AppColors.calendarAccent,
              ),
              const SizedBox(width: 8),
              Text(
                'Planned Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.calendarAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sessions.length.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.calendarAccent,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onAddSession,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.calendarAccent,
                iconSize: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.calendarDarkCard : AppColors.calendarLightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.calendarAccent.withOpacity(0.2),
                ),
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
            ...sessions.map((session) => PlannedSessionItem(session: session)),
        ],
      ),
    );
  }
}
