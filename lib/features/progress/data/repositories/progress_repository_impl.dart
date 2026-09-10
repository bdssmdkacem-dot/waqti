import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) => SharedPrefsProgressRepository());

class SharedPrefsProgressRepository implements ProgressRepository {
  static const _key = 'waqti_progress_v3';

  @override
  Future<UserProgress> loadProgress() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return const UserProgress();
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      final lessons = <String, LessonProgress>{};
      final rawL = (map['lessons'] as Map<String, dynamic>?) ?? {};
      for (final e in rawL.entries) {
        final v = e.value as Map<String, dynamic>;
        lessons[e.key] = LessonProgress(
          lessonId: e.key,
          stars: (v['stars'] as int?) ?? 0,
          bestCorrect: (v['bestCorrect'] as int?) ?? 0,
          totalQuestions: (v['totalQuestions'] as int?) ?? 0,
          completedAt: v['completedAt'] != null ? DateTime.tryParse(v['completedAt'] as String) : null,
        );
      }
      Map<String, int> ints(String key) {
        final rawValues = (map[key] as Map<String, dynamic>?) ?? {};
        return {for (final entry in rawValues.entries) entry.key: (entry.value as num).toInt()};
      }
      return UserProgress(
        lessons: lessons,
        streakDays: (map['streakDays'] as int?) ?? 0,
        totalStars: (map['totalStars'] as int?) ?? 0,
        totalLessons: (map['totalLessons'] as int?) ?? 0,
        isPremium: (map['isPremium'] as bool?) ?? false,
        lastPlayDate: map['lastPlayDate'] != null ? DateTime.tryParse(map['lastPlayDate'] as String) : null,
        skillErrors: ints('skillErrors'),
        questionErrors: ints('questionErrors'),
        questionCorrect: ints('questionCorrect'),
        bonusRetries: (map['bonusRetries'] as int?) ?? 0,
      );
    } catch (_) {
      return const UserProgress();
    }
  }

  @override
  Future<void> saveLesson(
    String lessonId,
    int stars,
    int correct,
    int total,
    [List<String> mistakes = const [], List<String> correctQuestions = const []]
  ) async {
    var prog = await loadProgress();
    final prev = prog.lessons[lessonId];
    final prevStars = prev?.stars ?? 0;
    final prevBest = prev?.bestCorrect ?? 0;
    final isNew = prevStars == 0;
    final newStars = stars > prevStars ? stars : prevStars;
    final newBest = correct > prevBest ? correct : prevBest;
    var totalSt = prog.totalStars;
    var totalLes = prog.totalLessons;
    if (stars > prevStars) totalSt += stars - prevStars;
    if (isNew) totalLes++;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var streak = prog.streakDays;
    final last = prog.lastPlayDate;
    if (last == null) {
      streak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) streak++;
      else if (diff > 1) streak = 1;
    }

    final errors = Map<String, int>.from(prog.skillErrors);
    for (final skill in mistakes) errors[skill] = (errors[skill] ?? 0) + 1;
    final qErrors = Map<String, int>.from(prog.questionErrors);
    for (final id in mistakes) qErrors[id] = (qErrors[id] ?? 0) + 1;
    final qCorrect = Map<String, int>.from(prog.questionCorrect);
    for (final id in correctQuestions) qCorrect[id] = (qCorrect[id] ?? 0) + 1;

    final updatedLessons = Map<String, LessonProgress>.from(prog.lessons)
      ..[lessonId] = LessonProgress(
        lessonId: lessonId,
        stars: newStars,
        bestCorrect: newBest,
        totalQuestions: total,
        completedAt: prev?.completedAt ?? now,
      );

    prog = prog.copyWith(
      lessons: updatedLessons,
      streakDays: streak,
      totalStars: totalSt,
      totalLessons: totalLes,
      lastPlayDate: now,
      skillErrors: errors,
      questionErrors: qErrors,
      questionCorrect: qCorrect,
    );
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, json.encode(_toMap(prog)));
  }

  @override
  Future<void> recordQuestionResult(String questionKey, String skillKey, bool correct) async {
    final prog = await loadProgress();
    final qErrors = Map<String, int>.from(prog.questionErrors);
    final qCorrect = Map<String, int>.from(prog.questionCorrect);
    final skillErrors = Map<String, int>.from(prog.skillErrors);
    if (correct) {
      qCorrect[questionKey] = (qCorrect[questionKey] ?? 0) + 1;
      if ((qErrors[questionKey] ?? 0) > 0) {
        qErrors[questionKey] = qErrors[questionKey]! - 1;
      }
      if ((skillErrors[skillKey] ?? 0) > 0) {
        skillErrors[skillKey] = skillErrors[skillKey]! - 1;
      }
    } else {
      qErrors[questionKey] = (qErrors[questionKey] ?? 0) + 1;
      skillErrors[skillKey] = (skillErrors[skillKey] ?? 0) + 1;
    }
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, json.encode(_toMap(prog.copyWith(
      questionErrors: qErrors,
      questionCorrect: qCorrect,
      skillErrors: skillErrors,
      lastPlayDate: DateTime.now(),
    ))));
  }

  @override
  Future<void> setPremium(bool value) async {
    var prog = await loadProgress();
    prog = prog.copyWith(isPremium: value);
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, json.encode(_toMap(prog)));
  }

  @override
  Future<void> addBonusRetry() async {
    var prog = await loadProgress();
    prog = prog.copyWith(bonusRetries: prog.bonusRetries + 1);
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, json.encode(_toMap(prog)));
  }

  @override
  Future<bool> useBonusRetry() async {
    final prog = await loadProgress();
    if (prog.bonusRetries <= 0) return false;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, json.encode(_toMap(prog.copyWith(bonusRetries: prog.bonusRetries - 1))));
    return true;
  }

  @override
  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }

  Map<String, dynamic> _toMap(UserProgress prog) => {
    'streakDays': prog.streakDays,
    'totalStars': prog.totalStars,
    'totalLessons': prog.totalLessons,
    'isPremium': prog.isPremium,
    'lastPlayDate': prog.lastPlayDate?.toIso8601String(),
    'skillErrors': prog.skillErrors,
    'questionErrors': prog.questionErrors,
    'questionCorrect': prog.questionCorrect,
    'bonusRetries': prog.bonusRetries,
    'lessons': {
      for (final entry in prog.lessons.entries)
        entry.key: {
          'stars': entry.value.stars,
          'bestCorrect': entry.value.bestCorrect,
          'totalQuestions': entry.value.totalQuestions,
          'completedAt': entry.value.completedAt?.toIso8601String(),
        },
    },
  };
}
