import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:myapp/services/quiz_service.dart';

import 'quiz_service_test.mocks.dart';

@GenerateMocks([VertexAI])
void main() {
  group('QuizService', () {
    test('generateQuiz returns non-empty list for valid topic', () async {
      final mockVertexAI = MockVertexAI();
      final quizService = QuizService(vertexAI: mockVertexAI);

      when(mockVertexAI.generateText(any)).thenAnswer(
        (_) async => 'Question 1\nQuestion 2\nQuestion 3',
      );

      const topic = 'History of Rome';
      final quiz = await quizService.generateQuiz(topic);

      expect(quiz, isNotEmpty);
      expect(quiz, isA<List<String>>());
    });
  });
}