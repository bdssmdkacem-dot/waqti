import 'package:flutter_test/flutter_test.dart';

import 'package:waqti/features/progress/domain/entities/progress_entity.dart';

void main() {
  group('progress learning rules', () {
    test('first lesson is always unlocked', () {
      const progress = UserProgress();
      expect(progress.isLessonUnlocked(['l1', 'l2'], 0), isTrue);
    });

    test('next lesson stays locked until previous lesson is completed', () {
      const progress = UserProgress();
      expect(progress.isLessonUnlocked(['l1', 'l2', 'l3'], 1), isFalse);
      expect(progress.isLessonUnlocked(['l1', 'l2', 'l3'], 2), isFalse);
    });

    test('next lesson unlocks after previous lesson completion', () {
      final progress = UserProgress(lessons: {
        'l1': const LessonProgress(lessonId: 'l1', stars: 2, bestCorrect: 4, totalQuestions: 5),
      });
      expect(progress.isLessonUnlocked(['l1', 'l2'], 1), isTrue);
      expect(progress.isLessonUnlocked(['l1', 'l2', 'l3'], 2), isFalse);
    });

    test('weakest skill is the skill with the highest error count', () {
      const progress = UserProgress(skillErrors: {
        'lesson:u1l1': 2,
        'lesson:u2l1': 5,
        'lesson:u3l1': 3,
      });
      expect(progress.weakestSkill, 'lesson:u2l1');
    });

    test('empty error history has no review target', () {
      const progress = UserProgress();
      expect(progress.weakestSkill, isNull);
    });
  });
}
