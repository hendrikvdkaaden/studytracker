import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../widgets/add_goal/clickable_field.dart';
import '../../widgets/add_goal/custom_text_field.dart';
import '../../widgets/add_goal/fixed_footer_button.dart';
import '../../widgets/add_goal/goal_type_selector.dart';

/// Layout template for the add goal screen
class AddGoalTemplate extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController subjectController;
  final DateTime selectedDate;
  final GoalType selectedType;
  final String formattedDate;
  final String formattedStudyTime;
  final Function(GoalType) onTypeSelected;
  final VoidCallback onDateTap;
  final VoidCallback onStudyTimeTap;
  final VoidCallback onSave;

  const AddGoalTemplate({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.subjectController,
    required this.selectedDate,
    required this.selectedType,
    required this.formattedDate,
    required this.formattedStudyTime,
    required this.onTypeSelected,
    required this.onDateTap,
    required this.onStudyTimeTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildForm(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _buildTitleField(),
          const SizedBox(height: 24),
          _buildSubjectField(),
          const SizedBox(height: 32),
          _buildTypeSelector(),
          const SizedBox(height: 32),
          _buildDeadlineField(),
          const SizedBox(height: 32),
          _buildStudyTimeField(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return CustomTextField(
      label: 'Goal Title',
      hintText: 'e.g., Final Project',
      controller: titleController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a goal title';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectField() {
    return CustomTextField(
      label: 'Subject',
      hintText: 'e.g., Computer Science',
      controller: subjectController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a subject';
        }
        return null;
      },
    );
  }

  Widget _buildTypeSelector() {
    return GoalTypeSelector(
      selectedType: selectedType,
      onTypeSelected: onTypeSelected,
    );
  }

  Widget _buildDeadlineField() {
    return ClickableField(
      label: 'Deadline',
      displayText: formattedDate,
      icon: Icons.calendar_month,
      onTap: onDateTap,
    );
  }

  Widget _buildStudyTimeField() {
    return ClickableField(
      label: 'Target Study Time',
      subtitle: 'Total hours planned for this goal',
      displayText: formattedStudyTime,
      icon: Icons.access_time,
      onTap: onStudyTimeTap,
    );
  }

  Widget _buildFooter() {
    return FixedFooterButton(
      text: 'Add Goal',
      onPressed: onSave,
    );
  }
}
