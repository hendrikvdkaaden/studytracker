import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import 'planned_session_item.dart';

class PlannedSessionsSection extends StatelessWidget {
  final List<StudySession> sessions;

  const PlannedSessionsSection({
    super.key,
    required this.sessions,
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
            ],
          ),
          const SizedBox(height: 12),
          ...sessions.map((session) => PlannedSessionItem(session: session)),
        ],
      ),
    );
  }
}
