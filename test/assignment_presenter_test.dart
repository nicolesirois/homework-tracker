
import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/presenters/assignment_presenter.dart';

void main() {
  late AssignmentPresenter presenter;

  setUp(() {
    presenter = AssignmentPresenter();
  });

  test('Assignment list starts empty', () {
    expect(presenter.assignments, isEmpty);
  });

  test('Total assignments is zero when list is empty', () {
    expect(presenter.totalAssignments, 0);
  });

  test('Completion ratio is zero when list is empty', () {
    expect(presenter.completionRatio, 0);
  });
}
