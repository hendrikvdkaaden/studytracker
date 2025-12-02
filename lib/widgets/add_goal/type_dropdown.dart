import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../utils/goal_type_helper.dart';

class TypeDropdown extends StatelessWidget {
  final GoalType selectedType;
  final ValueChanged<GoalType> onChanged;

  const TypeDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<GoalType>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: GoalType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(GoalTypeHelper.getLabel(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
