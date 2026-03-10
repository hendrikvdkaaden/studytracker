import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/difficulty_helper.dart';
import '../../../utils/goal_type_helper.dart';
import '../../common/subject_selector_field.dart';

Future<Goal?> showGoalInfoEditModal(
  BuildContext context,
  Goal goal,
) {
  return showModalBottomSheet<Goal>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _GoalInfoEditModal(goal: goal),
  );
}

class _GoalInfoEditModal extends StatefulWidget {
  final Goal goal;

  const _GoalInfoEditModal({required this.goal});

  @override
  State<_GoalInfoEditModal> createState() => _GoalInfoEditModalState();
}

class _GoalInfoEditModalState extends State<_GoalInfoEditModal> {
  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late GoalType _selectedType;
  late Difficulty _selectedDifficulty;
  late List<SubjectData> _subjects;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _subjectController = TextEditingController(text: widget.goal.subject);
    _selectedType = widget.goal.type;
    _selectedDifficulty = widget.goal.difficulty;
    _subjects = SettingsService.subjectData;
    // Only pre-select if the goal's subject still exists in the list
    final subjectExists = _subjects.any((s) => s.name == widget.goal.subject);
    _selectedSubject = subjectExists ? widget.goal.subject : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final subject = _subjects.isNotEmpty
        ? (_selectedSubject ?? '')
        : _subjectController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    final updated = widget.goal.copyWith(
      title: title,
      subject: subject,
      type: _selectedType,
      difficulty: _selectedDifficulty,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.calendarDarkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.lightText : AppColors.darkText;
    final subTextColor = AppColors.upcoming;
    final fieldFill = isDark
        ? AppColors.calendarDarkBackground
        : AppColors.calendarLightBackground;
    final borderColor = isDark
        ? const Color(0xFF2A4340)
        : const Color(0xFFDDE8E7);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Edit Deadline Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: subTextColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Deadline title',
                      hintStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: fieldFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.calendarAccent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject field
                  SubjectSelectorField(
                    subjects: _subjects,
                    selectedSubject: _selectedSubject,
                    controller: _subjectController,
                    onSubjectSelected: (s) =>
                        setState(() => _selectedSubject = s),
                  ),
                  const SizedBox(height: 20),

                  // Goal type
                  Text(
                    'Deadline Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GoalType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return InkWell(
                        onTap: () => setState(() => _selectedType = type),
                        borderRadius: BorderRadius.circular(20),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.calendarAccent.withValues(alpha: 0.2)
                                : fieldFill,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.calendarAccent
                                  : borderColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  GoalTypeHelper.getIconForType(type),
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.calendarAccent
                                      : subTextColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  GoalTypeHelper.getLabel(type),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.calendarAccent
                                        : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Difficulty
                  Text(
                    'Difficulty',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: Difficulty.values.map((diff) {
                      final isSelected = _selectedDifficulty == diff;
                      final color = DifficultyHelper.getAccentColor(diff);
                      final isLast = diff == Difficulty.values.last;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 8),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedDifficulty = diff),
                            borderRadius: BorderRadius.circular(10),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.2)
                                    : fieldFill,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? color : borderColor,
                                ),
                              ),
                              child: SizedBox(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    DifficultyHelper.getLabel(diff),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected ? color : subTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
