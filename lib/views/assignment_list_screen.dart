
import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();

  void _showAddAssignmentDialog() {
  String newAssignmentTitle = '';
  DateTime? selectedDueDate;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Add Assignment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 191, 101, 143),
              ),
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter assignment title',
                  ),
                  onChanged: (value) {
                    newAssignmentTitle = value;
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        selectedDueDate == null
                            ? 'No due date'
                            : 'Due: ${selectedDueDate!.month}/'
                                '${selectedDueDate!.day}/'
                                '${selectedDueDate!.year}',
                      ),
                    ),

                    TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate =
                            await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDueDate = pickedDate;
                          });
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),

              TextButton(
                onPressed: () {
                  if (newAssignmentTitle.trim().isNotEmpty) {
                    setState(() {
                      _presenter.addAssignment(
                        newAssignmentTitle.trim(),
                        dueDate: selectedDueDate,
                      );
                    });
                  }

                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final assignments = _presenter.assignments;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
              'Assignments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 191, 101, 143),
              ),
            ),
      ),
      body: ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];

          return CheckboxListTile(
            title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      assignment.title,
      style: TextStyle(
        decoration: assignment.isCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: Colors.red,
        decorationThickness: 2,
      ),
    ),

    if (assignment.dueDate != null)
      Text(
        'Due: ${assignment.dueDate!.month}/'
        '${assignment.dueDate!.day}/'
        '${assignment.dueDate!.year}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
  ],
),
            value: assignment.isCompleted,
            onChanged: (value) {
              setState(() {
                _presenter.toggleCompleted(index);
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

