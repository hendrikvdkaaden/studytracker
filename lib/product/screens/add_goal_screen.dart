import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../providers/app_providers.dart';
import '../../services/auto_planner_service.dart';
import '../../services/goal_repository.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../services/subscription_service.dart';
import '../../services/study_session_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/format_helpers.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/add_goal/pickers/auto_plan_wizard_modal.dart';
import '../../widgets/add_goal/pickers/study_session_picker_modal.dart';
import '../../widgets/common/premium_gate_bottom_sheet.dart';
import '../templates/add_goal_template.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  GoalRepository get _goalRepo => ref.read(goalRepositoryProvider);
  StudySessionRepository get _sessionRepo => ref.read(studySessionRepositoryProvider);

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
      deadline: _selectedDate,
      onSessionAdded: (session) {
        setState(() {
          _plannedSessions.add(session);
          _sortSessions();
        });
      },
    );
    if (mounted) FocusScope.of(context).unfocus();
  }

  void _sortSessions() {
    _plannedSessions.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      final aStart = a.startTime;
      final bStart = b.startTime;
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      return aStart.compareTo(bStart);
    });
  }

  void _deleteSession(int index) {
    setState(() {
      _plannedSessions.removeAt(index);
    });
  }

  Future<void> _editSession(int index) async {
    FocusScope.of(context).unfocus();
    await showStudySessionEditor(
      context: context,
      session: _plannedSessions[index],
      existingSessions: _plannedSessions,
      deadline: _selectedDate,
      onSessionUpdated: (updated) {
        setState(() {
          _plannedSessions[index] = updated;
          _sortSessions();
        });
      },
    );
  }

  void _onSubjectSelected(String subject) {
    setState(() => _selectedSubject = subject);
  }

  Future<void> _autoPlanSessions() async {
    final isPremium = await ref.read(subscriptionServiceProvider).isPremium();
    if (!mounted) return;
    if (!isPremium) {
      final purchased = await showPremiumGateSheet(
        context,
        title: context.l10n.premiumAutoPlanTitle,
        message: context.l10n.premiumAutoPlanMessage,
      );
      if (!purchased || !mounted) return;
    }

    if (!mounted) return;
    final result = await showAutoPlanWizard(context: context);
    if (result == null || !mounted) return;

    final existing = _sessionRepo.getAllPlannedSessions();

    final generated = AutoPlannerService.generateSessions(
      goalId: '',
      deadline: _selectedDate,
      totalMinutes: result.totalMinutes,
      weekdays: result.weekdays,
      startHour: result.startHour,
      startMinute: result.startMinute,
      endHour: result.endHour,
      endMinute: result.endMinute,
      sessionDuration: result.sessionDuration,
      breakMinutes: result.breakMinutes,
      existingSessions: existing,
    );

    if (!mounted) return;

    if (generated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.autoPlanErrorNoAvailableDays),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _plannedSessions.clear();
      _plannedSessions.addAll(generated);
      _sortSessions();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.autoPlanSuccessSnack(generated.length)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final isPremium = await ref.read(subscriptionServiceProvider).isPremium();
      if (!mounted) return;
      if (!isPremium) {
        final goals = _goalRepo.getAllGoals();
        if (goals.length >= SubscriptionService.freeGoalLimit) {
          final purchased = await showPremiumGateSheet(
            context,
            title: context.l10n.premiumGoalLimitTitle,
            message: context.l10n.premiumGoalLimitMessage,
          );
          if (!purchased || !mounted) return;
        }
      }

      final totalMinutes = _calculateTotalStudyTime();
      final subjectValue = _subjects.isNotEmpty
          ? (_selectedSubject ?? '')
          : _subjectController.text;

      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
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
          content: Text(context.l10n.addGoalSuccessSnack(_plannedSessions.length)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(context),
      body: AddGoalTemplate(
        formKey: _formKey,
        titleController: _titleController,
        subjectController: _subjectController,
        selectedDate: _selectedDate,
        selectedType: _selectedType,
        formattedDate: FormatHelpers.formatDate(_selectedDate),
        plannedSessions: _plannedSessions,
        subjects: _subjects,
        selectedSubject: _selectedSubject,
        onSubjectSelected: _onSubjectSelected,
        onTypeSelected: (type) => setState(() => _selectedType = type),
        onDateTap: () => _selectDate(context),
        onSessionTap: _showStudySessionPicker,
        onAutoplan: _autoPlanSessions,
        onSessionDelete: _deleteSession,
        onSessionEdit: _editSession,
        onSave: _saveGoal,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: context.colors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.l10n.addGoalScreenTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.colors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: context.colors.divider,
          height: 1,
        ),
      ),
    );
  }
}
