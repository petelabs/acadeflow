import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/models/quiz_question.dart';

class QuizService {
  final GenerativeModel _generativeModel = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: const String.fromEnvironment('GEMINI_API_KEY'));

  Future<List<QuizQuestion>> generateQuiz(String lessonContent) async {
    final prompt =
        'Create a multiple choice quiz based on the following content:\n\n$lessonContent';
    final response = await _generativeModel.generateContent([Content.text(prompt)]);

    // Assuming the response is a JSON string of the quiz
    return _parseQuiz(response.text!);
  }

  List<QuizQuestion> _parseQuiz(String jsonString) {
    final decoded = json.decode(jsonString) as List;
    return decoded
        .map((questionJson) => QuizQuestion.fromJson(questionJson))
        .toList();
  }
}
