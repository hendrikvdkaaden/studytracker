import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/goal_repository.dart';
import '../widgets/add_goal/date_selector.dart';
import '../widgets/add_goal/title_field.dart';
import '../widgets/add_goal/subject_field.dart';
import '../widgets/add_goal/type_dropdown.dart';
import '../widgets/add_goal/difficulty_dropdown.dart';
import '../widgets/add_goal/study_time_field.dart';
import '../widgets/add_goal/action_buttons.dart';

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
  Difficulty _selectedDifficulty = Difficulty.medium;
  int _studyTimeMinutes = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text,
        subject: _subjectController.text,
        date: _selectedDate,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        studyTime: _studyTimeMinutes,
      );

      _goalRepo.addGoal(goal);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TitleField(controller: _titleController),
            const SizedBox(height: 16),
            SubjectField(controller: _subjectController),
            const SizedBox(height: 16),
            TypeDropdown(
              selectedType: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            DifficultyDropdown(
              selectedDifficulty: _selectedDifficulty,
              onChanged: (value) => setState(() => _selectedDifficulty = value),
            ),
            const SizedBox(height: 16),
            DateSelector(
              selectedDate: _selectedDate,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            StudyTimeField(
              initialMinutes: _studyTimeMinutes,
              onChanged: (minutes) => setState(() => _studyTimeMinutes = minutes),
            ),
            const SizedBox(height: 24),
            ActionButtons(
              onCancel: () => Navigator.pop(context),
              onSave: _saveGoal,
            ),
          ],
        ),
      ),
    );
  }
}
