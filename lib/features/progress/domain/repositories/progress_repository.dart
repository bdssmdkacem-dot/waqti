import '../entities/progress_entity.dart';

abstract interface class ProgressRepository {
  Future<UserProgress> loadProgress();
  Future<void> saveLesson(
    String lessonId,
    int stars,
    int correct,
    int total,
    List<String> mistakes,
  );
  Future<void> setPremium(bool value);
  Future<void> reset();
}
