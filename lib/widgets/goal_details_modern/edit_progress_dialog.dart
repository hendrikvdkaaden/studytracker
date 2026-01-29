import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EditProgressDialog extends StatefulWidget {
  final int initialTargetTimeMinutes;
  final int initialTimeSpentMinutes;
  final Function(int targetTime, int timeSpent) onSave;

  const EditProgressDialog({
    super.key,
    required this.initialTargetTimeMinutes,
    required this.initialTimeSpentMinutes,
    required this.onSave,
  });

  @override
  State<EditProgressDialog> createState() => _EditProgressDialogState();
}

class _EditProgressDialogState extends State<EditProgressDialog> {
  late int _targetHours;
  late int _targetMinutes;
  late int _spentHours;
  late int _spentMinutes;

  @override
  void initState() {
    super.initState();
    _targetHours = widget.initialTargetTimeMinutes ~/ 60;
    _targetMinutes = widget.initialTargetTimeMinutes % 60;
    _spentHours = widget.initialTimeSpentMinutes ~/ 60;
    _spentMinutes = widget.initialTimeSpentMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A2E2D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Edit Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D1C1B),
              ),
            ),
            const SizedBox(height: 24),

            // Target Time Section
            Text(
              'Target Time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF499C95),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Hours',
                    value: _targetHours,
                    max: 100,
                    onChanged: (value) => setState(() => _targetHours = value),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Minutes',
                    value: _targetMinutes,
                    max: 55,
                    step: 5,
                    onChanged: (value) => setState(() => _targetMinutes = value),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Time Spent Section
            Text(
              'Time Spent',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF499C95),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Hours',
                    value: _spentHours,
                    max: 100,
                    onChanged: (value) => setState(() => _spentHours = value),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Minutes',
                    value: _spentMinutes,
                    max: 55,
                    step: 5,
                    onChanged: (value) => setState(() => _spentMinutes = value),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? const Color(0xFF2D4A48) : const Color(0xFFCEE8E6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0D1C1B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final targetTotal = (_targetHours * 60) + _targetMinutes;
                      final spentTotal = (_spentHours * 60) + _spentMinutes;
                      widget.onSave(targetTotal, spentTotal);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0DF2DF),
                      foregroundColor: const Color(0xFF102221),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required int value,
    required int max,
    int step = 1,
    required ValueChanged<int> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF102221) : const Color(0xFFF5F8F8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF2D4A48) : const Color(0xFFCEE8E6),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  if (value > 0) {
                    onChanged(value - step);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Text(
                value.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0D1C1B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  if (value < max) {
                    onChanged(value + step);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
