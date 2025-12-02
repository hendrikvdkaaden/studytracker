import 'package:flutter/material.dart';

class SubjectField extends StatelessWidget {
  final TextEditingController controller;

  const SubjectField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Subject',
        hintText: 'e.g., Mathematics',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.book),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a subject';
        }
        return null;
      },
    );
  }
}
