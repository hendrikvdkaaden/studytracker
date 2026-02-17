import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Future<({int hours, int minutes})?> showDurationPickerModal({
  required BuildContext context,
  required int initialHours,
  required int initialMinutes,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  int tempHours = initialHours;
  int tempMinutes = initialMinutes;

  return showModalBottomSheet<({int hours, int minutes})>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            _PickerHeader(
              title: 'Select Duration',
              onCancel: () => Navigator.pop(context),
              onDone: () => Navigator.pop(
                context,
                (hours: tempHours, minutes: tempMinutes),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _PickerColumn(
                    label: 'HOURS',
                    isDark: isDark,
                    itemCount: 25,
                    initialItem: tempHours,
                    onChanged: (index) => tempHours = index,
                    labelBuilder: (index) => index.toString().padLeft(2, '0'),
                  ),
                  Container(
                    width: 1,
                    height: 150,
                    color: isDark
                        ? const Color(0xFF4B5563)
                        : const Color(0xFFD1D5DB),
                  ),
                  _PickerColumn(
                    label: 'MINUTES',
                    isDark: isDark,
                    itemCount: 4,
                    initialItem: tempMinutes ~/ 15,
                    onChanged: (index) => tempMinutes = index * 15,
                    labelBuilder: (index) =>
                        (index * 15).toString().padLeft(2, '0'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
            onPressed: onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontSize: 16),
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
                color: Color(0xFF135BEC),
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
  final bool isDark;
  final int itemCount;
  final int initialItem;
  final ValueChanged<int> onChanged;
  final String Function(int) labelBuilder;

  const _PickerColumn({
    required this.label,
    required this.isDark,
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
              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
