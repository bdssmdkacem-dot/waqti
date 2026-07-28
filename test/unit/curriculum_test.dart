import 'package:flutter_test/flutter_test.dart';
import 'package:waqti/features/curriculum/data/datasources/curriculum_datasource.dart';
import 'package:waqti/features/curriculum/domain/entities/curriculum_entities.dart';
import 'package:waqti/features/progress/domain/entities/progress_entity.dart';

void main() {
  final db = CurriculumDatasource.instance;

  group('CurriculumDatasource', () {
    test('returns 13 units', () {
      expect(db.getUnits().length, 13);
    });

    test('unit 1 is free', () {
      expect(db.getUnits().first.isFree, isTrue);
    });

    test('unit 13 is time-calc', () {
      final u13 = db.findUnit('u13');
      expect(u13, isNotNull);
      expect(u13!.title, 'حساب الوقت');
      expect(u13.lessons.every((l) => l.type == LessonType.timeCalc), isTrue);
    });

    test('every lesson has at least one question', () {
      for (final unit in db.getUnits()) {
        for (final lesson in unit.lessons) {
          expect(lesson.totalQuestions, greaterThan(0),
              reason: '${lesson.id} has no questions');
        }
      }
    });

    test('findLesson returns correct lesson', () {
      final lesson = db.findLesson('u1', 'u1l1');
      expect(lesson, isNotNull);
      expect(lesson!.id, 'u1l1');
    });

    test('findNext returns next lesson within unit', () {
      final next = db.findNext('u1', 'u1l1');
      expect(next.lesson?.id, 'u1l2');
    });

    test('findNext crosses unit boundary', () {
      final u1 = db.findUnit('u1')!;
      final lastLesson = u1.lessons.last;
      final next = db.findNext('u1', lastLesson.id);
      expect(next.unit?.id, 'u2');
      expect(next.lesson?.id, 'u2l1');
    });

    test('findNext returns null at end of curriculum', () {
      final u13 = db.findUnit('u13')!;
      final lastLesson = u13.lessons.last;
      final next = db.findNext('u13', lastLesson.id);
      expect(next.unit, isNull);
      expect(next.lesson, isNull);
    });
  });

  group('TimeQuestion', () {
    const q = TimeQuestion(hour: 3, minute: 30,
        type: QuestionType.multipleChoice, prompt: 'test');

    test('timeStr formats 12-hour correctly', () {
      expect(q.timeStr, '03:30');
    });

    test('time24Str formats 24-hour correctly', () {
      expect(q.time24Str, '03:30');
    });

    test('arabicTime returns half past', () {
      expect(q.arabicTime, contains('والنصف'));
    });
  });

  group('TimeCalcQuestion', () {
    const q = TimeCalcQuestion(
      startHour: 2, startMinute: 30,
      endHour: 3, endMinute: 0,
      prompt: 'test',
    );

    test('computes elapsed seconds correctly', () {
      expect(q.elapsedSeconds, 1800); // 30 minutes
    });

    test('elapsedStr returns 30 دقيقة', () {
      expect(q.elapsedStr, '30 دقيقة');
    });

    test('options contains correct answer', () {
      expect(q.options.contains(q.elapsedStr), isTrue);
    });

    test('options has 4 choices', () {
      expect(q.options.length, 4);
    });

    test('overnight calculation wraps correctly', () {
      const night = TimeCalcQuestion(
        startHour: 21, startMinute: 0,
        endHour: 7,   endMinute: 0,
        prompt: 'test',
      );
      expect(night.elapsedHours, 10);
    });
  });

  group('UserProgress', () {
    const empty = UserProgress();

    test('empty progress has no completed lessons', () {
      expect(empty.isLessonDone('u1l1'), isFalse);
    });

    test('isUnitUnlocked: first unit always unlocked', () {
      expect(empty.isUnitUnlocked(0, []), isTrue);
    });

    test('isUnitUnlocked: second unit locked when first not done', () {
      expect(empty.isUnitUnlocked(1, ['u1l1', 'u1l2']), isFalse);
    });

    test('isUnitUnlocked: second unit unlocked when first complete', () {
      final prog = UserProgress(lessons: {
        'u1l1': const LessonProgress(lessonId: 'u1l1', stars: 2),
        'u1l2': const LessonProgress(lessonId: 'u1l2', stars: 1),
        'u1l3': const LessonProgress(lessonId: 'u1l3', stars: 3),
        'u1l4': const LessonProgress(lessonId: 'u1l4', stars: 2),
      });
      expect(prog.isUnitUnlocked(1, ['u1l1','u1l2','u1l3','u1l4']), isTrue);
    });

    test('totalStars sums correctly', () {
      final prog = UserProgress(totalStars: 12);
      expect(prog.totalStars, 12);
    });
  });

  group('LessonProgress', () {
    test('isCompleted false when stars = 0', () {
      const lp = LessonProgress(lessonId: 'test', stars: 0);
      expect(lp.isCompleted, isFalse);
    });

    test('isCompleted true when stars > 0', () {
      const lp = LessonProgress(lessonId: 'test', stars: 2);
      expect(lp.isCompleted, isTrue);
    });

    test('accuracy calculated correctly', () {
      const lp = LessonProgress(lessonId: 'test', stars: 2, bestCorrect: 4, totalQuestions: 5);
      expect(lp.accuracy, closeTo(0.8, 0.001));
    });
  });
}
