import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqti/features/curriculum/domain/entities/curriculum_entities.dart';
import 'package:waqti/features/progress/domain/entities/progress_entity.dart';
import 'package:waqti/features/progress/domain/services/smart_review_engine.dart';

void main() {
  const lesson = WaqtiLesson(
    id: 'lesson-1',
    title: 'اختبار',
    subtitle: 'اختبار',
    type: LessonType.analog,
    questions: [
      TimeQuestion(hour: 8, minute: 0, type: QuestionType.multipleChoice, prompt: '1'),
      TimeQuestion(hour: 9, minute: 30, type: QuestionType.multipleChoice, prompt: '2'),
      TimeQuestion(hour: 10, minute: 45, type: QuestionType.multipleChoice, prompt: '3'),
    ],
  );
  const lesson2 = WaqtiLesson(
    id: 'lesson-2',
    title: 'اختبار 2',
    subtitle: 'اختبار',
    type: LessonType.analog,
    questions: [
      TimeQuestion(hour: 11, minute: 0, type: QuestionType.multipleChoice, prompt: '4'),
    ],
  );
  const unit = WaqtiUnit(
    id: 'unit-1',
    title: 'الوحدة',
    subtitle: 'اختبار',
    emoji: '🕐',
    lessons: [lesson, lesson2],
    color: Color(0xFF000000),
  );

  test('prioritizes the weakest skill before raw question errors', () {
    final progress = UserProgress(
      skillErrors: {
        'lesson:lesson-1': 2,
        'lesson:lesson-2': 6,
      },
      questionErrors: {
        'question:lesson-1:0': 8,
        'question:lesson-2:0': 2,
      },
    );

    final result = const SmartReviewEngine().buildSession(
      units: [unit],
      progress: progress,
    );

    expect(result.first.lesson.id, 'lesson-2');
  });

  test('prioritizes questions with the most errors inside a skill', () {
    final progress = UserProgress(
      skillErrors: {'lesson:lesson-1': 5},
      questionErrors: {
        'question:lesson-1:0': 1,
        'question:lesson-1:1': 4,
        'question:lesson-1:2': 2,
      },
      questionCorrect: {
        'question:lesson-1:1': 1,
        'question:lesson-1:2': 3,
      },
    );

    final result = const SmartReviewEngine().buildSession(
      units: [unit],
      progress: progress,
    );

    expect(result.length, 3);
    expect(result.first.questionIndex, 1);
    expect(result.first.errorCount, 4);
  });

  test('excludes a question once its error count reaches zero', () {
    final progress = UserProgress(
      questionErrors: {'question:lesson-1:0': 0},
      questionCorrect: {'question:lesson-1:0': 10},
    );

    final result = const SmartReviewEngine().buildSession(
      units: [unit],
      progress: progress,
    );

    expect(result, isEmpty);
  });
}
