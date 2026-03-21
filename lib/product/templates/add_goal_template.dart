import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/l10n_extension.dart';
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
            label: context.l10n.addGoalTitleLabel,
            hintText: context.l10n.addGoalTitleHint,
            controller: titleController,
            icon: Icons.edit_outlined,
            iconBg: AppColors.iconBgTeal,
            iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.addGoalValidateTitle;
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
            label: context.l10n.addGoalDeadlineLabel,
            displayText: formattedDate,
            icon: Icons.calendar_month,
            iconBg: AppColors.iconBgOrange,
            iconColor: AppColors.iconOrange,
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
                colors: [AppColors.primary, AppColors.primaryLight],
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
              label: Text(
                context.l10n.addGoalSaveButtonLabel,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    ? AppColors.iconGreen.withValues(alpha: 0.15)
                    : AppColors.iconBgGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book_outlined,
                  size: 17, color: AppColors.iconGreen),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.addGoalSubjectLabel.toUpperCase(),
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
                return context.l10n.addGoalValidateSubject;
              }
            } else {
              if (subjectController.text.isEmpty) {
                return context.l10n.addGoalValidateSubject;
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
                    ? AppColors.iconPurple.withValues(alpha: 0.15)
                    : AppColors.iconBgPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt,
                  size: 17, color: AppColors.iconPurple),
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
            // Plan voor mij button
            GestureDetector(
              onTap: onAutoplan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.iconPurple.withValues(alpha: 0.15)
                      : AppColors.iconBgPurple,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.iconPurple.withValues(alpha: 0.3)
                        : AppColors.iconPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 13,
                        color: isDark
                            ? AppColors.iconPurple.withValues(alpha: 0.9)
                            : AppColors.iconPurple),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.addGoalAutoPlanButton,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.iconPurple.withValues(alpha: 0.9)
                            : AppColors.iconPurple,
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
                    ? AppColors.sectionDarkBg
                    : AppColors.sectionLightBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.addGoalAddSessionButton,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.darkText,
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
              context.l10n.addGoalSessionCount(plannedSessions.length),
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
              FormatHelpers.formatTime(
                plannedSessions.fold(0, (s, e) => s + e.duration),
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : AppColors.textSecondary,
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
                      : AppColors.iconBgTeal,
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
                      context.l10n.addGoalAddSessionShort,
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

