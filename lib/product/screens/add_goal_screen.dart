import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/goal_repository.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart'; // also imports SubjectData
import '../../services/study_session_repository.dart';
import '../../theme/app_colors.dart';
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
  List<SubjectData> _subjects = [];
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _subjects = SettingsService.subjectData;
  }

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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
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
      existingSessions: _plannedSessions,
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

  void _onSubjectSelected(String subject) {
    setState(() => _selectedSubject = subject);
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final totalMinutes = _calculateTotalStudyTime();
      final subjectValue = _subjects.isNotEmpty
          ? (_selectedSubject ?? '')
          : _subjectController.text;

      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text,
        subject: subjectValue,
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
        await NotificationService.scheduleSessionReminder(
          sessionWithGoalId,
          goal.title,
        );
      }

      // Schedule deadline reminder
      await NotificationService.scheduleDeadlineReminder(goal);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _plannedSessions.isEmpty
                ? 'Deadline added successfully!'
                : 'Deadline and ${_plannedSessions.length} session${_plannedSessions.length != 1 ? 's' : ''} added!',
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
        subjects: _subjects,
        selectedSubject: _selectedSubject,
        onSubjectSelected: _onSubjectSelected,
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
        'Create Deadline',
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
