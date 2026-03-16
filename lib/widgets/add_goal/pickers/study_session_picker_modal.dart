import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/format_helpers.dart';
import '../../../utils/l10n_extension.dart';
import 'package:uuid/uuid.dart';
import 'duration_picker_modal.dart';

class StudySessionPickerModal extends StatefulWidget {
  final void Function(StudySession session) onSessionAdded;
  final List<StudySession> existingSessions;
  final StudySession? initialSession; // non-null = edit mode

  const StudySessionPickerModal({
    super.key,
    required this.onSessionAdded,
    this.existingSessions = const [],
    this.initialSession,
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
      final ctx = _notesKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
    });
  }

  Future<void> _pickDuration() async {
    final result = await showDurationPickerModal(
      context: context,
      initialHours: durationHours,
      initialMinutes: durationMinutes,
    );
    if (result != null) {
      setState(() {
        durationHours = result.hours;
        durationMinutes = result.minutes;
        _overlapError = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duration must be greater than 0'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    widget.onSessionAdded(session);
    FocusManager.instance.primaryFocus?.unfocus();

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    messenger.showSnackBar(
      SnackBar(
        content: Text(isEditing ? context.l10n.sessionPickerSaveEditButton : context.l10n.sessionPickerSaveButton),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDate(DateTime d) => FormatHelpers.formatDate(d);

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSession != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightCard;
    final sectionBg =
        isDark ? const Color(0xFF1A2035) : const Color(0xFFF9FAFB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;
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
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
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
                IconButton(
                  icon: Icon(Icons.close, color: subtleText),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey[100],
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey[100],
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + keyboardInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  _buildSectionHeader(
                    label: context.l10n.sessionPickerDateLabel,
                    icon: Icons.calendar_month,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF135BEC),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTappableCard(
                    onTap: _pickDate,
                    isDark: isDark,
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
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFEA6C0A),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: sectionBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _overlapError != null
                            ? AppColors.overdue
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFE5E7EB)),
                        width: _overlapError != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepper(
                          isDark: isDark,
                          label: context.l10n.sessionPickerHours,
                          value: selectedHour,
                          max: 23,
                          onChanged: (v) => setState(() {
                            selectedHour = v;
                            _overlapError = null;
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            ' : ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        _buildStepper(
                          isDark: isDark,
                          label: context.l10n.sessionPickerMinutes,
                          value: selectedMinute,
                          max: 59,
                          onChanged: (v) => setState(() {
                            selectedMinute = v;
                            _overlapError = null;
                          }),
                        ),
                      ],
                    ),
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
                    iconBg: const Color(0xFFF5F3FF),
                    iconColor: const Color(0xFF7C3AED),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    key: _notesKey,
                    decoration: BoxDecoration(
                      color: sectionBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE5E7EB),
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
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF059669),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTappableCard(
                    onTap: _pickDuration,
                    isDark: isDark,
                    sectionBg: sectionBg,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${durationHours}u ${durationMinutes}m',
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
                  const SizedBox(height: 32),

                  // Add button
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF135BEC), Color(0xFF4489FF)],
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
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
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
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper({
    required bool isDark,
    required String label,
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final valueColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey[100]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: valueColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _stepButton(
              icon: Icons.remove,
              onTap: () {
                if (value > 0) onChanged(value - 1);
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _stepButton(
              icon: Icons.add,
              onTap: () {
                if (value < max) onChanged(value + 1);
              },
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[300] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildTappableCard({
    required VoidCallback onTap,
    required bool isDark,
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
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE5E7EB)),
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
      );
    },
  );
}

Future<void> showStudySessionEditor({
  required BuildContext context,
  required StudySession session,
  required void Function(StudySession updated) onSessionUpdated,
  List<StudySession> existingSessions = const [],
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext context) {
      return StudySessionPickerModal(
        onSessionAdded: onSessionUpdated,
        // Exclude the session being edited from overlap check
        existingSessions:
            existingSessions.where((s) => s.id != session.id).toList(),
        initialSession: session,
      );
    },
  );
}
