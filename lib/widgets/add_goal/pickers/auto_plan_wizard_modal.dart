import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/l10n_extension.dart';

class AutoPlanWizardResult {
  final int totalMinutes;
  final List<int> weekdays;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int sessionDuration; // minutes

  const AutoPlanWizardResult({
    required this.totalMinutes,
    required this.weekdays,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.sessionDuration,
  });
}

Future<AutoPlanWizardResult?> showAutoPlanWizard({
  required BuildContext context,
}) {
  return showModalBottomSheet<AutoPlanWizardResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AutoPlanWizardSheet(),
  );
}

class _AutoPlanWizardSheet extends StatefulWidget {
  const _AutoPlanWizardSheet();

  @override
  State<_AutoPlanWizardSheet> createState() => _AutoPlanWizardSheetState();
}

class _AutoPlanWizardSheetState extends State<_AutoPlanWizardSheet> {
  int _totalHours = 12;
  int _totalMinutes = 30;
  List<int> _weekdays = [2, 3, 4]; // Di, Wo, Do default
  double _startHour = 8;
  double _endHour = 18;
  int _sessionDurationHours = 0;
  int _sessionDurationMinutes = 45;

  static const _dayLabels = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  static const _dayValues = [1, 2, 3, 4, 5, 6, 7];

  void _toggleDay(int day) {
    setState(() {
      if (_weekdays.contains(day)) {
        _weekdays.remove(day);
      } else {
        _weekdays.add(day);
        _weekdays.sort();
      }
    });
  }

  void _confirm() {
    final l10n = context.l10n;
    final totalMins = _totalHours * 60 + _totalMinutes;
    final sessionMins = _sessionDurationHours * 60 + _sessionDurationMinutes;

    if (totalMins <= 0) {
      _showSnack(l10n.autoPlanErrorNoTime);
      return;
    }
    if (sessionMins <= 0) {
      _showSnack(l10n.autoPlanErrorNoSessionDuration);
      return;
    }
    if (_weekdays.isEmpty) {
      _showSnack(l10n.autoPlanErrorNoDays);
      return;
    }
    final windowMins = (_endHour - _startHour) * 60;
    if (windowMins <= 0) {
      _showSnack(l10n.autoPlanErrorWindowNegative);
      return;
    }
    if (sessionMins > windowMins) {
      _showSnack(l10n.autoPlanErrorSessionTooLong);
      return;
    }

    Navigator.pop(
      context,
      AutoPlanWizardResult(
        totalMinutes: totalMins,
        weekdays: List<int>.from(_weekdays),
        startHour: _startHour.round(),
        startMinute: 0,
        endHour: _endHour.round(),
        endMinute: 0,
        sessionDuration: sessionMins,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightCard;
    final sectionBg = isDark ? const Color(0xFF1A2035) : const Color(0xFFF9FAFB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return Container(
      height: screenHeight * 0.85,
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
                    context.l10n.autoPlanTitle,
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              children: [
                // 1. Totale studietijd
                _buildSectionHeader(
                  label: context.l10n.autoPlanTotalStudyTimeLabel,
                  icon: Icons.schedule,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFEA6C0A),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildTimeStepperCard(
                  isDark: isDark,
                  sectionBg: sectionBg,
                  hours: _totalHours,
                  minutes: _totalMinutes,
                  maxHours: 24,
                  onHoursChanged: (v) => setState(() => _totalHours = v),
                  onMinutesChanged: (v) => setState(() => _totalMinutes = v),
                ),
                const SizedBox(height: 28),

                // 2. Studiedagen
                _buildSectionHeader(
                  label: context.l10n.autoPlanStudyDaysLabel,
                  icon: Icons.calendar_month,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF135BEC),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(_dayLabels.length, (i) {
                    final day = _dayValues[i];
                    final selected = _weekdays.contains(day);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleDay(day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey[200]!),
                            ),
                            boxShadow: selected
                                ? null
                                : [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: Text(
                              _dayLabels[i],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? Colors.white
                                    : subtleText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                // 3. Studievenster
                _buildSectionHeader(
                  label: context.l10n.autoPlanStudyWindowLabel,
                  icon: Icons.wb_sunny_outlined,
                  iconBg: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF7C3AED),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildTimeRangeCard(isDark: isDark, sectionBg: sectionBg, subtleText: subtleText),
                const SizedBox(height: 28),

                // 4. Sessieduur
                _buildSectionHeader(
                  label: context.l10n.autoPlanSessionDurationLabel,
                  icon: Icons.bolt,
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF059669),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildTimeStepperCard(
                  isDark: isDark,
                  sectionBg: sectionBg,
                  hours: _sessionDurationHours,
                  minutes: _sessionDurationMinutes,
                  maxHours: 8,
                  onHoursChanged: (v) =>
                      setState(() => _sessionDurationHours = v),
                  onMinutesChanged: (v) =>
                      setState(() => _sessionDurationMinutes = v),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Footer
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey[100],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.l10n.btnCancel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: subtleText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
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
                      onPressed: _confirm,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text(
                        context.l10n.autoPlanConfirmButton,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
          child: Icon(icon, size: 18, color: iconColor),
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

  Widget _buildTimeStepperCard({
    required bool isDark,
    required Color sectionBg,
    required int hours,
    required int minutes,
    required int maxHours,
    required ValueChanged<int> onHoursChanged,
    required ValueChanged<int> onMinutesChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE5E7EB),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepper(
            isDark: isDark,
            label: context.l10n.sessionPickerHours,
            value: hours,
            max: maxHours,
            onChanged: onHoursChanged,
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
            value: minutes,
            max: 59,
            onChanged: onMinutesChanged,
          ),
        ],
      ),
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

  Widget _buildTimeRangeCard({
    required bool isDark,
    required Color sectionBg,
    required Color subtleText,
  }) {
    final startLabel =
        '${_startHour.round().toString().padLeft(2, '0')}:00';
    final endLabel = '${_endHour.round().toString().padLeft(2, '0')}:00';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          // Labels above bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtleText)),
              Text('12:00',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtleText)),
              Text('23:00',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtleText)),
            ],
          ),
          const SizedBox(height: 8),
          // 24-hour segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 40,
              child: Row(
                children: List.generate(24, (i) {
                  final active = i >= _startHour && i < _endHour;
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary.withValues(alpha: 0.8)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E7EB)),
                        border: Border(
                          right: BorderSide(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Range slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 0,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 20),
              thumbColor: AppColors.primary,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: RangeSlider(
              values: RangeValues(_startHour, _endHour),
              min: 0,
              max: 23,
              divisions: 23,
              onChanged: (v) {
                setState(() {
                  _startHour = v.start;
                  _endHour = v.end;
                });
              },
            ),
          ),
          const SizedBox(height: 4),
          // Selected range label
          Text(
            'Selected: $startLabel — $endLabel',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
