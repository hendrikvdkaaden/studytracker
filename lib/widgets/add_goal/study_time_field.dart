import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StudyTimeField extends StatelessWidget {
  final int initialMinutes;
  final ValueChanged<int> onChanged;

  const StudyTimeField({
    super.key,
    required this.initialMinutes,
    required this.onChanged,
  });

  void _showTimePicker(BuildContext context) {
    final initialHours = initialMinutes ~/ 60;
    final initialMins = initialMinutes % 60;

    int selectedHours = initialHours;
    int selectedMinutes = initialMins;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Text(
                    'Study Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final totalMinutes = (selectedHours * 60) + selectedMinutes;
                      onChanged(totalMinutes);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hours picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: initialHours,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          selectedHours = index;
                        },
                        children: List<Widget>.generate(
                          25,
                          (int index) => Center(
                            child: Text(
                              '$index',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Minutes picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: initialMins ~/ 10,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          selectedMinutes = index * 10;
                        },
                        children: List<Widget>.generate(
                          6,
                          (int index) => Center(
                            child: Text(
                              '${index * 10}',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getFormattedTime() {
    if (initialMinutes == 0) {
      return 'Not set';
    }
    final hours = initialMinutes ~/ 60;
    final minutes = initialMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showTimePicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Estimated Study Time',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.access_time),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getFormattedTime(),
              style: TextStyle(
                fontSize: 16,
                color: initialMinutes == 0 ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
