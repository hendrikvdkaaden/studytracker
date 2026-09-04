import 'package:flutter/material.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/l10n_extension.dart';
import '../../common/inline_time_stepper.dart';

class AutoPlanWizardResult {
  final int totalMinutes;
  final List<int> weekdays;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int sessionDuration; // minutes
  final int breakMinutes; // break between sessions on the same day

  /// Whether the planner should avoid times the user is already busy in
  /// their own calendar.
  final bool avoidCalendarEvents;

  const AutoPlanWizardResult({
    required this.totalMinutes,
    required this.weekdays,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.sessionDuration,
    required this.breakMinutes,
    this.avoidCalendarEvents = false,
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
  int _totalHours = 5;
  int _totalMinutes = 30;
  final List<int> _weekdays = [2, 3, 4]; // Di, Wo, Do default
  double _startHour = 8;
  double _endHour = 18;
  int _sessionDurationHours = 0;
  int _sessionDurationMinutes = 45;
  int _breakMinutes = 15;
  String? _errorMessage;

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
    setState(() => _errorMessage = null);
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
        breakMinutes: _breakMinutes,
        // Set in Profile, not here: it belongs with calendar sync.
        avoidCalendarEvents: SettingsService.planAroundCalendar,
      ),
    );
  }

  /// Shown inline above the confirm button instead of as a toast.
  void _showSnack(String msg) {
    setState(() => _errorMessage = msg);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bg = context.colors.modalBackground;
    final sectionBg = context.colors.sectionBackground;
    final textColor = context.colors.textPrimary;
    final subtleText = context.colors.textSecondary;

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
              color: context.colors.dragHandle,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header — no close button: the sheet is dismissed by swiping down.
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: context.colors.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey[100],
          ),
          // Scrollable content
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              children: [
                // 1. Totale studietijd
                _buildSectionHeader(
                  label: context.l10n.autoPlanTotalStudyTimeLabel,
                  icon: Icons.schedule,
                  iconBg: AppColors.iconBgOrange,
                  iconColor: AppColors.iconOrange,
                ),
                const SizedBox(height: 12),
                _buildTimeStepperCard(
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
                  iconBg: AppColors.iconBgBlue,
                  iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                : (context.colors.isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : (context.colors.isDark
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
                  iconBg: AppColors.iconBgPurple,
                  iconColor: AppColors.iconPurple,
                ),
                const SizedBox(height: 12),
                _buildTimeRangeCard(sectionBg: sectionBg, subtleText: subtleText),
                const SizedBox(height: 28),

                // 4. Sessieduur
                _buildSectionHeader(
                  label: context.l10n.autoPlanSessionDurationLabel,
                  icon: Icons.bolt,
                  iconBg: AppColors.iconBgGreen,
                  iconColor: AppColors.iconGreen,
                ),
                const SizedBox(height: 12),
                _buildTimeStepperCard(
                  sectionBg: sectionBg,
                  hours: _sessionDurationHours,
                  minutes: _sessionDurationMinutes,
                  maxHours: 8,
                  onHoursChanged: (v) =>
                      setState(() => _sessionDurationHours = v),
                  onMinutesChanged: (v) =>
                      setState(() => _sessionDurationMinutes = v),
                ),
                const SizedBox(height: 28),

                // 5. Pauze tussen sessies
                _buildSectionHeader(
                  label: context.l10n.autoPlanBreakDurationLabel,
                  icon: Icons.coffee_outlined,
                  iconBg: AppColors.iconBgOrange,
                  iconColor: AppColors.iconOrange,
                ),
                const SizedBox(height: 12),
                _buildBreakPicker(sectionBg: sectionBg, subtleText: subtleText),

                const SizedBox(height: 24),
              ],
            ),
          ),
          // Footer
          Divider(
            height: 1,
            color: context.colors.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey[100],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 14, color: AppColors.overdue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.overdue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
          child: Icon(icon, size: 18, color: iconColor),
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

  Widget _buildTimeStepperCard({
    required Color sectionBg,
    required int hours,
    required int minutes,
    required int maxHours,
    required ValueChanged<int> onHoursChanged,
    required ValueChanged<int> onMinutesChanged,
  }) {
    return InlineTimeStepper(
      backgroundColor: sectionBg,
      hours: hours,
      minutes: minutes,
      maxHours: maxHours,
      onHoursChanged: onHoursChanged,
      onMinutesChanged: onMinutesChanged,
    );
  }

  Widget _buildBreakPicker({
    required Color sectionBg,
    required Color subtleText,
  }) {
    const options = [0, 15, 30, 45, 60];
    final labels = [
      context.l10n.autoPlanBreakNone,
      context.l10n.autoPlanBreak15,
      context.l10n.autoPlanBreak30,
      context.l10n.autoPlanBreak45,
      context.l10n.autoPlanBreak60,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.border,
        ),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = _breakMinutes == options[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _breakMinutes = options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(right: i < options.length - 1 ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : (context.colors.isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : (context.colors.isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey[200]!),
                  ),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : subtleText,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeRangeCard({
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
          color: context.colors.border,
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
                            : (context.colors.isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppColors.lightBorder),
                        border: Border(
                          right: BorderSide(
                            color: context.colors.isDark
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
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
