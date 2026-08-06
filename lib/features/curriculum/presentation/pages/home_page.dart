import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/ads/data/ad_service.dart';
import '../../../../features/curriculum/data/datasources/curriculum_datasource.dart';
import '../../../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../../../../features/progress/presentation/providers/progress_provider.dart';
import '../../../../features/settings/data/sound_service.dart';
import '../../../../shared/widgets/zaid_mascot.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units    = CurriculumDatasource.instance.getUnits();
    final progress = ref.watch(progressNotifierProvider);
    final ads      = ref.watch(adServiceProvider);
    final sound    = ref.watch(soundServiceProvider);
    final mq       = MediaQuery.of(context);
    final isTablet = mq.size.width >= 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [WaqtiColors.sky, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(children: [
              _Header(sound: sound),
              Expanded(
                child: isTablet
                    ? _TabletLayout(units: units, progress: progress)
                    : _PhoneLayout(units: units, progress: progress),
              ),
              // ── AdMob Banner ─────────────────────────────────
              progress.valueOrNull?.isPremium == true
                  ? const SizedBox.shrink()
                  : ads.homeBannerReady && ads.homeBanner != null
                      ? Container(
                          width:  ads.homeBanner!.size.width.toDouble(),
                          height: ads.homeBanner!.size.height.toDouble(),
                          color:  Colors.white,
                          child:  AdWidget(ad: ads.homeBanner!),
                        )
                      : const SizedBox.shrink(),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  const _Header({required this.sound});
  final SoundService sound;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider).valueOrNull;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: WaqtiColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(children: [
        _Stat('🔥', '${progress?.streakDays ?? 0}', 'يوم'),
        const Spacer(),
        const Text(
          '⏰ وقتي',
          style: TextStyle(
            fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 22,
            fontWeight: FontWeight.w800, color: Colors.white,
          ),
        ),
        const Spacer(),
        Row(children: [
          _Stat('⭐', '${progress?.totalStars ?? 0}', 'نجمة'),
          const SizedBox(width: 6),
          ListenableBuilder(
            listenable: sound,
            builder: (_, __) => IconButton(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              icon: Icon(
                sound.isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white, size: 22,
              ),
              onPressed: () => sound.toggleMute(),
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            onPressed: () {
              sound.click();
              context.push('/settings');
            },
          ),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label);
  final String icon, value, label;
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(icon,  style: const TextStyle(fontSize: 18)),
    Text(value, style: const TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
    Text(label, style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 9, color: Colors.white.withOpacity(.8))),
  ]);
}

// ── Phone layout ───────────────────────────────────────────────
class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.units, required this.progress});
  final List<WaqtiUnit> units;
  final AsyncValue<dynamic> progress;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
    children: [
      _ZaidBubble(),
      const SizedBox(height: 14),
      _FreePlayBtn(),
      const SizedBox(height: 18),
      Text('🗺️ مسار التعلّم', style: TextStyle(
        fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.lg(context),
        fontWeight: FontWeight.w700, color: WaqtiColors.textDark,
      )),
      const SizedBox(height: 10),
      ...units.asMap().entries.map((e) =>
        _UnitCard(unit: e.value, unitIndex: e.key)
            .animate().fadeIn(delay: Duration(milliseconds: 70 * e.key))
            .slideX(begin: e.key.isEven ? -.06 : .06, end: 0),
      ),
    ],
  );
}

// ── Tablet layout ──────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.units, required this.progress});
  final List<WaqtiUnit> units;
  final AsyncValue<dynamic> progress;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 280,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [_ZaidBubble(), const SizedBox(height: 16), _FreePlayBtn()]),
        ),
      ),
      const VerticalDivider(width: 1),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Text('🗺️ مسار التعلّم', style: TextStyle(
              fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.lg(context),
              fontWeight: FontWeight.w700, color: WaqtiColors.textDark,
            )),
            const SizedBox(height: 10),
            ...units.asMap().entries.map((e) =>
              _UnitCard(unit: e.value, unitIndex: e.key)
                  .animate().fadeIn(delay: Duration(milliseconds: 60 * e.key)),
            ),
          ],
        ),
      ),
    ],
  );
}

// ── Zaid mascot bubble ─────────────────────────────────────────
class _ZaidBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sz = (MediaQuery.of(context).size.width * 0.24).clamp(80.0, 110.0);
    return Center(
      child: ZaidMascot(
        mood: ZaidMood.happy, size: sz,
        speech: 'مرحباً! هل أنت مستعد؟ 🎉',
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ── Free-play button ───────────────────────────────────────────
class _FreePlayBtn extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(soundServiceProvider).click();
        context.push('/free-play');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [WaqtiColors.accent, WaqtiColors.gold]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: WaqtiColors.accent.withOpacity(.4), blurRadius: 14, offset: const Offset(0,4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🕐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text('العب بالساعة بحرية', style: TextStyle(
            fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.md(context),
            fontWeight: FontWeight.w700, color: WaqtiColors.textDark,
          )),
        ]),
      ),
    );
  }
}

// ── Unit card ──────────────────────────────────────────────────
class _UnitCard extends ConsumerWidget {
  const _UnitCard({required this.unit, required this.unitIndex});
  final WaqtiUnit unit;
  final int unitIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final prog = progressAsync.valueOrNull;

    final allUnits  = CurriculumDatasource.instance.getUnits();
    final prevIds   = unitIndex > 0
        ? allUnits[unitIndex - 1].lessons.map((l) => l.id).toList()
        : <String>[];
    final locked    = prog == null ? true : !prog.isUnitUnlocked(unitIndex, prevIds);
    final done      = unit.lessons.where((l) => prog?.isLessonDone(l.id) ?? false).length;
    final pct       = unit.lessons.isEmpty ? 0.0 : done / unit.lessons.length;
    final color     = unit.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.2), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(.1), blurRadius: 10, offset: const Offset(0,3))],
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
              child: Center(child: Text(unit.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(unit.title, style: TextStyle(
                  fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.md(context),
                  fontWeight: FontWeight.w700, color: WaqtiColors.textDark,
                ))),
                if (unit.isFree) _badge('مجاني', WaqtiColors.mint),
                if (locked)      const Icon(Icons.lock, size: 16, color: WaqtiColors.textLight),
              ]),
              Text(unit.subtitle, style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.xs(context), color: WaqtiColors.textLight)),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: color.withOpacity(.12),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 2),
              Text('$done/${unit.lessons.length} دروس', style: TextStyle(
                fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.xs(context),
                color: WaqtiColors.textLight,
              )),
            ])),
          ]),
        ),
        // Lessons
        if (!locked)
          ...unit.lessons.asMap().entries.map((e) =>
            _LessonRow(lesson: e.value, index: e.key, unit: unit))
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('🔒 أكمل الوحدة السابقة', style: TextStyle(
              fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.xs(context),
              color: WaqtiColors.textLight,
            )),
          ),
      ]),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    margin: const EdgeInsets.only(left: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: const TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
  );
}

// ── Lesson row ─────────────────────────────────────────────────
class _LessonRow extends ConsumerWidget {
  const _LessonRow({required this.lesson, required this.index, required this.unit});
  final WaqtiLesson lesson;
  final int         index;
  final WaqtiUnit   unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prog  = ref.watch(progressNotifierProvider).valueOrNull;
    final done  = prog?.isLessonDone(lesson.id) ?? false;
    final stars = prog?.getLessonStars(lesson.id) ?? 0;
    final color = unit.color;

    return InkWell(
      onTap: () {
        ref.read(soundServiceProvider).click();
        context.push(
          '/lesson',
          extra: LessonRouteArgs(unit: unit, lesson: lesson),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: done ? color : color.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: done
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text('${index+1}', style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: color))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lesson.title,    style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.sm(context), fontWeight: FontWeight.w600, color: WaqtiColors.textDark)),
            Text(lesson.subtitle, style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: WaqtiSize.xs(context), color: WaqtiColors.textLight)),
          ])),
          if (done) Text('⭐' * stars, style: const TextStyle(fontSize: 12)),
          const Icon(Icons.chevron_left, color: WaqtiColors.textLight, size: 18),
        ]),
      ),
    );
  }
}
