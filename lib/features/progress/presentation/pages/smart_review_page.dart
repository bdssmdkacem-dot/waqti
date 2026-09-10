import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/curriculum/data/datasources/curriculum_datasource.dart';
import '../../../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../providers/progress_provider.dart';

/// Smart Review selects the lesson associated with the child's most frequent
/// recorded mistakes and sends the child back to focused practice.
class SmartReviewPage extends ConsumerWidget {
  const SmartReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider).valueOrNull;
    final units = CurriculumDatasource.instance.getUnits();
    final weakSkill = progress?.weakestSkill;
    final target = weakSkill == null ? null : _findLesson(units, weakSkill);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WaqtiColors.offWhite,
        appBar: AppBar(
          title: const Text('المراجعة الذكية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
          backgroundColor: WaqtiColors.primary,
          foregroundColor: Colors.white,
        ),
        body: progress == null
            ? const Center(child: CircularProgressIndicator())
            : target == null
                ? const _EmptyReview()
                : _ReviewCard(unit: target.unit, lesson: target.lesson, errors: progress.skillErrors[weakSkill] ?? 0),
      ),
    );
  }

  ({WaqtiUnit unit, WaqtiLesson lesson})? _findLesson(List<WaqtiUnit> units, String id) {
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == id) return (unit: unit, lesson: lesson);
      }
    }
    return null;
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.unit, required this.lesson, required this.errors});
  final WaqtiUnit unit;
  final WaqtiLesson lesson;
  final int errors;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const Text('🎯', textAlign: TextAlign.center, style: TextStyle(fontSize: 54)),
        const SizedBox(height: 14),
        const Text('وجدنا شيئًا يحتاج إلى تدريب إضافي!', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
        const SizedBox(height: 8),
        const Text('سنراجع معك المهارة التي أخطأت فيها أكثر.', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: WaqtiColors.textLight)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: unit.color.withOpacity(.25), width: 2)),
          child: Column(children: [
            Text(unit.emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 8),
            Text(unit.title, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: unit.color)),
            const SizedBox(height: 4),
            Text(lesson.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: WaqtiColors.textDark)),
            const SizedBox(height: 8),
            Text('$errors أخطاء مسجلة — سنركز عليها الآن', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: WaqtiColors.textLight)),
          ]),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push('/lesson', extra: LessonRouteArgs(unit: unit, lesson: lesson)),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('ابدأ المراجعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: WaqtiColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ),
      ],
    );
  }
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🌟', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        const Text('أنت في بداية الرحلة!', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
        const SizedBox(height: 8),
        const Text('أكمل بعض الدروس أولًا، وسنحلل إجاباتك لنصنع لك مراجعة مناسبة.', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: WaqtiColors.textLight)),
      ]),
    ),
  );
}
