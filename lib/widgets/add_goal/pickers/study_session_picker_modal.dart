import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/format_helpers.dart';
import '../../../utils/l10n_extension.dart';
import 'package:uuid/uuid.dart';
import '../../common/inline_time_stepper.dart';

class StudySessionPickerModal extends StatefulWidget {
  final void Function(StudySession session) onSessionAdded;
  final List<StudySession> existingSessions;
  final StudySession? initialSession; // non-null = edit mode
  final DateTime? deadline;

  const StudySessionPickerModal({
    super.key,
    required this.onSessionAdded,
    this.existingSessions = const [],
    this.initialSession,
    this.deadline,
  });

  @override
  State<StudySessionPickerModal> createState() =>
      _StudySessionPickerModalState();
}

class _StudySessionPickerModalState extends State<StudySessionPickerModal> {
  late DateTime selectedDate;
  late int selectedHour;
  late int selectedMinute;
  int durationHours = 1;
  int durationMinutes = 0;
  final TextEditingController notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  final GlobalKey _notesKey = GlobalKey();
  String? _overlapError;
  String? _durationError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSession;
    if (initial != null) {
      selectedDate = initial.date;
      selectedHour = initial.startTime?.hour ?? DateTime.now().hour;
      selectedMinute = initial.startTime?.minute ?? DateTime.now().minute;
      durationHours = initial.duration ~/ 60;
      durationMinutes = initial.duration % 60;
      notesController.text = initial.notes ?? '';
    } else {
      final now = DateTime.now();
      selectedDate = now;
      selectedHour = now.hour;
      selectedMinute = now.minute;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _scrollToNotes() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final scrollable = _notesKey.currentContext == null
          ? null
          : Scrollable.maybeOf(_notesKey.currentContext!);
      scrollable?.position.ensureVisible(
        _notesKey.currentContext!.findRenderObject()!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }


  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rawDeadline = widget.deadline;
    final lastDate = rawDeadline != null && !rawDeadline.isBefore(today)
        ? rawDeadline
        : today.add(const Duration(days: 365));
    final clampedInitial = selectedDate.isBefore(today) ? today : selectedDate;
    final date = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: today,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
        _overlapError = null;
      });
    }
  }

  bool _hasOverlap(DateTime newStart, int durationMins) {
    final newEnd = newStart.add(Duration(minutes: durationMins));
    for (final existing in widget.existingSessions) {
      if (existing.startTime == null) continue;
      final existingEnd =
          existing.startTime!.add(Duration(minutes: existing.duration));
      if (newStart.isBefore(existingEnd) &&
          newEnd.isAfter(existing.startTime!)) {
        return true;
      }
    }
    return false;
  }

  void _addSession() {
    final totalDuration = (durationHours * 60) + durationMinutes;

    if (totalDuration == 0) {
      setState(() => _durationError = context.l10n.sessionPickerDurationError);
      return;
    }
    setState(() => _durationError = null);

    final newStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedHour,
      selectedMinute,
    );

    if (_hasOverlap(newStart, totalDuration)) {
      setState(() {
        _overlapError = context.l10n.sessionPickerOverlapError;
      });
      return;
    }

    final isEditing = widget.initialSession != null;
    final session = StudySession(
      id: isEditing ? widget.initialSession!.id : const Uuid().v4(),
      goalId: isEditing ? widget.initialSession!.goalId : '',
      date: selectedDate,
      duration: totalDuration,
      isCompleted: isEditing ? widget.initialSession!.isCompleted : false,
      startTime: newStart,
      // Trimmed so a note of only whitespace is stored as no note at all.
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );

    widget.onSessionAdded(session);
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);
  }

  String _formatDate(DateTime d) => FormatHelpers.formatDate(d);

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSession != null;
    final colors = context.colors;
    final bg = colors.modalBackground;
    final sectionBg = colors.sectionBackground;
    final textColor = colors.textPrimary;
    final subtleText = colors.textSecondary;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: context.colors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? context.l10n.sessionPickerTitleEdit : context.l10n.sessionPickerTitleAdd,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: colors.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey[100],
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + keyboardInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  _buildSectionHeader(
                    label: context.l10n.sessionPickerDateLabel,
                    icon: Icons.calendar_month,
                    iconBg: AppColors.iconBgBlue,
                    iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  _buildTappableCard(
                    onTap: _pickDate,
                    sectionBg: sectionBg,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: subtleText, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Start time
                  _buildSectionHeader(
                    label: context.l10n.sessionPickerStartTimeLabel,
                    icon: Icons.access_time,
                    iconBg: AppColors.iconBgOrange,
                    iconColor: AppColors.iconOrange,
                  ),
                  const SizedBox(height: 12),
                  InlineTimeStepper(
                    backgroundColor: sectionBg,
                    hours: selectedHour,
                    minutes: selectedMinute,
                    maxHours: 23,
                    hasError: _overlapError != null,
                    onHoursChanged: (v) => setState(() {
                      selectedHour = v;
                      _overlapError = null;
                    }),
                    onMinutesChanged: (v) => setState(() {
                      selectedMinute = v;
                      _overlapError = null;
                    }),
                  ),
                  if (_overlapError != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: AppColors.overdue),
                        const SizedBox(width: 4),
                        Text(
                          _overlapError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.overdue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Notes
                  _buildSectionHeader(
                    label: context.l10n.sessionPickerNotesLabel,
                    icon: Icons.edit_note,
                    iconBg: AppColors.iconBgPurple,
                    iconColor: AppColors.iconPurple,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    key: _notesKey,
                    decoration: BoxDecoration(
                      color: sectionBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: TextField(
                      controller: notesController,
                      focusNode: _notesFocusNode,
                      onTap: _scrollToNotes,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.sessionPickerNotesHint,
                        hintStyle: TextStyle(color: subtleText),
                        filled: false,
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Duration
                  _buildSectionHeader(
                    label: context.l10n.sessionPickerDurationLabel,
                    icon: Icons.bolt,
                    iconBg: AppColors.iconBgGreen,
                    iconColor: AppColors.iconGreen,
                  ),
                  const SizedBox(height: 12),
                  InlineTimeStepper(
                    backgroundColor: sectionBg,
                    hours: durationHours,
                    minutes: durationMinutes,
                    maxHours: 8,
                    hasError: _durationError != null,
                    onHoursChanged: (v) => setState(() {
                      durationHours = v;
                      _overlapError = null;
                      _durationError = null;
                    }),
                    onMinutesChanged: (v) => setState(() {
                      durationMinutes = v;
                      _overlapError = null;
                      _durationError = null;
                    }),
                  ),
                  if (_durationError != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: AppColors.overdue),
                        const SizedBox(width: 4),
                        Text(
                          _durationError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.overdue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Add button
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _addSession,
                      icon: Icon(isEditing ? Icons.check : Icons.add, size: 18),
                      label: Text(
                        isEditing ? context.l10n.sessionPickerSaveEditButton : context.l10n.sessionPickerSaveButton,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottomInset),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String label,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.colors.iconChipBackground(iconColor, iconBg),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }


  Widget _buildTappableCard({
    required VoidCallback onTap,
    required Color sectionBg,
    required Widget child,
    bool hasError = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: sectionBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasError
                ? AppColors.overdue
                : (context.colors.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.lightBorder),
            width: hasError ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

Future<void> showStudySessionPicker({
  required BuildContext context,
  required void Function(StudySession session) onSessionAdded,
  List<StudySession> existingSessions = const [],
  DateTime? deadline,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext context) {
      return StudySessionPickerModal(
        onSessionAdded: onSessionAdded,
        existingSessions: existingSessions,
        deadline: deadline,
      );
    },
  );
}

Future<void> showStudySessionEditor({
  required BuildContext context,
  required StudySession session,
  required void Function(StudySession updated) onSessionUpdated,
  List<StudySession> existingSessions = const [],
  DateTime? deadline,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext context) {
      return StudySessionPickerModal(
        onSessionAdded: onSessionUpdated,
        existingSessions:
            existingSessions.where((s) => s.id != session.id).toList(),
        initialSession: session,
        deadline: deadline,
      );
    },
  );
}
