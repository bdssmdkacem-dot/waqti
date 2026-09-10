import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/curriculum/data/datasources/curriculum_datasource.dart';
import '../providers/progress_provider.dart';

class ProgressDashboardPage extends ConsumerWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider).valueOrNull;
    final units = CurriculumDatasource.instance.getUnits();
    if (progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalLessons = units.fold<int>(0, (sum, u) => sum + u.lessons.length);
    final completed = progress.lessons.values.where((l) => l.isCompleted).length;
    final questionKeys = <String>{
      ...progress.questionCorrect.keys,
      ...progress.questionErrors.keys,
    };
    final answeredQuestions = questionKeys.fold<int>(
      0,
      (sum, key) => sum + (progress.questionCorrect[key] ?? 0) + (progress.questionErrors[key] ?? 0),
    );
    final correctAnswers = progress.questionCorrect.values.fold<int>(0, (sum, value) => sum + value);
    final accuracy = answeredQuestions == 0 ? 0.0 : correctAnswers / answeredQuestions;
    final weak = progress.weakestSkill;
    final weakErrors = weak == null ? 0 : progress.skillErrors[weak] ?? 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WaqtiColors.offWhite,
        appBar: AppBar(
          title: const Text('تقدّمي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
          backgroundColor: WaqtiColors.primary,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DailyGoalCard(progress.dailyLessons, progress.dailyGoal, progress.dailyGoalProgress, progress.dailyGoalComplete),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _MetricCard('⭐', '${progress.totalStars}', 'النجوم')),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard('🔥', '${progress.streakDays}', 'أيام متتالية')),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard('🎯', '${(accuracy * 100).round()}%', 'الدقة')),
            ]),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'رحلة التعلّم',
              child: Column(children: [
                _ProgressRow('الدروس المكتملة', completed, totalLessons),
                const SizedBox(height: 12),
                _ProgressRow('النجوم', progress.totalStars, totalLessons * 3),
              ]),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: '🧠 المهارة التي تحتاج تدريبًا',
              child: weak == null
                  ? const Text('لا توجد أخطاء مسجلة بعد. استمر في التعلّم!', style: _bodyStyle)
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_lessonTitle(units, weak), style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
                      const SizedBox(height: 4),
                      Text('$weakErrors أخطاء تحتاج إلى مراجعة', style: _bodyStyle),
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: ElevatedButton.icon(
                        onPressed: () => context.push('/review'),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('ابدأ المراجعة الذكية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
                      )),
                    ]),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: '🏆 مستواك',
              child: Text(_levelText(completed, totalLessons, accuracy), style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: WaqtiColors.textDark)),
            ),
          ],
        ),
      ),
    );
  }

  String _lessonTitle(List<dynamic> units, String id) {
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == id) return lesson.title;
      }
    }
    return 'مهارة تحتاج مراجعة';
  }

  String _levelText(int completed, int total, double accuracy) {
    if (completed == 0) return '🌱 البداية الجميلة — ابدأ أول درس!';
    if (total > 0 && completed >= total && accuracy >= .8) return '🏆 بطل الساعة — أتقنت المنهج!';
    if (accuracy >= .85) return '🌟 ممتاز — تقدّمك رائع!';
    if (accuracy >= .65) return '🚀 جيد جدًا — واصل التدريب!';
    return '💪 أنت تتعلم — المراجعة ستساعدك على التحسن!';
  }
}

const _bodyStyle = TextStyle(fontFamily: 'Cairo', fontSize: 14, color: WaqtiColors.textLight);

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard(this.done, this.goal, this.progress, this.complete);
  final int done, goal;
  final double progress;
  final bool complete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [WaqtiColors.primary, WaqtiColors.accent]),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: WaqtiColors.primary.withOpacity(.18), blurRadius: 14, offset: const Offset(0, 5))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('🎯', style: TextStyle(fontSize: 30)),
        const SizedBox(width: 10),
        Expanded(child: Text(complete ? 'حققت هدف اليوم! 🎉' : 'هدف اليوم', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))),
        Text('$done/$goal', style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white))),
      const SizedBox(height: 8),
      Text(complete ? 'رائع! عد غدًا وحافظ على السلسلة.' : 'أكمل $goal دروس اليوم لبناء عادة التعلّم.', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white)),
    ]),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.icon, this.value, this.label);
  final String icon, value, label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE0E0E0))),
    child: Column(children: [Text(icon, style: const TextStyle(fontSize: 24)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)), Text(label, style: _bodyStyle.copyWith(fontSize: 11))]),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE0E0E0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)), const SizedBox(height: 14), child]),
  );
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow(this.label, this.value, this.total);
  final String label;
  final int value, total;
  @override
  Widget build(BuildContext context) {
    final pct = total <= 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(label, style: _bodyStyle)), Text('$value / $total', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: WaqtiColors.textDark))]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: pct, minHeight: 7, backgroundColor: const Color(0xFFE0E0E0))),
    ]);
  }
}
