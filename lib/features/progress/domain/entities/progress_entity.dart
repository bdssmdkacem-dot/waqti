// Progress entities — no Freezed, plain immutable Dart.

class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    this.stars = 0,
    this.bestCorrect = 0,
    this.totalQuestions = 0,
    this.completedAt,
  });

  final String lessonId;
  final int stars, bestCorrect, totalQuestions;
  final DateTime? completedAt;

  bool get isCompleted => stars > 0;
  double get accuracy => totalQuestions == 0 ? 0 : bestCorrect / totalQuestions;

  LessonProgress copyWith({
    int? stars,
    int? bestCorrect,
    int? totalQuestions,
    DateTime? completedAt,
  }) => LessonProgress(
    lessonId: lessonId,
    stars: stars ?? this.stars,
    bestCorrect: bestCorrect ?? this.bestCorrect,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    completedAt: completedAt ?? this.completedAt,
  );
}

class UserProgress {
  const UserProgress({
    this.lessons = const {},
    this.streakDays = 0,
    this.totalStars = 0,
    this.totalLessons = 0,
    this.isPremium = false,
    this.lastPlayDate,
    this.skillErrors = const {},
    this.questionErrors = const {},
    this.questionCorrect = const {},
    this.bonusRetries = 0,
  });

  final Map<String, LessonProgress> lessons;
  final int streakDays, totalStars, totalLessons;
  final bool isPremium;
  final DateTime? lastPlayDate;
  final Map<String, int> skillErrors;
  final Map<String, int> questionErrors;
  final Map<String, int> questionCorrect;
  final int bonusRetries;

  bool isLessonDone(String id) => lessons[id]?.isCompleted ?? false;
  int getLessonStars(String id) => lessons[id]?.stars ?? 0;

  String? get weakestSkill {
    if (skillErrors.isEmpty) return null;
    return skillErrors.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  bool isLessonUnlocked(List<String> lessonIds, int lessonIndex) {
    if (lessonIndex <= 0) return true;
    if (lessonIndex >= lessonIds.length) return false;
    return isLessonDone(lessonIds[lessonIndex - 1]);
  }

  bool isUnitUnlocked(int unitIndex, List<String> prevLessonIds) {
    if (unitIndex == 0) return true;
    return prevLessonIds.every(isLessonDone);
  }

  UserProgress copyWith({
    Map<String, LessonProgress>? lessons,
    int? streakDays,
    int? totalStars,
    int? totalLessons,
    bool? isPremium,
    DateTime? lastPlayDate,
    Map<String, int>? skillErrors,
    Map<String, int>? questionErrors,
    Map<String, int>? questionCorrect,
    int? bonusRetries,
  }) => UserProgress(
    lessons: lessons ?? this.lessons,
    streakDays: streakDays ?? this.streakDays,
    totalStars: totalStars ?? this.totalStars,
    totalLessons: totalLessons ?? this.totalLessons,
    isPremium: isPremium ?? this.isPremium,
    lastPlayDate: lastPlayDate ?? this.lastPlayDate,
    skillErrors: skillErrors ?? this.skillErrors,
    questionErrors: questionErrors ?? this.questionErrors,
    questionCorrect: questionCorrect ?? this.questionCorrect,
    bonusRetries: bonusRetries ?? this.bonusRetries,
  );
}
