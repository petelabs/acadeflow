import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/module.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:myapp/services/firestore_service.dart'; // Import FirestoreService
import 'package:myapp/models/lesson.dart'; // Import Lesson

class ModulesScreen extends StatefulWidget {
  final String courseId;
  const ModulesScreen({super.key, required this.courseId});

  @override
  _ModulesScreenState createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modules for Course ${widget.courseId}'),
      ),
      body: FutureBuilder<List<Module>>(
        future: FirestoreService().getModules(widget.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading modules: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No modules found for this course.'));
          } else {
            final modules = snapshot.data!;
            return ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ExpansionTile(
                    title: Text(module.title ?? 'Unnamed Module'),
                    children: module.lessonIds.map((lessonId) {
 return FutureBuilder<Lesson?>(
 future: FirestoreService().getLesson(widget.courseId, module.id, lessonId),
 builder: (context, lessonSnapshot) {
 if (lessonSnapshot.connectionState == ConnectionState.waiting) {
 return const ListTile(
 title: Text('Loading lesson...'),
 );
 } else if (lessonSnapshot.hasError || !lessonSnapshot.hasData || lessonSnapshot.data == null) {
 return ListTile(
 title: Text('Error loading lesson $lessonId'),
 );
 } else {
 final lesson = lessonSnapshot.data!;
 return ListTile(
 title: Text(lesson.title),
 onTap: () {
 context.go('/courses/${widget.courseId}/modules/${module.id}/lessons/$lessonId');
 },
 );
 }
 },
 );
 }).toList(),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar( // Add BottomNavBar
        currentIndex: 1, // Index for Courses/Modules/Lessons
        onTap: (index) {
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
        },
      ),
    );
  }
}