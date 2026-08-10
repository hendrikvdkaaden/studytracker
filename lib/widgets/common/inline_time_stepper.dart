import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';

/// Hours/minutes entry used by both the auto plan wizard and the study session
/// picker. Each value can be typed directly or adjusted with the +/- buttons.
class InlineTimeStepper extends StatelessWidget {
  final int hours;
  final int minutes;
  final int maxHours;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final Color? backgroundColor;

  /// Highlights the card in the error colour, e.g. when the chosen start time
  /// clashes with another session.
  final bool hasError;

  const InlineTimeStepper({
    super.key,
    required this.hours,
    required this.minutes,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    this.maxHours = 24,
    this.backgroundColor,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.sectionBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasError ? AppColors.overdue : context.colors.border,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InlineStepper(
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
          _InlineStepper(
            label: context.l10n.sessionPickerMinutes,
            value: minutes,
            max: 59,
            onChanged: onMinutesChanged,
          ),
        ],
      ),
    );
  }
}

class _InlineStepper extends StatefulWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _InlineStepper({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_InlineStepper> createState() => _InlineStepperState();
}

class _InlineStepperState extends State<_InlineStepper> {
  bool _editing = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editing) _commit();
    });
  }

  @override
  void didUpdateWidget(_InlineStepper old) {
    super.didUpdateWidget(old);
    if (!_editing && old.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _controller.text = widget.value.toString();
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    });
    _focusNode.requestFocus();
  }

  /// Commits the typed text and returns the clamped value. The return value
  /// lets callers keep stepping from the freshly committed number instead of
  /// the stale [widget.value], which the parent has not rebuilt with yet.
  int _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    final clamped = (parsed ?? widget.value).clamp(0, widget.max);
    // Clear _editing before unfocusing so the focus listener's guard is false
    // and it does not call back into _commit.
    setState(() => _editing = false);
    // The iOS number pad has no return key, so onSubmitted can never fire.
    // Releasing focus here is what actually dismisses the keyboard.
    _focusNode.unfocus();
    _controller.text = clamped.toString();
    widget.onChanged(clamped);
    return clamped;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = context.colors.card;
    final valueColor = context.colors.textPrimary;

    return Column(
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: context.colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          // Tapping while editing commits, giving the user a visible way out
          // of the keyboard.
          onTap: _editing ? _commit : _startEditing,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 88,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _editing
                    ? AppColors.primary
                    : (context.colors.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey[100]!),
                width: _editing ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: _editing
                ? TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: valueColor,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _commit(),
                  )
                : Text(
                    widget.value.toString().padLeft(2, '0'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: valueColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StepButton(
              icon: Icons.remove,
              onTap: () {
                // Commit first: while editing, didUpdateWidget skips syncing
                // the controller, so stepping without committing would leave
                // the visible text out of step with the real value. Step from
                // the committed value, not the stale widget.value.
                final current = _editing ? _commit() : widget.value;
                if (current > 0) widget.onChanged(current - 1);
              },
            ),
            const SizedBox(width: 8),
            _StepButton(
              icon: Icons.add,
              onTap: () {
                final current = _editing ? _commit() : widget.value;
                if (current < widget.max) {
                  widget.onChanged(current + 1);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.colors.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
