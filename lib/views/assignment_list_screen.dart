
import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _assignmentPresenter = AssignmentPresenter();
  final CoursePresenter _coursePresenter = CoursePresenter();

  String? _selectedCourseFilter;
  String? _newAssignmentCourse;
  List<String> _courseNames = [];
  bool _isLoading = true;
  bool _hideCompleted = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
    _loadData();
  }

  Future<void> _loadAssignments() async {
    await _assignmentPresenter.loadAssignments();
    setState(() => _isLoading = false);
  }

  Future<void> _loadData() async {
    await _coursePresenter.loadCourses();
    await _assignmentPresenter.loadAssignments();

    setState(() {
      _isLoading = false;
      _courseNames = _coursePresenter.courses.map((c) => c.name).toList();
    });
  }

  void _showAddAssignmentDialog() {
  String newAssignmentTitle = '';
  DateTime? selectedDueDate;
  _newAssignmentCourse = _courseNames.isNotEmpty ? _courseNames.first : null;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Add Assignment',
              style: TextStyle(
                fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 191, 101, 143),
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
                  onChanged: (value) {newAssignmentTitle = value;},
                ),

                const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _newAssignmentCourse,
                    items: _courseNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (value) => setState(() => _newAssignmentCourse = value),
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
                if (newAssignmentTitle.trim().isNotEmpty &&
                    _newAssignmentCourse != null) {
                  await _assignmentPresenter.addAssignment(
                    newAssignmentTitle.trim(),
                    _newAssignmentCourse!,
                    dueDate: selectedDueDate,
                  );

                  await _assignmentPresenter.loadAssignments();

                  setState(() {});
                  Navigator.pop(context);
                }
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
    final assignments = _assignmentPresenter.assignments;

    final displayedAssignments = assignments.where((assignment) {
      final matchesCourse = _selectedCourseFilter == null ||
      assignment.courseName == _selectedCourseFilter;

    final matchesSearch = assignment.title
      .toLowerCase()
      .contains(_searchQuery);

    final matchesCompletion =
      !_hideCompleted || !assignment.isCompleted;

    return matchesCourse && matchesSearch && matchesCompletion;
}).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
              'Assignments',
              style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 191, 101, 143),
              ),
             ),
              actions: [
                if (_courseNames.isNotEmpty)
                DropdownButton<String>(
                  hint: const Text('Filter by Course', 
                  style: TextStyle(color: Colors.white),
                  ),
                  dropdownColor: Color.fromARGB(255, 236, 194, 214),
                  value: _selectedCourseFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseFilter = value;
                    });
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Courses'),
                    ),
                    ..._courseNames.map(
                      (name) => DropdownMenuItem(value: name, child: Text(name),
                      ),
                    ),
                  ],
                ),
            ],
          ),

     body:
       _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search assignments...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: displayedAssignments.length,
              itemBuilder: (context, index) {
                final assignment = displayedAssignments[index];

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
                  subtitle: Text('Course: ${assignment.courseName}'),
                  value: assignment.isCompleted,
                  onChanged: (_) async {
                    final originalIndex =
                        _assignmentPresenter.assignments
                            .indexOf(assignment);

                    await _assignmentPresenter
                        .toggleCompleted(originalIndex);

                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
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
    AddFAB(onPressed: _showAddAssignmentDialog),
 ],
),
);
}
}

