import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StudyTimePickerModal extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;
  final Function(int hours, int minutes) onTimeSelected;

  const StudyTimePickerModal({
    super.key,
    required this.initialHours,
    required this.initialMinutes,
    required this.onTimeSelected,
  });

  @override
  State<StudyTimePickerModal> createState() => _StudyTimePickerModalState();
}

class _StudyTimePickerModalState extends State<StudyTimePickerModal> {
  late int tempHours;
  late int tempMinutes;

  @override
  void initState() {
    super.initState();
    tempHours = widget.initialHours;
    tempMinutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF135BEC),
                      fontSize: 16,
                    ),
                  ),
                ),
                const Text(
                  'Target Study Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onTimeSelected(tempHours, tempMinutes);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Color(0xFF135BEC),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Pickers
          Expanded(
            child: Row(
              children: [
                // Hours Picker
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'HOURS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: tempHours,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              tempHours = index;
                            });
                          },
                          children: List<Widget>.generate(100, (int index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 200,
                  color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                ),
                // Minutes Picker
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MINUTES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: tempMinutes ~/ 5,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              tempMinutes = index * 5;
                            });
                          },
                          children: List<Widget>.generate(12, (int index) {
                            return Center(
                              child: Text(
                                (index * 5).toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showStudyTimePicker({
  required BuildContext context,
  required int initialHours,
  required int initialMinutes,
  required Function(int hours, int minutes) onTimeSelected,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StudyTimePickerModal(
        initialHours: initialHours,
        initialMinutes: initialMinutes,
        onTimeSelected: onTimeSelected,
      );
    },
  );
}
