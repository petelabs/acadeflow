import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:myapp/models/course.dart';
import 'package:myapp/models/progress.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class CoursesScreenWithSearch extends StatefulWidget {
  const CoursesScreenWithSearch({super.key});

  @override
  _CoursesScreenWithSearchState createState() =>
      _CoursesScreenWithSearchState();
}

class _CoursesScreenWithSearchState extends State<CoursesScreenWithSearch> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Course>> _coursesFuture; // Removed late
  late Future<UserProgress?> _progressFuture;
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  final TextEditingController _searchController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState(); // Call super.initState first
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null) {
      _coursesFuture = _firestoreService.getCourses(); // Ensure _firestoreService is initialized
      _progressFuture = _firestoreService.getUserProgress(_userId!); // Ensure _firestoreService is initialized
      _fetchData();
    } else {
      // Handle case where user is not logged in, maybe navigate to login
      _coursesFuture = Future.value([]);
      _progressFuture = Future.value(null);
      // Consider navigating to login or showing an error
    }

    _searchController.addListener(_filterCourses);
  }

  Future<void> _fetchData() async {
    try {
      _allCourses = await _coursesFuture;
      _filteredCourses = _allCourses; // Initially show all courses
      setState(() {});
    } catch (e) {
      // Handle error fetching courses
      print('Error fetching courses: $e');
      setState(() {
        _allCourses = [];
        _filteredCourses = [];
      });
    }
  }

  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
 _filteredCourses = _allCourses.where((course) {
 return course.title.toLowerCase().contains(query) ||
            course.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCourses);
    _searchController.dispose();
    super.dispose();
  }

  double _getCourseProgress(String courseId, UserProgress? progress) {
    if (progress == null || !progress.courseProgress.containsKey(courseId)) {
      return 0.0;
    }
    final completedLessons = progress.courseProgress[courseId]!.length;
    final course =
        _allCourses.firstWhere((course) => course.id == courseId);
    if (course.totalLessons == 0) {
      return 0.0;
    }
    return completedLessons / course.totalLessons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search courses...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, courseSnapshot) {
          if (courseSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (courseSnapshot.hasError) {
            return Center(child: Text('Error loading courses: ${courseSnapshot.error}'));
          } else if (!courseSnapshot.hasData || courseSnapshot.data!.isEmpty) {
            return const Center(child: Text('No courses available.'));
          } else {
            return FutureBuilder<UserProgress?>(
              future: _progressFuture,
              builder: (context, progressSnapshot) {
                // Progress loading is not critical for displaying the course list,
                // so we can show the list even if progress is still loading or has an error.
                final userProgress = progressSnapshot.data;

                if (_filteredCourses.isEmpty && _searchController.text.isNotEmpty) {
                   return const Center(child: Text('No courses found matching your search.'));
                }

                return ListView.builder(
                  itemCount: _filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = _filteredCourses[index];
                    final progress = _getCourseProgress(course.id, userProgress);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(course.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.description),
                            const SizedBox(height: 4.0),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              color: Theme.of(context).primaryColor,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('${(progress * 100).toStringAsFixed(0)}% Complete'),
                            ),
                          ],
                        ),
                        onTap: () {
                          context.go('/courses/${course.id}/modules');
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar( // Added onTap parameter
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
            // Already on Courses screen
              break;
            case 2:
              context.go('/quizzes');
              break;
            case 3:
              context.go('/profile'); // Navigate to profile screen
              break;
          }
        },
      ),
    );
  }
}