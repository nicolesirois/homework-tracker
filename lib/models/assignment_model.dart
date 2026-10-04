import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Assignment {
  final String title;
  bool isCompleted;
  DateTime? dueDate;


  Assignment({required this.title, this.isCompleted = false, this.dueDate});

  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  static Future<List<Assignment>> fetchAssignments() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _db.child('assignments/$userId').get();
    final List<Assignment> assignments = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((key, value) {
      DateTime? dueDate;

       if (value['dueDate'] != null) {
        dueDate = DateTime.tryParse(value['dueDate'].toString());
      }

     assignments.add(
       Assignment(
         title: value['title'].toString(),
         isCompleted: value['isCompleted'] == true,
         dueDate: dueDate,
       ),
     );
  });
  }
    return assignments;
  }

  static Future<void> addAssignment(String title, {DateTime? dueDate}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    final newRef = _db.child('assignments/$userId').push();
    await newRef.set({
      'title': title,
      'isCompleted': false,
      'dueDate': dueDate?.toIso8601String(),
    });
  }

  static Future<void> updateCompletionStatus(int index, List<Assignment> currentAssignments) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || index < 0 || index >= currentAssignments.length) return;

    final snapshot = await _db.child('assignments/$userId').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.elementAt(index);
      final ref = _db.child('assignments/$userId/${entry.key}');
      final updatedStatus = !currentAssignments[index].isCompleted;
      await ref.update({
        'isCompleted': updatedStatus,
      });
    }
  }

}