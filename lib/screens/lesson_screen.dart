import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/models/lesson.dart';
import 'package:myapp/models/progress.dart';
import 'package:myapp/services/firestore_service.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Lesson? _lesson;
  UserProgress? _currentUserProgress;
  bool _isLoading = true;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _fetchLessonAndProgress();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _fetchLessonAndProgress() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final lessonFuture = _firestoreService.getLesson(widget.courseId, widget.moduleId, widget.lessonId);
      final progressFuture = _firestoreService.getUserProgress(userId);

      final results = await Future.wait([lessonFuture, progressFuture]);
      final lesson = results[0] as Lesson?;
      final progress = results[1] as UserProgress?;

      if (!mounted) return;
      setState(() {
        _lesson = lesson;
        _currentUserProgress = progress;
      });

      if (_lesson?.videoUrl != null && _lesson!.videoUrl!.isNotEmpty) {
        _initializeVideoPlayer(_lesson!.videoUrl!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching lesson data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoPlayerController!.initialize().then((_) {
      if (!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
      );
      _videoPlayerController!.addListener(_videoListener);
      setState(() {});
    });
  }

  void _videoListener() {
    final position = _videoPlayerController?.value.position;
    final duration = _videoPlayerController?.value.duration;
    if (position != null && duration != null && position >= duration) {
      _markLessonCompleted();
      _videoPlayerController!.removeListener(_videoListener); // Prevent multiple calls
    }
  }

  Future<void> _markLessonCompleted() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && _lesson != null) {
      try {
        await _firestoreService.markLessonCompleted(userId, widget.courseId, widget.moduleId, widget.lessonId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson marked as completed!')),
          );
          _fetchLessonAndProgress(); // Refresh progress
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error marking lesson as completed: $e')),
          );
        }
      }
    }
  }

  bool _isLessonCompleted() {
    if (_currentUserProgress == null) return false;
    return _currentUserProgress!.isLessonCompleted(widget.courseId, widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lesson?.title ?? 'Lesson'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lesson == null
              ? const Center(child: Text('Lesson not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lesson!.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
                        AspectRatio(
                          aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
                          child: Chewie(controller: _chewieController!),
                        )
                      else if (_lesson!.videoUrl != null && _lesson!.videoUrl!.isNotEmpty)
                        const Center(child: CircularProgressIndicator())
                      else
                        const SizedBox.shrink(), 
                      const SizedBox(height: 16.0),
                      Text(
                        _lesson!.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24.0),
                      if (_isLessonCompleted())
                        const Chip(
                          label: Text('Completed'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      else if (_lesson!.videoUrl == null || _lesson!.videoUrl!.isEmpty)
                        ElevatedButton(
                          onPressed: _markLessonCompleted,
                          child: const Text('Mark as Completed'),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/courses'); break;
            case 2: context.go('/quizzes'); break;
            case 3: context.go('/chat'); break;
            case 4: context.go('/profile'); break;
          }
        },
      ),
    );
  }
}
