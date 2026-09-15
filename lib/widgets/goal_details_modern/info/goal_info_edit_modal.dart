import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/goal_type_helper.dart';
import '../../../utils/l10n_extension.dart';
import '../../common/subject_selector_field.dart';

Future<Goal?> showGoalInfoEditModal(
  BuildContext context,
  Goal goal,
) {
  return showModalBottomSheet<Goal>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Leave a strip of the screen visible so the sheet can still be swiped
    // down or dismissed by tapping outside it.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.92,
    ),
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
  late List<SubjectData> _subjects;
  String? _selectedSubject;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _subjectController = TextEditingController(text: widget.goal.subject);
    _selectedType = widget.goal.type;
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
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final subject = _subjects.isNotEmpty
        ? (_selectedSubject ?? '')
        : _subjectController.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMessage = l10n.goalInfoEditValidateTitle);
      return;
    }
    if (subject.isEmpty) {
      setState(() => _errorMessage = l10n.goalInfoEditValidateSubject);
      return;
    }
    setState(() => _errorMessage = null);

    final updated = widget.goal.copyWith(
      title: title,
      subject: subject,
      type: _selectedType,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.colors.modalBackground;
    final textColor = context.colors.textPrimary;
    final subTextColor = context.colors.accent;
    final fieldFill = context.colors.fieldBackground;
    final borderColor = context.colors.border;

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
                  context.l10n.goalInfoEditModalTitle,
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
                    context.l10n.btnCancel,
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
                    context.l10n.goalInfoEditTitleLabel,
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
                      hintText: context.l10n.goalInfoEditTitleHint,
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
                        borderSide: BorderSide(
                          color: context.colors.accentStrong,
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
                    context.l10n.goalInfoEditTypeLabel,
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
                                ? context.colors.accentStrong.withValues(alpha: 0.2)
                                : fieldFill,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? context.colors.accentStrong
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
                                      ? context.colors.accentStrong
                                      : subTextColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  GoalTypeHelper.getLocalizedLabel(context, type),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? context.colors.accentStrong
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
                  const SizedBox(height: 28),

                  if (_errorMessage != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: AppColors.overdue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.overdue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.goalInfoEditSaveButton,
                        style: const TextStyle(
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
