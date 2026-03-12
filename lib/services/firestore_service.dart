import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/module.dart';
import '../models/lesson.dart';
import '../models/progress.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Course>> getCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      return snapshot.docs.map((doc) => Course.fromFirestore(doc, null)).toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<List<Module>> getModules(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();
      return snapshot.docs.map((doc) => Module.fromFirestore(doc, null)).toList();
    } catch (e) {
      print('Error fetching modules for course $courseId: $e');
      return [];
    }
  }

  Future<Lesson?> getLesson(String courseId, String moduleId, String lessonId) async {
    try {
      final doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .doc(moduleId)
          .collection('lessons')
          .doc(lessonId)
          .get();
      if (doc.exists) {
        return Lesson.fromFirestore(doc, null);
      }
      return null;
    } catch (e) {
      print('Error fetching lesson $lessonId for module $moduleId in course $courseId: $e');
      return null;
    }
  }

    Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final snapshot = await _firestore.collectionGroup('lessons').where('id', isEqualTo: lessonId).get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Lesson.fromFirestore(doc, null);
      }
      return null;
    } catch (e) {
      print('Error fetching lesson by ID $lessonId: $e');
      return null;
    }
  }


  Future<List<Lesson>> getAllLessonsForCourse(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();
      List<Lesson> allLessons = [];
      for (var moduleDoc in snapshot.docs) {
        final lessonsSnapshot = await moduleDoc.reference.collection('lessons').get();
        allLessons.addAll(lessonsSnapshot.docs.map((doc) => Lesson.fromFirestore(doc, null)).toList());
      }
      return allLessons;
    } catch (e) {
      print('Error fetching all lessons for course $courseId: $e');
      return [];
    }
  }

  Future<UserProgress?> getUserProgress(String userId) async {
    try {
      final doc = await _firestore.collection('userProgress').doc(userId).get();
      if (doc.exists) {
        return UserProgress.fromFirestore(doc, null);
      }
      return null;
    } catch (e) {
      print('Error fetching user progress for user $userId: $e');
      return null;
    }
  }

  Future<void> saveUserProgress(String userId, UserProgress progress) async {
    try {
      await _firestore.collection('userProgress').doc(userId).set(progress.toFirestore());
    } catch (e) {
      print('Error saving user progress for user $userId: $e');
    }
  }

  Future<void> markLessonCompleted(String userId, String courseId, String moduleId, String lessonId) async {
    try {
      final progressRef = _firestore.collection('userProgress').doc(userId);
      await _firestore.runTransaction((Transaction transaction) async {
        final snapshot = await transaction.get(progressRef);

        if (!snapshot.exists) {
          transaction.set(progressRef, {
            'courseProgress': {
              courseId: [lessonId],
            },
            'quizProgress': {},
          });
        } else {
          final data = snapshot.data() as Map<String, dynamic>;
          final courseProgress = Map<String, dynamic>.from(data['courseProgress'] ?? {});
          final completedLessons = List<String>.from(courseProgress[courseId] ?? []);

          if (!completedLessons.contains(lessonId)) {
            completedLessons.add(lessonId);
            courseProgress[courseId] = completedLessons;
            transaction.update(progressRef, {'courseProgress': courseProgress});
          }
        }
      });
    } on FirebaseException catch (e) {
      print('Firebase Error marking lesson $lessonId as completed for user $userId: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error marking lesson $lessonId as completed for user $userId: $e');
      rethrow;
    }
  }

  Future<void> updateUserName(String userId, String name) async {
    try {
      await _firestore.collection('users').doc(userId).set({'name': name}, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user name for user $userId: $e');
    }
  }
}