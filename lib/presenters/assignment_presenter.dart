import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments => _assignments;

  Future<void> loadAssignments() async {
    final fetched = await Assignment.fetchAssignments();
    _assignments
    ..clear()
    ..addAll(fetched);
  }

  Future<void> addAssignment(String title, String courseName, {DateTime? dueDate}) async {
    await Assignment.addAssignment(title, courseName, dueDate: dueDate);
    _assignments.add(Assignment(title: title, courseName: courseName, 
    dueDate: dueDate,));
  }

  Future<void> toggleCompleted(int index) async {
    await Assignment.updateCompletionStatus(index, _assignments);
    _assignments[index].isCompleted = !_assignments[index].isCompleted;
  }
}