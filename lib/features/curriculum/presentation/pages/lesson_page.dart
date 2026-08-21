import 'dart:math' as math;
import 'package:confetti/confetti.dart';
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
import '../../../../shared/widgets/analog_clock.dart';
import '../../../../shared/widgets/digital_clock.dart';
import '../../../../shared/widgets/zaid_mascot.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.unit, required this.lesson});
  final WaqtiUnit unit;
  final WaqtiLesson lesson;
  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  int qi = 0;
  int correct = 0;
  bool answered = false;
  bool? lastCorrect;
  bool finished = false;
  int setH = 12;
  int setM = 0;
  late final ConfettiController _confetti;
  late List<bool?> results;

  int get totalQ => widget.lesson.totalQuestions;
  Color get color => widget.unit.color;
  SoundService get _sound => ref.read(soundServiceProvider);
  bool get _isCalc => widget.lesson.type == LessonType.timeCalc;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    results = List<bool?>.filled(totalQ, null);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _sound.stop(WaqtiSound.countdown);
    super.dispose();
  }

  void _resetQuestion() {
    answered = false;
    lastCorrect = null;
    setH = 12;
    setM = 0;
  }

  void _answer(bool value) {
    if (answered) return;
    setState(() {
      answered = true;
      lastCorrect = value;
      results[qi] = value;
      if (value) correct++;
    });
    if (value) {
      _sound.correct();
    } else {
      _sound.wrong();
    }
  }

  void _next() {
    _sound.click();
    if (qi < totalQ - 1) {
      setState(() {
        qi++;
        _resetQuestion();
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => finished = true);
    final stars = correct == totalQ ? 3 : correct >= (totalQ * 2 / 3).ceil() ? 2 : 1;
    if (stars == 3) {
      _confetti.play();
      await _sound.lessonComplete();
      await Future.delayed(600.ms);
      await _sound.success();
    } else if (stars == 2) {
      await _sound.lessonComplete();
    } else {
      await _sound.notification();
    }
    await ref.read(progressNotifierProvider.notifier).completeLesson(
      widget.lesson.id,
      stars,
      correct,
      totalQ,
    );
    // Production interstitial is eligible after every completed lesson, starting at lesson 1.
    await ref.read(adServiceProvider).onLessonComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WaqtiColors.offWhite,
        body: Stack(
          children: [
            SafeArea(child: finished ? _buildFinish() : _buildQuestion()),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [WaqtiColors.accent, WaqtiColors.coral, WaqtiColors.mint, WaqtiColors.primary],
                numberOfParticles: 40,
                emissionFrequency: .08,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner() {
    final ads = ref.watch(adServiceProvider);
    final premium = ref.watch(progressNotifierProvider).valueOrNull?.isPremium ?? false;
    if (premium || !ads.lessonBannerReady || ads.lessonBanner == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      height: ads.lessonBanner!.size.height.toDouble(),
      alignment: Alignment.center,
      color: Colors.white,
      child: SizedBox(
        width: ads.lessonBanner!.size.width.toDouble(),
        height: ads.lessonBanner!.size.height.toDouble(),
        child: AdWidget(ad: ads.lessonBanner!),
      ),
    );
  }

  Widget _buildQuestion() {
    return Column(
      children: [
        _topBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              children: [
                _zaidBubble(),
                const SizedBox(height: 16),
                _isCalc ? _buildCalcQ() : _buildTimeQ(),
              ],
            ),
          ),
        ),
        _banner(),
      ],
    );
  }

  Widget _topBar() => Container(
    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
    color: color,
    child: Column(children: [
      Row(children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () { _sound.click(); context.pop(); },
        ),
        Expanded(
          child: Text(
            widget.lesson.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        Text('${qi + 1}/$totalQ', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white)),
        const SizedBox(width: 10),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: LinearProgressIndicator(
          value: (qi + 1) / totalQ,
          backgroundColor: Colors.white.withOpacity(.25),
          valueColor: const AlwaysStoppedAnimation(WaqtiColors.accent),
          minHeight: 7,
        ),
      ),
      const SizedBox(height: 7),
      _scoreBar(),
    ]),
  );

  Widget _scoreBar() => Wrap(
    spacing: 5,
    alignment: WrapAlignment.center,
    children: List.generate(totalQ, (i) {
      final result = results[i];
      final bg = result == null ? Colors.white.withOpacity(.15) : result ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3F1);
      final fg = result == null ? Colors.white70 : result ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: fg.withOpacity(.4), width: 1.5)),
        child: Center(child: Text(result == null ? '${i + 1}' : (result ? '✓' : '✗'), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: fg))),
      );
    }),
  );

  Widget _zaidBubble() {
    final prompt = _isCalc ? widget.lesson.calcQuestions[qi].prompt : widget.lesson.questions[qi].prompt;
    final mood = !answered ? ZaidMood.thinking : (lastCorrect == true ? ZaidMood.celebrating : ZaidMood.encouraging);
    return ZaidMascot(mood: mood, size: 78, speech: prompt);
  }

  Widget _buildTimeQ() {
    final q = widget.lesson.questions[qi];
    switch (q.type) {
      case QuestionType.multipleChoice:
        return _buildMC(q);
      case QuestionType.setHands:
        return _buildSetHands(q);
      case QuestionType.digitalMC:
        return _buildDigitalMC(q);
      default:
        return _buildMC(q);
    }
  }

  Widget _buildMC(TimeQuestion q) {
    final choices = _genChoices(q.hour, q.minute);
    return Column(children: [
      AnalogClock(hour: q.hour, minute: q.minute, size: WaqtiSize.lessonClockSize(context), color: color),
      const SizedBox(height: 20),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
        children: choices.map((choice) {
          final ok = choice == q.timeStr;
          return GestureDetector(
            onTap: answered ? null : () => _answer(ok),
            child: AnimatedContainer(
              duration: 200.ms,
              decoration: BoxDecoration(
                color: answered && ok ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: answered && ok ? WaqtiColors.mint : color.withOpacity(.2), width: 2.5),
              ),
              child: Center(child: Text(choice, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: answered && ok ? const Color(0xFF2E7D32) : WaqtiColors.textDark))),
            ),
          );
        }).toList(),
      ),
      if (answered) ...[const SizedBox(height: 16), _nextBtn()],
    ]);
  }

  Widget _buildDigitalMC(TimeQuestion q) {
    final h12 = q.hour > 12 ? q.hour - 12 : (q.hour == 0 ? 12 : q.hour);
    final choices = _genDigChoices(q.hour, q.minute);
    return Column(children: [
      DigitalClock(hour: h12, minute: q.minute, fontSize: 40),
      const SizedBox(height: 8),
      AmPmBadge(hour: q.hour),
      const SizedBox(height: 18),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.7,
        children: choices.map((choice) {
          final ok = choice.time == q.time24Str;
          return GestureDetector(
            onTap: answered ? null : () => _answer(ok),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: answered && ok ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: answered && ok ? WaqtiColors.mint : Colors.black12, width: 2),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(choice.time, style: const TextStyle(fontFamily: 'Courier New', fontSize: 18, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
                const SizedBox(height: 3),
                Text(choice.label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: WaqtiColors.textLight)),
              ]),
            ),
          );
        }).toList(),
      ),
      if (answered) ...[const SizedBox(height: 16), _nextBtn()],
    ]);
  }

  Widget _buildSetHands(TimeQuestion q) {
    final correctNow = answered && setH % 12 == q.hour % 12 && setM == q.minute;
    return Column(children: [
      Text.rich(
        TextSpan(children: [
          const TextSpan(text: 'حرّك العقارب إلى: ', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: WaqtiColors.textMid)),
          TextSpan(text: q.timeStr, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ]),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      Text(q.arabicTime, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: WaqtiColors.textLight)),
      const SizedBox(height: 14),
      InteractiveClock(
        initialHour: 12,
        initialMinute: 0,
        size: WaqtiSize.lessonClockSize(context),
        color: color,
        onChanged: answered ? (_, __) {} : (hour, minute) {
          setState(() { setH = hour; setM = minute; });
        },
      ),
      const SizedBox(height: 12),
      Text('${setH.toString().padLeft(2, '0')}:${setM.toString().padLeft(2, '0')}', style: TextStyle(fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.w800, color: answered ? (correctNow ? const Color(0xFF2E7D32) : const Color(0xFFC62828)) : color)),
      const SizedBox(height: 12),
      if (!answered)
        ElevatedButton(
          onPressed: () => _answer(setH % 12 == q.hour % 12 && setM == q.minute),
          style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(150, 48)),
          child: const Text('✓ تحقّق', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        )
      else
        _nextBtn(),
    ]);
  }

  Widget _buildCalcQ() {
    final q = widget.lesson.calcQuestions[qi];
    Future.microtask(() => _sound.countdown());
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(children: [
          const Text('البداية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: WaqtiColors.textLight)),
          const SizedBox(height: 4),
          DigitalClock(hour: q.startHour, minute: q.startMinute, second: q.startSecond > 0 ? q.startSecond : null, fontSize: 24),
        ]),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_back, color: color)),
        Column(children: [
          const Text('النهاية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: WaqtiColors.textLight)),
          const SizedBox(height: 4),
          DigitalClock(hour: q.endHour, minute: q.endMinute, second: q.endSecond > 0 ? q.endSecond : null, fontSize: 24),
        ]),
      ]),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(12)),
        child: const Text('🧮 كم من الوقت مرّ؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: WaqtiColors.textDark)),
      ),
      const SizedBox(height: 18),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
        children: q.options.map((option) {
          final ok = option == q.elapsedStr;
          return GestureDetector(
            onTap: answered ? null : () => _answer(ok),
            child: Container(
              decoration: BoxDecoration(color: answered && ok ? const Color(0xFFE8F5E9) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: answered && ok ? WaqtiColors.mint : color.withOpacity(.2), width: 2)),
              child: Center(child: Text(option, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: WaqtiColors.textDark))),
            ),
          );
        }).toList(),
      ),
      if (answered) ...[const SizedBox(height: 16), _nextBtn()],
    ]);
  }

  Widget _nextBtn() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _next,
      style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 52)),
      child: Text(qi == totalQ - 1 ? 'أكمل الدرس 🎉' : 'السؤال التالي ←', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );

  Widget _buildFinish() {
    final stars = correct == totalQ ? 3 : correct >= (totalQ * 2 / 3).ceil() ? 2 : 1;
    final next = CurriculumDatasource.instance.findNext(widget.unit.id, widget.lesson.id);
    final ads = ref.watch(adServiceProvider);
    final premium = ref.watch(progressNotifierProvider).valueOrNull?.isPremium ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(children: [
        const SizedBox(height: 10),
        ZaidMascot(mood: stars == 3 ? ZaidMood.celebrating : ZaidMood.happy, size: 115, speech: stars == 3 ? 'ممتاز! درجة مثالية! 🏆' : 'أحسنت! استمر في التدريب! 💪'),
        const SizedBox(height: 14),
        const Text('انتهى الدرس!', style: TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
        const SizedBox(height: 8),
        Text('${'⭐' * stars}${'☆' * (3 - stars)}', style: const TextStyle(fontSize: 38)),
        const SizedBox(height: 8),
        Text('$correct من $totalQ إجابات صحيحة', style: const TextStyle(fontFamily: 'Cairo', color: WaqtiColors.textMid)),
        const SizedBox(height: 18),
        if (next.lesson != null)
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => context.pushReplacement('/lesson', extra: LessonRouteArgs(unit: next.unit!, lesson: next.lesson!)),
            style: ElevatedButton.styleFrom(backgroundColor: next.unit!.color, padding: const EdgeInsets.symmetric(vertical: 15)),
            child: Text('التالي: ${next.lesson!.title} ${next.unit!.emoji} ←', style: const TextStyle(fontFamily: 'Cairo')),
          )),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => context.go('/'),
          style: ElevatedButton.styleFrom(backgroundColor: WaqtiColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
          child: const Text('العودة للمسار 🏠', style: TextStyle(fontFamily: 'Cairo')),
        )),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () => setState(() { qi = 0; correct = 0; finished = false; results = List<bool?>.filled(totalQ, null); _resetQuestion(); }),
          child: const Text('🔄 أعد الدرس', style: TextStyle(fontFamily: 'Cairo')),
        )),
        if (!premium && ads.rewardedReady) ...[
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Icons.card_giftcard),
            label: const Text('🎁 شاهد إعلانًا واحصل على مكافأة', style: TextStyle(fontFamily: 'Cairo')),
            onPressed: () async {
              await ref.read(adServiceProvider).showRewarded(onRewarded: (amount) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎁 حصلت على $amount نقطة')));
              });
            },
          )),
        ],
        if (!premium && ads.rewardedHintReady) ...[
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('💡 شاهد إعلانًا للحصول على تلميح', style: TextStyle(fontFamily: 'Cairo')),
            onPressed: () async {
              await ref.read(adServiceProvider).showRewardedHint(onRewarded: (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💡 التلميح متاح الآن')));
              });
            },
          )),
        ],
        if (!premium) ...[const SizedBox(height: 14), _banner()],
      ]),
    );
  }

  List<String> _genChoices(int h, int m) {
    String format(int hour, int minute) {
      final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    final pool = <String>{format(h, m)};
    final rng = math.Random();
    const minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
    while (pool.length < 4) {
      pool.add(format(rng.nextInt(12) + 1, minutes[rng.nextInt(minutes.length)]));
    }
    return pool.toList()..shuffle();
  }

  List<_DigChoice> _genDigChoices(int h, int m) {
    String time(int hour, int minute) => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    String period(int hour) => hour < 12 ? 'صباحًا' : 'مساءً';
    final correctTime = time(h, m);
    final seen = <String>{correctTime};
    final list = <_DigChoice>[_DigChoice(correctTime, '$correctTime ${period(h)}')];
    for (final hour in [(h + 12) % 24, (h + 1) % 24, (h + 23) % 24, (h + 6) % 24]) {
      final value = time(hour, m);
      if (seen.add(value) && list.length < 4) list.add(_DigChoice(value, '$value ${period(hour)}'));
    }
    return list..shuffle();
  }
}

class _DigChoice {
  const _DigChoice(this.time, this.label);
  final String time;
  final String label;
}
