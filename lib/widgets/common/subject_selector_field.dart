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

    return _SubjectDropdown(
      subjects: subjects,
      selectedSubject: selectedSubject,
      onSubjectSelected: onSubjectSelected,
      validator: validator,
    );
  }
}

class _SubjectDropdown extends StatelessWidget {
  final List<SubjectData> subjects;
  final String? selectedSubject;
  final ValueChanged<String> onSubjectSelected;
  final String? Function(String?)? validator;

  const _SubjectDropdown({
    required this.subjects,
    required this.onSubjectSelected,
    this.selectedSubject,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionBg = isDark ? AppColors.sectionDarkBg : AppColors.sectionLightBg;

    return DropdownButtonFormField<String>(
      initialValue: selectedSubject,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: sectionBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.overdue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.overdue, width: 1.5),
        ),
      ),
      dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(16),
      hint: Text(
        'Select a subject',
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
      ),
      selectedItemBuilder: (context) => subjects.map((s) {
        final color = s.name == selectedSubject ? s.color : null;
        return Row(
          children: [
            if (color != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              s.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.darkText,
              ),
            ),
          ],
        );
      }).toList(),
      items: subjects.map((s) {
        final isSelected = s.name == selectedSubject;
        return DropdownMenuItem<String>(
          value: s.name,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                s.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white : AppColors.darkText),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onSubjectSelected(value);
      },
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: isDark ? Colors.grey[400] : Colors.grey[500],
      ),
    );
  }
}
