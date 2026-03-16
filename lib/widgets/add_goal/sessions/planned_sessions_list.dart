import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import '../../common/planned_session_item.dart';

class PlannedSessionsList extends StatelessWidget {
  final List<StudySession> sessions;
  final Function(int index) onDelete;
  final Function(int index) onEdit;

  const PlannedSessionsList({
    super.key,
    required this.sessions,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card list with dividers — same style as goal details screen
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
                for (int i = 0; i < sessions.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? const Color(0xFF2d4a48)
                          : const Color(0xFFcee8e6),
                    ),
                  PlannedSessionItem(
                    session: sessions[i],
                    index: i,
                    onDelete: () => onDelete(i),
                    onEdit: () => onEdit(i),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
