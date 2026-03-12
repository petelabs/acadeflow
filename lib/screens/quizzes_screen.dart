import 'package:flutter/material.dart';
import 'package:myapp/models/quiz_question.dart';
import 'package:myapp/services/quiz_service.dart';

class QuizzesScreen extends StatefulWidget {
  final String lessonId;
  final String lessonContent;

  const QuizzesScreen({
    super.key,
    required this.lessonId,
    required this.lessonContent,
  });

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final QuizService _quizService = QuizService();
  List<QuizQuestion> _quizQuestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  void _generateQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final quizContent = await _quizService.generateQuiz(widget.lessonContent);
      setState(() {
        _quizQuestions = quizContent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _quizQuestions.length,
              itemBuilder: (context, index) {
                final question = _quizQuestions[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.question, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ...question.options.map(
                          (option) => RadioListTile(
                            title: Text(option),
                            value: option,
                            groupValue: null, // Add logic to handle answers
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
