import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import 'package:uuid/uuid.dart';
import 'duration_picker_modal.dart';
import 'time_picker_modal.dart';

class StudySessionPickerModal extends StatefulWidget {
  final Function(StudySession session) onSessionAdded;

  const StudySessionPickerModal({
    super.key,
    required this.onSessionAdded,
  });

  @override
  State<StudySessionPickerModal> createState() =>
      _StudySessionPickerModalState();
}

class _StudySessionPickerModalState extends State<StudySessionPickerModal> {
  DateTime selectedDate = DateTime.now();
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  int durationHours = 1;
  int durationMinutes = 0;
  final TextEditingController notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  final GlobalKey _notesKey = GlobalKey();

  @override
  void dispose() {
    notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _scrollToNotes() {
    Future.delayed(const Duration(milliseconds: 400), () {
      final context = _notesKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
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
      });
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePickerModal(
      context: context,
      initialHour: selectedHour,
      initialMinute: selectedMinute,
    );
    if (result != null) {
      setState(() {
        selectedHour = result.hour;
        selectedMinute = result.minute;
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
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF135BEC),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
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

    final session = StudySession(
      id: const Uuid().v4(),
      goalId: '', // Will be set when goal is created
      date: selectedDate,
      duration: totalDuration,
      isCompleted: false,
      startTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedHour,
        selectedMinute,
      ),
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    widget.onSessionAdded(session);

    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session added!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Color(0xFF135BEC),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  'Plan Study Session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Date', isDark),
                  const SizedBox(height: 8),
                  _buildSelectableField(
                    onTap: _pickDate,
                    label:
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    icon: Icons.calendar_today,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Start Time', isDark),
                  const SizedBox(height: 8),
                  _buildSelectableField(
                    onTap: _pickTime,
                    label:
                        '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                    icon: Icons.access_time,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Notes (Optional)', isDark),
                  const SizedBox(height: 8),
                  TextField(
                    key: _notesKey,
                    controller: notesController,
                    focusNode: _notesFocusNode,
                    onTap: _scrollToNotes,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'What will you study?',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFF6F6F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildSectionTitle('Duration', isDark),
                  const SizedBox(height: 8),
                  _buildSelectableField(
                    onTap: _pickDuration,
                    label: '${durationHours}h ${durationMinutes}m',
                    icon: Icons.schedule,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  // Add Session Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF135BEC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add Session',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[300] : Colors.grey[800],
      ),
    );
  }

  Widget _buildSelectableField({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF6F6F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Icon(icon, size: 20),
          ],
        ),
      ),
    );
  }
}

Future<void> showStudySessionPicker({
  required BuildContext context,
  required Function(StudySession session) onSessionAdded,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext context) {
      return StudySessionPickerModal(
        onSessionAdded: onSessionAdded,
      );
    },
  );
}
