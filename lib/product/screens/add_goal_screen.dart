import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/goal_repository.dart';
import '../../services/study_session_repository.dart';
import '../../widgets/add_goal/pickers/study_session_picker_modal.dart';
import '../templates/add_goal_template.dart';

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
  final StudySessionRepository _sessionRepo = StudySessionRepository();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  GoalType _selectedType = GoalType.exam;
  final List<StudySession> _plannedSessions = [];

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

  int _calculateTotalStudyTime() {
    int totalMinutes = 0;
    for (var session in _plannedSessions) {
      totalMinutes += session.duration;
    }
    return totalMinutes;
  }

  Future<void> _showStudySessionPicker() async {
    FocusScope.of(context).unfocus();
    await showStudySessionPicker(
      context: context,
      onSessionAdded: (session) {
        setState(() {
          _plannedSessions.add(session);
        });
      },
    );
    if (mounted) FocusScope.of(context).unfocus();
  }

  void _deleteSession(int index) {
    setState(() {
      _plannedSessions.removeAt(index);
    });
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final totalMinutes = _calculateTotalStudyTime();

      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text,
        subject: _subjectController.text,
        date: _selectedDate,
        type: _selectedType,
        difficulty: Difficulty.medium,
        studyTime: totalMinutes,
      );

      // Save goal first
      await _goalRepo.addGoal(goal);

      // Save planned sessions with the goal ID
      for (var session in _plannedSessions) {
        final sessionWithGoalId = session.copyWith(goalId: goal.id);
        await _sessionRepo.addSession(sessionWithGoalId);
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _plannedSessions.isEmpty
                ? 'Goal added successfully!'
                : 'Goal and ${_plannedSessions.length} session${_plannedSessions.length != 1 ? 's' : ''} added!',
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8),
      appBar: _buildAppBar(isDark),
      body: AddGoalTemplate(
        formKey: _formKey,
        titleController: _titleController,
        subjectController: _subjectController,
        selectedDate: _selectedDate,
        selectedType: _selectedType,
        formattedDate: _formatDate(_selectedDate),
        plannedSessions: _plannedSessions,
        onTypeSelected: (type) => setState(() => _selectedType = type),
        onDateTap: () => _selectDate(context),
        onSessionTap: _showStudySessionPicker,
        onSessionDelete: _deleteSession,
        onSave: _saveGoal,
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
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
    );
  }
}
