import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/progress_entity.dart';
import '../../data/repositories/progress_repository_impl.dart';

part 'progress_provider.g.dart';

@Riverpod(keepAlive: true)
class ProgressNotifier extends _$ProgressNotifier {
  @override
  Future<UserProgress> build() async {
    return ref.watch(progressRepositoryProvider).loadProgress();
  }

  Future<void> completeLesson(
    String lessonId, int stars, int correct, int total,
  ) async {
    await ref
        .read(progressRepositoryProvider)
        .saveLesson(lessonId, stars, correct, total);
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
