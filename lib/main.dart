
import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'main_navigation.dart';


void main() {
  runApp(const HomeworkTrackerApp());
}

class HomeworkTrackerApp extends StatelessWidget {
  const HomeworkTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Tracker',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 191, 101, 143),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Homework Tracker',
          style: TextStyle(fontSize: 30, color: const Color.fromARGB(255, 244, 209, 216), fontWeight: FontWeight.bold,
          ),
          ),
      ),
      );
  }

}
