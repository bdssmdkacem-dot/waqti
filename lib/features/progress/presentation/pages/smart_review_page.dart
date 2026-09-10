import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/curriculum/data/datasources/curriculum_datasource.dart';
import '../../domain/services/smart_review_engine.dart';
import '../providers/progress_provider.dart';

class SmartReviewPage extends ConsumerWidget {
  const SmartReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider).valueOrNull;
    final units = CurriculumDatasource.instance.getUnits();
    final candidates = progress == null
        ? const <ReviewCandidate>[]
        : const SmartReviewEngine().buildSession(units: units, progress: progress);

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
            : candidates.isEmpty
                ? const _EmptyReview()
                : _ReviewContent(candidates: candidates),
      ),
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({required this.candidates});
  final List<ReviewCandidate> candidates;

  @override
  Widget build(BuildContext context) {
    final first = candidates.first;
    final skillErrors = first.skillErrorCount;
    final mastery = (first.mastery * 100).round();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        const Text('🧠', textAlign: TextAlign.center, style: TextStyle(fontSize: 54)),
        const SizedBox(height: 12),
        const Text(
          'سنراجع ما تحتاجه فعلًا',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 23, fontWeight: FontWeight.w800, color: WaqtiColors.textDark),
        ),
        const SizedBox(height: 8),
        const Text(
          'المراجعة تختار الأسئلة التي أخطأت فيها، وتبدأ بأضعف مهارة ثم تنتقل تلقائيًا لما يليها.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.6, color: WaqtiColors.textLight),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: first.lesson.id == first.lesson.id ? WaqtiColors.primary.withValues(alpha: .18) : Colors.black12, width: 2),
          ),
          child: Column(children: [
            Text(first.lesson.title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Stat('🎯', '$mastery%', 'إتقان السؤال'),
              const SizedBox(width: 12),
              _Stat('❌', '$skillErrors', 'أخطاء المهارة'),
              const SizedBox(width: 12),
              _Stat('📝', '${candidates.length}', 'أسئلة للمراجعة'),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        ElevatedButton.icon(
          onPressed: () => context.push('/free-play', extra: true),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('ابدأ المراجعة الذكية', style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: WaqtiColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'سيتم تحديث الاختيارات بعد كل إجابة، لذلك إذا تحسنت مهارة سينتقل النظام إلى المهارة التالية بدل تكرار نفس السؤال.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 12, height: 1.6, color: WaqtiColors.textLight),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label);
  final String icon, value, label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 9, color: WaqtiColors.textLight)),
    ]),
  );
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
        const Text('لا توجد مراجعة مطلوبة الآن!', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
        const SizedBox(height: 8),
        const Text('أكمل الدروس أو العب في الوضع الحر. عندما نسجل أخطاء، ستظهر هنا مراجعة مخصصة.', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: WaqtiColors.textLight)),
      ]),
    ),
  );
}
