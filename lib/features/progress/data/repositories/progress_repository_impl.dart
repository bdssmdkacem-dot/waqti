import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final rawErrors = (map['skillErrors'] as Map<String, dynamic>?) ?? {};
      final skillErrors = <String, int>{
        for (final e in rawErrors.entries) e.key: (e.value as num).toInt(),
      };
      return UserProgress(
        lessons: lessons,
        streakDays: (map['streakDays'] as int?) ?? 0,
        totalStars: (map['totalStars'] as int?) ?? 0,
        totalLessons: (map['totalLessons'] as int?) ?? 0,
        isPremium: (map['isPremium'] as bool?) ?? false,
        lastPlayDate: map['lastPlayDate'] != null ? DateTime.tryParse(map['lastPlayDate'] as String) : null,
        skillErrors: skillErrors,
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
    [List<String> mistakes = const []]
  ) async {
    var prog = await loadProgress();
    final prev = prog.lessons[lessonId];
    final prevStars = prev?.stars ?? 0;
    final prevBest = prev?.bestCorrect ?? 0;
    final isNew = prevStars == 0;
    final newStars = stars > prevStars ? stars : prevStars;
    final newBest = correct > prevBest ? correct : prevBest;
    int totalSt = prog.totalStars;
    int totalLes = prog.totalLessons;
    if (stars > prevStars) {
      totalSt += stars - prevStars;
    }
    if (isNew) {
      totalLes++;
    }

    // Streaks are based on calendar days, not elapsed 24-hour periods.
    // Example: playing at 23:30 and again at 08:00 the next morning
    // must count as two consecutive days.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var streak = prog.streakDays;
    final last = prog.lastPlayDate;
    if (last == null) {
      streak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
      // diff == 0: replaying on the same day does not increase the streak.
    }

    final errors = Map<String, int>.from(prog.skillErrors);
    for (final skill in mistakes) {
      errors[skill] = (errors[skill] ?? 0) + 1;
    }

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
    );

    final p = await SharedPreferences.getInstance();
    await p.setString(_key, json.encode(_toMap(prog)));
  }

  @override
  Future<void> setPremium(bool value) async {
    var prog = await loadProgress();
    prog = prog.copyWith(isPremium: value);
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, json.encode(_toMap(prog)));
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
    'lessons': {
      for (final e in prog.lessons.entries)
        e.key: {
          'stars': e.value.stars,
          'bestCorrect': e.value.bestCorrect,
          'totalQuestions': e.value.totalQuestions,
          'completedAt': e.value.completedAt?.toIso8601String(),
        },
    },
  };
}
