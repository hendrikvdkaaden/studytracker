import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/l10n_extension.dart';

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
    return Dialog(
      backgroundColor: context.colors.modalBackground,
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
              context.l10n.goalDetailsEditProgressTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Target Time Section
            Text(
              context.l10n.progressEditTargetTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: context.l10n.progressEditHours,
                    value: _targetHours,
                    max: 100,
                    onChanged: (value) => setState(() => _targetHours = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    label: context.l10n.progressEditMinutes,
                    value: _targetMinutes,
                    max: 55,
                    step: 5,
                    onChanged: (value) => setState(() => _targetMinutes = value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Time Spent Section
            Text(
              context.l10n.progressEditTimeSpent,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: context.l10n.progressEditHours,
                    value: _spentHours,
                    max: 100,
                    onChanged: (value) => setState(() => _spentHours = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    label: context.l10n.progressEditMinutes,
                    value: _spentMinutes,
                    max: 55,
                    step: 5,
                    onChanged: (value) => setState(() => _spentMinutes = value),
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
                        color: context.colors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      context.l10n.btnCancel,
                      style: TextStyle(
                        color: context.colors.textPrimary,
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
                    child: Text(
                      context.l10n.btnSave,
                      style: const TextStyle(
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
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.fieldBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.colors.border,
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
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              ),
              Text(
                value.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
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
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
