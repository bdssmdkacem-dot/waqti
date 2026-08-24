import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/progress_entity.dart';

final progressNotifierProvider =
    AsyncNotifierProvider<ProgressNotifier, UserProgress>(
  ProgressNotifier.new,
);

class ProgressNotifier extends AsyncNotifier<UserProgress> {
  @override
  Future<UserProgress> build() =>
      ref.watch(progressRepositoryProvider).loadProgress();

  Future<void> completeLesson(
    String lessonId,
    int stars,
    int correct,
    int total,
    [List<String> mistakes = const []]
  ) async {
    final recordedMistakes = mistakes.isEmpty && correct < total
        ? List<String>.filled(total - correct, 'lesson:$lessonId')
        : mistakes;
    await ref.read(progressRepositoryProvider).saveLesson(
      lessonId, stars, correct, total, recordedMistakes,
    );
    ref.invalidateSelf();
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
