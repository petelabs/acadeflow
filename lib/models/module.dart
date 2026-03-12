import 'package:cloud_firestore/cloud_firestore.dart';

class Module {
  final String id;
  final String title;
  final List<String> lessonIds; // Store lesson IDs instead of full Lesson objects

  Module({
    required this.id,
    required this.title,
 required this.lessonIds,
  });

  factory Module.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Module(
      id: snapshot.id,
      title: data?['title'],
      lessonIds: List<String>.from(data?['lessonIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'lessonIds': lessonIds,
    };
  }
}