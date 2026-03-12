import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Welcome to Academia Flow!'),
        ),
      ),
    );
  }
}

void _onItemTapped(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/');
      break;
    case 1:
      context.go('/courses');
      break;
    case 2:
      context.go('/quizzes');
      break;
    case 3:
      context.go('/chat');
      break;
    case 4:
      context.go('/profile');
      break;
  }
}