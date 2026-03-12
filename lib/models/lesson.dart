import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String id;
  final String title;
  final String content;
  final String? videoUrl;
  final String courseId;
  final String moduleId;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    this.videoUrl,
    required this.courseId,
    required this.moduleId,
  });

  factory Lesson.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Lesson(
      id: snapshot.id,
      title: data?['title'],
      content: data?['content'],
      videoUrl: data?['videoUrl'],
      courseId: snapshot.reference.parent.parent?.parent.parent?.id ?? '', // Assuming structure courses/courseId/modules/moduleId/lessons/lessonId
      moduleId: snapshot.reference.parent.parent?.id ?? '', // Assuming structure courses/courseId/modules/moduleId/lessons/lessonId
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "content": content,
      "videoUrl": videoUrl,
    };
  }
}