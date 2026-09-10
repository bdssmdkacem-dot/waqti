import '../../../curriculum/domain/entities/curriculum_entities.dart';
import '../entities/progress_entity.dart';

class ReviewCandidate {
  const ReviewCandidate({
    required this.lesson,
    required this.questionIndex,
    required this.questionKey,
    required this.errorCount,
    required this.correctCount,
  });

  final WaqtiLesson lesson;
  final int questionIndex;
  final String questionKey;
  final int errorCount;
  final int correctCount;

  double get mastery => correctCount + errorCount == 0
      ? 0
      : correctCount / (correctCount + errorCount);
}

class SmartReviewEngine {
  const SmartReviewEngine({this.maxQuestions = 8});
  final int maxQuestions;

  List<ReviewCandidate> buildSession({
    required List<WaqtiUnit> units,
    required UserProgress progress,
  }) {
    final candidates = <ReviewCandidate>[];
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        for (var i = 0; i < lesson.totalQuestions; i++) {
          final key = questionKey(lesson.id, i);
          final errors = progress.questionErrors[key] ?? 0;
          final correct = progress.questionCorrect[key] ?? 0;
          if (errors == 0) continue;
          candidates.add(ReviewCandidate(
            lesson: lesson,
            questionIndex: i,
            questionKey: key,
            errorCount: errors,
            correctCount: correct,
          ));
        }
      }
    }

    candidates.sort((a, b) {
      final errorCompare = b.errorCount.compareTo(a.errorCount);
      if (errorCompare != 0) return errorCompare;
      final masteryCompare = a.mastery.compareTo(b.mastery);
      if (masteryCompare != 0) return masteryCompare;
      return a.correctCount.compareTo(b.correctCount);
    });
    return candidates.take(maxQuestions).toList(growable: false);
  }

  static String questionKey(String lessonId, int index) => 'question:$lessonId:$index';
  static String skillKey(String lessonId) => 'lesson:$lessonId';
}
