import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';

Future<({int hour, int minute})?> showTimePickerModal({
  required BuildContext context,
  required int initialHour,
  required int initialMinute,
}) async {
  int tempHour = initialHour;
  int tempMinute = initialMinute;

  return showModalBottomSheet<({int hour, int minute})>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: context.colors.modalBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            _PickerHeader(
              title: 'Select Time',
              onCancel: () => Navigator.pop(context),
              onDone: () => Navigator.pop(
                context,
                (hour: tempHour, minute: tempMinute),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _PickerColumn(
                    label: 'HOUR',
                    itemCount: 24,
                    initialItem: tempHour,
                    onChanged: (index) => tempHour = index,
                    labelBuilder: (index) => index.toString().padLeft(2, '0'),
                  ),
                  Container(
                    width: 1,
                    height: 150,
                    color: context.colors.divider,
                  ),
                  _PickerColumn(
                    label: 'MINUTE',
                    itemCount: 12,
                    initialItem: tempMinute ~/ 5,
                    onChanged: (index) => tempMinute = index * 5,
                    labelBuilder: (index) =>
                        (index * 5).toString().padLeft(2, '0'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _PickerHeader extends StatelessWidget {
  final String title;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const _PickerHeader({
    required this.title,
    required this.onCancel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.border,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 16),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: onDone,
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  final String label;
  final int itemCount;
  final int initialItem;
  final ValueChanged<int> onChanged;
  final String Function(int) labelBuilder;

  const _PickerColumn({
    required this.label,
    required this.itemCount,
    required this.initialItem,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: initialItem,
              ),
              itemExtent: 32,
              onSelectedItemChanged: onChanged,
              children: List<Widget>.generate(itemCount, (index) {
                return Center(
                  child: Text(
                    labelBuilder(index),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
