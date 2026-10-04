
import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  bool _isLoading = true;
  bool _hideCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();
    setState(() => _isLoading = false);
  }

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
                onPressed: () async {
                  if (newAssignmentTitle.trim().isNotEmpty) {
                    await _presenter.addAssignment(newAssignmentTitle.trim(),
                    dueDate: selectedDueDate,
                    );
                    await _presenter.loadAssignments();
                    setState(() {});
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
    final assignments = _hideCompleted
    ? _presenter.assignments
        .where((assignment) => !assignment.isCompleted)
        .toList()
    : _presenter.assignments;

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
      body: 
      _isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
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
            onChanged: (_) async {
              await _presenter.toggleCompleted(index);
              setState(() {});
            },
          );
        },
      ),
      floatingActionButton: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Padding(
      padding: const EdgeInsets.only(left: 30),
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _hideCompleted = !_hideCompleted;
          });
        },
        child: Icon(
          _hideCompleted
              ? Icons.filter_alt
              : Icons.filter_alt_outlined,
        ),
      ),
    ),
    FloatingActionButton(
      onPressed: _showAddAssignmentDialog,
      child: const Icon(Icons.add),
    ),
  ],
),
    );
  }
}

