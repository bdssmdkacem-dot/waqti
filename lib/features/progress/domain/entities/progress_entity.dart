import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_entity.freezed.dart';

@freezed
class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required String lessonId,
    @Default(0) int stars,       // 1-3
    @Default(0) int bestCorrect,
    @Default(0) int totalQuestions,
    DateTime? completedAt,
  }) = _LessonProgress;

  const LessonProgress._();
  bool get isCompleted => stars > 0;
  double get accuracy => totalQuestions == 0 ? 0 : bestCorrect / totalQuestions;
}

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    @Default({}) Map<String, LessonProgress> lessons,
    @Default(0) int streakDays,
    @Default(0) int totalStars,
    @Default(0) int totalLessons,
    @Default(false) bool isPremium,
    DateTime? lastPlayDate,
  }) = _UserProgress;

  const UserProgress._();

  bool isLessonDone(String id) => lessons[id]?.isCompleted ?? false;
  int  getLessonStars(String id) => lessons[id]?.stars ?? 0;

  bool isUnitUnlocked(int unitIndex, List<String> prevLessonIds) {
    if (unitIndex == 0) return true;
    return prevLessonIds.every(isLessonDone);
  }
}
