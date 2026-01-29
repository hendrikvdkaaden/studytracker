import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/goal_repository.dart';
import '../widgets/add_goal/study_time_picker_modal.dart';
import '../widgets/add_goal/custom_text_field.dart';
import '../widgets/add_goal/clickable_field.dart';
import '../widgets/add_goal/goal_type_selector.dart';
import '../widgets/add_goal/fixed_footer_button.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final GoalRepository _goalRepo = GoalRepository();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  GoalType _selectedType = GoalType.exam;
  int _studyTimeHours = 0;
  int _studyTimeMinutes = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF135BEC),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _showStudyTimePicker() async {
    await showStudyTimePicker(
      context: context,
      initialHours: _studyTimeHours,
      initialMinutes: _studyTimeMinutes,
      onTimeSelected: (hours, minutes) {
        setState(() {
          _studyTimeHours = hours;
          _studyTimeMinutes = minutes;
        });
      },
    );
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final totalMinutes = (_studyTimeHours * 60) + _studyTimeMinutes;

      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text,
        subject: _subjectController.text,
        date: _selectedDate,
        type: _selectedType,
        difficulty: Difficulty.medium,
        studyTime: totalMinutes,
      );

      _goalRepo.addGoal(goal);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal added successfully!')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    return '$month $day, $year';
  }

  String _formatStudyTime() {
    if (_studyTimeHours == 0 && _studyTimeMinutes == 0) {
      return 'Select study time';
    }
    return '${_studyTimeHours}h ${_studyTimeMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Goal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Title Field
                CustomTextField(
                  label: 'Goal Title',
                  hintText: 'e.g., Final Project',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Subject Field
                CustomTextField(
                  label: 'Subject',
                  hintText: 'e.g., Computer Science',
                  controller: _subjectController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Goal Type Selector
                GoalTypeSelector(
                  selectedType: _selectedType,
                  onTypeSelected: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
                const SizedBox(height: 32),
                // Deadline Field
                ClickableField(
                  label: 'Deadline',
                  displayText: _formatDate(_selectedDate),
                  icon: Icons.calendar_month,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 32),
                // Target Study Time Field
                ClickableField(
                  label: 'Target Study Time',
                  subtitle: 'Total hours planned for this goal',
                  displayText: _formatStudyTime(),
                  icon: Icons.access_time,
                  onTap: _showStudyTimePicker,
                ),
              ],
            ),
          ),
          // Fixed Footer
          FixedFooterButton(
            text: 'Add Goal',
            onPressed: _saveGoal,
          ),
        ],
      ),
    );
  }
}
