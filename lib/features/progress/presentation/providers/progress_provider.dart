import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/progress_entity.dart';

final progressNotifierProvider =
    AsyncNotifierProvider<ProgressNotifier, UserProgress>(ProgressNotifier.new);

class ProgressNotifier extends AsyncNotifier<UserProgress> {
  @override
  Future<UserProgress> build() => ref.watch(progressRepositoryProvider).loadProgress();

  Future<void> completeLesson(
    String lessonId,
    int stars,
    int correct,
    int total, [
    List<String> mistakes = const [],
    List<String> correctQuestions = const [],
  ]) async {
    await ref.read(progressRepositoryProvider).saveLesson(
      lessonId, stars, correct, total, mistakes, correctQuestions,
    );
    ref.invalidateSelf();
  }

  Future<void> addBonusRetry() async {
    await ref.read(progressRepositoryProvider).addBonusRetry();
    ref.invalidateSelf();
  }

  Future<bool> useBonusRetry() async {
    final used = await ref.read(progressRepositoryProvider).useBonusRetry();
    if (used) ref.invalidateSelf();
    return used;
  }

  Future<void> setPremium(bool value) async {
    await ref.read(progressRepositoryProvider).setPremium(value);
    ref.invalidateSelf();
  }

  Future<void> reset() async {
    await ref.read(progressRepositoryProvider).reset();
    ref.invalidateSelf();
  }
}
