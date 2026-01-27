import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/study_session.dart';
import '../../services/study_session_repository.dart';
import 'package:uuid/uuid.dart';

void showEditStudyTimeDialog(BuildContext context, String goalId, int currentTotalMinutes, VoidCallback onSuccess) {
  final initialHours = currentTotalMinutes ~/ 60;
  final initialMins = (currentTotalMinutes % 60) ~/ 10;

  int selectedHours = initialHours;
  int selectedMinutes = (initialMins * 10);

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
                  'Edit Study Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final newTotalMinutes = (selectedHours * 60) + selectedMinutes;
                    final repo = StudySessionRepository();
                    final navigator = Navigator.of(context);

                    // Delete all existing sessions for this goal
                    await repo.deleteSessionsByGoalId(goalId);

                    // Create a single new session with the edited total time
                    if (newTotalMinutes > 0) {
                      final session = StudySession(
                        id: const Uuid().v4(),
                        goalId: goalId,
                        date: DateTime.now(),
                        duration: newTotalMinutes,
                      );
                      await repo.addSession(session);
                    }

                    navigator.pop();
                    onSuccess();
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
                            '$index h',
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
                        initialItem: initialMins,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (int index) {
                        selectedMinutes = index * 10;
                      },
                      children: List<Widget>.generate(
                        6,
                        (int index) => Center(
                          child: Text(
                            '${index * 10} m',
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
