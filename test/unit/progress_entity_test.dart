import 'package:flutter_test/flutter_test.dart';
import 'package:waqti/features/progress/domain/entities/progress_entity.dart';

void main() {
  group('UserProgress lesson progression', () {
    const ids = ['lesson-1', 'lesson-2', 'lesson-3'];

    test('first lesson is unlocked', () {
      const progress = UserProgress();
      expect(progress.isLessonUnlocked(ids, 0), isTrue);
    });

    test('later lessons stay locked until the previous lesson is complete', () {
      const progress = UserProgress();
      expect(progress.isLessonUnlocked(ids, 1), isFalse);
      expect(progress.isLessonUnlocked(ids, 2), isFalse);
    });

    test('completing the previous lesson unlocks only the next lesson', () {
      const progress = UserProgress(lessons: {
        'lesson-1': LessonProgress(
          lessonId: 'lesson-1',
          stars: 2,
          bestCorrect: 4,
          totalQuestions: 5,
        ),
      });

      expect(progress.isLessonUnlocked(ids, 1), isTrue);
      expect(progress.isLessonUnlocked(ids, 2), isFalse);
    });
  });
}
