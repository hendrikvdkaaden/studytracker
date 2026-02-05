import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import 'planned_session_item.dart';

class PlannedSessionsList extends StatelessWidget {
  final List<StudySession> sessions;
  final Function(int index) onDelete;

  const PlannedSessionsList({
    super.key,
    required this.sessions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate total planned time
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );
    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;

    String totalTimeText = '';
    if (totalHours > 0 && remainingMinutes > 0) {
      totalTimeText = '${totalHours}h ${remainingMinutes}m';
    } else if (totalHours > 0) {
      totalTimeText = '${totalHours}h';
    } else {
      totalTimeText = '${remainingMinutes}m';
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF135BEC).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF135BEC).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Planned Sessions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF135BEC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${sessions.length} session${sessions.length != 1 ? 's' : ''} • $totalTimeText',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;
            return PlannedSessionItem(
              session: session,
              onDelete: () => onDelete(index),
            );
          }),
        ],
      ),
    );
  }
}
