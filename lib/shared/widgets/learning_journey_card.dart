import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../../features/progress/domain/entities/progress_entity.dart';

class LearningJourneyCard extends StatelessWidget {
  const LearningJourneyCard({super.key, required this.units, required this.progress});
  final List<WaqtiUnit> units;
  final UserProgress? progress;

  @override
  Widget build(BuildContext context) {
    final total = units.fold<int>(0, (sum, unit) => sum + unit.lessons.length);
    final completed = progress?.totalLessons ?? 0;
    final safeTotal = total == 0 ? 1 : total;
    final pct = (completed / safeTotal).clamp(0.0, 1.0);
    final level = completed < 3 ? 1 : completed < 7 ? 2 : completed < 12 ? 3 : completed < 18 ? 4 : 5;
    final titles = const ['بداية الرحلة', 'قارئ الساعة', 'خبير الدقائق', 'سيد الوقت', 'بطل الوقت'];
    final nextGoal = level == 5 ? total : [3, 7, 12, 18, total][level - 1];
    final remaining = (nextGoal - completed).clamp(0, total);
    final weakest = progress?.weakestSkill;
    final weakLabel = weakest == null ? null : weakest.startsWith('lesson:') ? 'مراجعة الدرس' : _skillLabel(weakest);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [WaqtiColors.primary, Color(0xFF3F72AF)], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x223F72AF), blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🧭', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          const Expanded(child: Text('رحلة وقتي', style: TextStyle(fontFamily: 'Cairo', fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white))),
          Text('المستوى $level/5', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70)),
        ]),
        const SizedBox(height: 10),
        Text(titles[level - 1], style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: WaqtiColors.accent)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(WaqtiColors.accent)),
        ),
        const SizedBox(height: 7),
        Row(children: [
          Expanded(child: Text('$completed من $total درس', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70))),
          Text('🔥 ${progress?.streakDays ?? 0} أيام', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        if (remaining > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
            child: Text('🎯 بقي $remaining للوصول إلى المستوى التالي', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white)),
          ),
        ],
        if (weakLabel != null) ...[
          const SizedBox(height: 8),
          Text('💡 ركّز قليلًا على: $weakLabel', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70)),
        ],
      ]),
    );
  }

  String _skillLabel(String skill) {
    switch (skill) {
      case 'read_clock': return 'قراءة الساعة';
      case 'set_hands': return 'تحريك العقارب';
      case 'digital_clock': return 'الساعة الرقمية';
      case 'time_calculation': return 'حساب المدة';
      default: return skill;
    }
  }
}
