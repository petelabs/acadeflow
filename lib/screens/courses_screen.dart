import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/models/course.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/models/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Course>> _coursesFuture;
  String _searchQuery = '';
  List<Course> _allCourses = [];
  UserProgress? _currentUserProgress;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
    _fetchUserProgress();
  }

  Future<List<Course>> _fetchCourses() async {
    try {
      _allCourses = await _firestoreService.getCourses();
      return _allCourses;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching courses: $e')),
        );
      }
      return [];
    }
  }

  Future<void> _fetchUserProgress() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final progress = await _firestoreService.getUserProgress(user.uid);
        if (mounted) {
          setState(() {
            _currentUserProgress = progress;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user progress: $e')),
          );
        }
      }
    }
  }

  List<Course> get _filteredCourses {
    if (_searchQuery.isEmpty) {
      return _allCourses;
    } else {
      return _allCourses.where((course) {
        return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search courses...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses found.'));
          } else {
            return ListView.builder(
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 2.0,
                    child: ListTile(
                      title: Text(course.title, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(course.description),
                      onTap: () {
                        context.go('/courses/${course.id}/modules');
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
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