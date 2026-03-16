import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/add_goal/fields/clickable_field.dart';
import '../../widgets/add_goal/fields/custom_text_field.dart';
import '../../widgets/add_goal/fields/goal_type_selector.dart';
import '../../utils/format_helpers.dart';
import '../../widgets/add_goal/sessions/planned_sessions_list.dart';
import '../../widgets/common/subject_selector_field.dart';

class AddGoalTemplate extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController subjectController;
  final DateTime selectedDate;
  final GoalType selectedType;
  final String formattedDate;
  final List<StudySession> plannedSessions;
  final List<SubjectData> subjects;
  final String? selectedSubject;
  final ValueChanged<String> onSubjectSelected;
  final Function(GoalType) onTypeSelected;
  final VoidCallback onDateTap;
  final VoidCallback onSessionTap;
  final VoidCallback onAutoplan;
  final Function(int) onSessionDelete;
  final Function(int) onSessionEdit;
  final VoidCallback onSave;

  const AddGoalTemplate({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.subjectController,
    required this.selectedDate,
    required this.selectedType,
    required this.formattedDate,
    required this.plannedSessions,
    required this.subjects,
    required this.onSubjectSelected,
    required this.onTypeSelected,
    required this.onDateTap,
    required this.onSessionTap,
    required this.onAutoplan,
    required this.onSessionDelete,
    required this.onSessionEdit,
    required this.onSave,
    this.selectedSubject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Form(
      key: formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + bottomInset),
        children: [
          // Title
          CustomTextField(
            label: 'Title',
            hintText: 'Final Project',
            controller: titleController,
            icon: Icons.edit_outlined,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: AppColors.primary,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Subject
          _buildSubjectSection(context, isDark, subtleText),
          const SizedBox(height: 24),

          // Deadline
          ClickableField(
            label: 'Deadline',
            displayText: formattedDate,
            icon: Icons.calendar_month,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFEA6C0A),
            onTap: onDateTap,
          ),
          const SizedBox(height: 24),

          // Type
          GoalTypeSelector(
            selectedType: selectedType,
            onTypeSelected: onTypeSelected,
          ),
          const SizedBox(height: 24),

          // Sessions
          _buildSessionsSection(context, isDark, subtleText),
          const SizedBox(height: 32),

          // Save button
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF135BEC), Color(0xFF4489FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.check, size: 18),
              label: const Text(
                'Add Deadline',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSection(
      BuildContext context, bool isDark, Color subtleText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF059669).withValues(alpha: 0.15)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book_outlined,
                  size: 17, color: Color(0xFF059669)),
            ),
            const SizedBox(width: 10),
            Text(
              'SUBJECT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: subtleText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SubjectSelectorField(
          subjects: subjects,
          selectedSubject: selectedSubject,
          controller: subjectController,
          onSubjectSelected: onSubjectSelected,
          validator: (value) {
            if (subjects.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return 'Please select a subject';
              }
            } else {
              if (subjectController.text.isEmpty) {
                return 'Please enter a subject';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSessionsSection(
      BuildContext context, bool isDark, Color subtleText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: const Icon(Icons.bolt,
                  size: 17, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'STUDY SESSIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: subtleText,
                ),
              ),
            ),
            // Plan voor mij button
            GestureDetector(
              onTap: onAutoplan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    Icon(Icons.auto_awesome,
                        size: 13,
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.9)
                            : AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Plan for me',
                      style: TextStyle(
                        fontSize: 11,
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
        const SizedBox(height: 10),
        if (plannedSessions.isNotEmpty) ...[
          PlannedSessionsList(
            sessions: plannedSessions,
            onDelete: onSessionDelete,
            onEdit: onSessionEdit,
          ),
          const SizedBox(height: 12),
        ],
        // Footer: full-width card when empty, summary+pill when list has items
        if (plannedSessions.isEmpty)
          GestureDetector(
            onTap: onSessionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A2035)
                    : const Color(0xFFF9FAFB),
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
                      'Add study session',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),
                  Icon(Icons.add,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      size: 20),
                ],
              ),
            ),
          )
        else
          Row(
          children: [
            Text(
              '${plannedSessions.length} session${plannedSessions.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : const Color(0xFF374151),
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
              FormatHelpers.formatTime(
                plannedSessions.fold(0, (s, e) => s + e.duration),
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : const Color(0xFF374151),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSessionTap,
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
                    Icon(Icons.add,
                        size: 14,
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.9)
                            : AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Add session',
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
    );
  }
}

