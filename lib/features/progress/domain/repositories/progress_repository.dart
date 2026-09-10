import '../entities/progress_entity.dart';

abstract interface class ProgressRepository {
  Future<UserProgress> loadProgress();

  Future<void> saveLesson(
    String lessonId,
    int stars,
    int correct,
    int total,
    [List<String> mistakes = const [], List<String> correctQuestions = const []]
  );

  Future<void> recordQuestionResult(
    String questionKey,
    String skillKey,
    bool correct,
  );

  Future<void> setPremium(bool value);
  Future<void> addBonusRetry();
  Future<bool> useBonusRetry();
  Future<void> reset();
}
