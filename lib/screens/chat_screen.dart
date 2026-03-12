import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  final String? lessonId;

  const ChatScreen({super.key, this.lessonId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  late final GenerativeModel _model;
  String? _lessonContent;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: const String.fromEnvironment('GEMINI_API_KEY'));
    if (widget.lessonId != null) {
      _fetchLessonContent(widget.lessonId!);
    }
  }

  Future<void> _fetchLessonContent(String lessonId) async {
    try {
      final lesson = await _firestoreService.getLessonById(lessonId);
      setState(() {
        _lessonContent = lesson?.content;
      });
    } catch (e) {
      log('Error fetching lesson content: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
      ),
      body: Column(
        children: <Widget>[
          if (_lessonContent != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Chat context: Based on the current lesson.',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['role'] == 'user';
                return ListTile(
                  title: Align(
                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(color: isUserMessage ? Colors.blue[900] : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  tooltip: 'Send Message',
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, 
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
              break; 
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
    });
    _textController.clear();

    String prompt = text;
    if (_lessonContent != null) {
      prompt = "Based on the following lesson content:\n\n$_lessonContent\n\nAnswer the following question: $text";
    }

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        setState(() {
          _messages.add({"role": "model", "text": response.text!});
        });
      }
    } catch (e) {
      log('Error sending message to Gemini: $e');
      setState(() {
        _messages.add({"role": "model", "text": "Error: ${e.toString()}"});
      });
    }
  }
}