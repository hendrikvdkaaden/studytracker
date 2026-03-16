import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../add_goal/fields/custom_text_field.dart';

class SubjectSelectorField extends StatelessWidget {
  final List<SubjectData> subjects;
  final String? selectedSubject;
  // Required when subjects is empty (fallback free-text mode)
  final TextEditingController? controller;
  final ValueChanged<String> onSubjectSelected;
  final String? Function(String?)? validator;

  const SubjectSelectorField({
    super.key,
    required this.subjects,
    required this.onSubjectSelected,
    this.selectedSubject,
    this.controller,
    this.validator,
  }) : assert(
          subjects.length > 0 || controller != null,
          'SubjectSelectorField: controller must not be null when subjects is empty',
        );

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return CustomTextField(
        label: 'Subject',
        hintText: 'Computer Science',
        controller: controller!,
        validator: validator,
      );
    }

    return _SubjectSelectorWithList(
      subjects: subjects,
      selectedSubject: selectedSubject,
      onSubjectSelected: onSubjectSelected,
      validator: validator,
    );
  }
}

class _SubjectSelectorWithList extends StatelessWidget {
  final List<SubjectData> subjects;
  final String? selectedSubject;
  final ValueChanged<String> onSubjectSelected;
  final String? Function(String?)? validator;

  const _SubjectSelectorWithList({
    required this.subjects,
    required this.onSubjectSelected,
    this.selectedSubject,
    this.validator,
  });

  Future<void> _openSheet(
    BuildContext context,
    FormFieldState<String> field,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select a subject',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...subjects.map((subjectData) {
                final isSelected = subjectData.name == selectedSubject;
                return ListTile(
                  leading: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: subjectData.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    subjectData.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    onSubjectSelected(subjectData.name);
                    // field is a local parameter — no stored reference, no leak
                    field.didChange(subjectData.name);
                  },
                );
              }),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }

  String? _validate(String? _) {
    if (validator != null) {
      return validator!(selectedSubject);
    }
    return null;
  }

  Color? get _selectedColor {
    if (selectedSubject == null) return null;
    for (final s in subjects) {
      if (s.name == selectedSubject) return s.color;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSelection = selectedSubject?.isNotEmpty == true;
    final displayText = hasSelection ? selectedSubject! : 'Select a subject';
    final subjectColor = _selectedColor;

    final sectionBg =
        isDark ? const Color(0xFF1A2035) : const Color(0xFFF9FAFB);

    return FormField<String>(
      validator: _validate,
      builder: (field) {
        final hasError = field.errorText != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openSheet(context, field),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: sectionBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasError
                        ? AppColors.overdue
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE5E7EB)),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (hasSelection && subjectColor != null) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: subjectColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: !hasSelection
                              ? (isDark ? Colors.grey[500] : Colors.grey[400])
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF111827)),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (field.errorText != null) ...[
              const SizedBox(height: 6),
              Text(
                field.errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.overdue,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
