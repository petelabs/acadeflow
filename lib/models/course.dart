import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final int totalLessons;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.totalLessons,
  });

  factory Course.fromFirestore(

    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Course(
      id: snapshot.id,
      title: data?['title'],
      description: data?['description'],
      totalLessons: data?['totalLessons'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "description": description,
      "totalLessons": totalLessons,
    };
  }
}