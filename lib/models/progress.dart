import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final Map<String, List<String>> courseProgress;
  final Map<String, int> quizProgress;

  UserProgress({
    this.courseProgress = const {},
    this.quizProgress = const {},
  });

  factory UserProgress.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserProgress(
      courseProgress: Map<String, List<String>>.from(data?['courseProgress']?.map((key, value) => MapEntry(key, List<String>.from(value))) ?? {}),
      quizProgress: Map<String, int>.from(data?['quizProgress'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseProgress': courseProgress,
      'quizProgress': quizProgress,
    };
  }

  bool isLessonCompleted(String courseId, String lessonId) {
    return courseProgress.containsKey(courseId) &&
        courseProgress[courseId]!.contains(lessonId);
  }
}