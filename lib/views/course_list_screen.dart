import 'package:flutter/material.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CoursePresenter _presenter = CoursePresenter();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState(){
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await _presenter.loadCourses();
    setState(() => _isLoading = false);
  }

  
  void _showAddCourseDialog(){
    String name = '';
    String? description;

showDialog(
  context: context,
  builder: (context) {
return AlertDialog(
  title: const Text(
              'Add Course',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 191, 101, 143),
              ),
            ),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        decoration: const InputDecoration(labelText: 'Course Name'),
        onChanged: (value) {name = value;},
      ),
      TextField(
        decoration: const InputDecoration(labelText: 'Description (optional)'),
        onChanged: (value) {description = value;},
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
        if (name.trim().isNotEmpty) {
          await _presenter.addCourse(name.trim(), description?.trim());
          setState(() {});
        Navigator.pop(context);
        }
      },
      child: const Text('Add'),
    ),
  ],
);
  }
);
  }
  @override
Widget build(BuildContext context) {
  final courses = _presenter.courses
    .where((course) =>
        course.name.toLowerCase().contains(_searchQuery)).toList();

  return Scaffold(
    appBar: AppBar(title: const Text(
              'Courses',
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
    : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search courses...',
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
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];

                return ListTile(
                  title: Text(course.name),
                  subtitle: course.description != null
                      ? Text(course.description!)
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: const Color.fromARGB(255, 191, 101, 143),
                    onPressed: () async {
                      await _presenter.deleteCourse(course.name);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    floatingActionButton: AddFAB(onPressed: _showAddCourseDialog,),
  );
}
}