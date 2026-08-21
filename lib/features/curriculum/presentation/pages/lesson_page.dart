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
  int qi = 0, correct = 0;
  bool answered = false;
  bool? lastCorrect;
  List<bool?> results = [];
  late ConfettiController _confetti;
  bool finished = false;
  int setH = 12, setM = 0;

  int get totalQ => widget.lesson.totalQuestions;
  Color get color => widget.unit.color;
  SoundService get _sound => ref.read(soundServiceProvider);
  bool get _isCalc => widget.lesson.type == LessonType.timeCalc;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    results = List.filled(totalQ, null);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _sound.stop(WaqtiSound.countdown);
    super.dispose();
  }

  void _resetQ() { answered = false; lastCorrect = null; setH = 12; setM = 0; }

  void _onAnswer(bool ok) {
    setState(() { answered = true; lastCorrect = ok; results[qi] = ok; if (ok) correct++; });
    if (ok) _sound.correct(); else _sound.wrong();
  }

  void _next() {
    _sound.click();
    if (qi < totalQ - 1) setState(() { qi++; _resetQ(); });
    else _finish();
  }

  Future<void> _finish() async {
    setState(() => finished = true);
    final stars = correct == totalQ ? 3 : correct >= (totalQ * 2 / 3).ceil() ? 2 : 1;
    if (stars == 3) { _confetti.play(); await _sound.lessonComplete(); await Future.delayed(600.ms); await _sound.success(); }
    else if (stars == 2) await _sound.lessonComplete();
    else await _sound.notification();

    await ref.read(progressNotifierProvider.notifier)
        .completeLesson(widget.lesson.id, stars, correct, totalQ);
    await ref.read(adServiceProvider).onLessonComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl,
      child: Scaffold(backgroundColor: WaqtiColors.offWhite,
        body: Stack(children: [
          SafeArea(child: finished ? _buildFinish() : _buildQuestion()),
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [WaqtiColors.accent, WaqtiColors.coral, WaqtiColors.mint, WaqtiColors.primary],
            numberOfParticles: 40, emissionFrequency: .08,
          )),
        ]),
      ),
    );
  }

  Widget _buildQuestion() => Column(children: [
    _topBar(),
    Expanded(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(children: [
        _zaidBubble(),
        const SizedBox(height: 16),
        _isCalc ? _buildCalcQ() : _buildTimeQ(),
      ]),
    )),
  ]);

  Widget _topBar() => Container(
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
    color: color,
    child: Column(children: [
      Row(children: [
        IconButton(icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () { _sound.click(); context.pop(); }),
        Expanded(child: Text(widget.lesson.title, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
        Padding(padding: const EdgeInsets.only(left: 8),
          child: Text('${qi+1}/$totalQ', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white))),
      ]),
      const SizedBox(height: 4),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: qi / totalQ,
            backgroundColor: Colors.white.withOpacity(.25),
            valueColor: const AlwaysStoppedAnimation(WaqtiColors.accent),
            minHeight: 7,
          ))),
      const SizedBox(height: 6),
      _scoreBar(),
    ]),
  );

  Widget _scoreBar() => Wrap(
    spacing: 5, alignment: WrapAlignment.center,
    children: List.generate(totalQ, (i) {
      final r = results[i];
      final bg = r == null ? Colors.white.withOpacity(.15) : r ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3F1);
      final fg = r == null ? Colors.white70 : r ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
      return Container(width: 24, height: 24,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: fg.withOpacity(.4), width: 1.5)),
        child: Center(child: Text(r == null ? '${i+1}' : (r ? '✓' : '✗'),
          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: fg))));
    }),
  );

  Widget _zaidBubble() {
    final prompt = _isCalc ? widget.lesson.calcQuestions[qi].prompt : widget.lesson.questions[qi].prompt;
    final mood   = !answered ? ZaidMood.thinking : (lastCorrect == true ? ZaidMood.celebrating : ZaidMood.encouraging);
    return ZaidMascot(mood: mood, size: 80, speech: prompt);
  }

  Widget _buildTimeQ() {
    final q = widget.lesson.questions[qi];
    return switch (q.type) {
      QuestionType.multipleChoice => _buildMC(q),
      QuestionType.setHands       => _buildSetHands(q),
      QuestionType.digitalMC      => _buildDigitalMC(q),
      _                           => _buildMC(q),
    };
  }

  // ── Multiple Choice ─────────────────────────────────────────
  Widget _buildMC(TimeQuestion q) {
    final choices = _genChoices(q.hour, q.minute);
    return Column(children: [
      AnalogClock(hour: q.hour, minute: q.minute, size: WaqtiSize.lessonClockSize(context), color: color),
      const SizedBox(height: 20),
      GridView.count(crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.3,
        children: choices.map((c) {
          final isCorrect = c == q.timeStr;
          final bg     = answered && isCorrect ? const Color(0xFFE8F5E9) : Colors.white;
          final border = answered && isCorrect ? WaqtiColors.mint : color.withOpacity(.2);
          final fg     = answered && isCorrect ? const Color(0xFF2E7D32) : WaqtiColors.textDark;
          return GestureDetector(
            onTap: answered ? null : () { _sound.click(); _onAnswer(c == q.timeStr); },
            child: AnimatedContainer(duration: 200.ms,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 2.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6, offset: const Offset(0,2))]),
              child: Center(child: Text(c, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: fg)))));
        }).toList()),
      const SizedBox(height: 16),
      if (answered) _nextBtn(),
    ]);
  }

  // ── Digital MC ──────────────────────────────────────────────
  Widget _buildDigitalMC(TimeQuestion q) {
    final h12 = q.hour > 12 ? q.hour - 12 : (q.hour == 0 ? 12 : q.hour);
    final choices = _genDigChoices(q.hour, q.minute);
    return Column(children: [
      DigitalClock(hour: h12, minute: q.minute, fontSize: 40),
      const SizedBox(height: 10),
      AmPmBadge(hour: q.hour),
      const SizedBox(height: 6),
      Text('الوقت بالساعة الرقمية: ${q.time24Str}',
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: WaqtiColors.textLight)),
      const SizedBox(height: 18),
      GridView.count(crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.7,
        children: choices.map((c) {
          final isCorrect = c.time == q.time24Str;
          return GestureDetector(
            onTap: answered ? null : () { _sound.click(); _onAnswer(isCorrect); },
            child: AnimatedContainer(duration: 200.ms,
              decoration: BoxDecoration(
                color: answered && isCorrect ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: answered && isCorrect ? WaqtiColors.mint : Colors.black12, width: 2.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6, offset: const Offset(0,2))]),
              padding: const EdgeInsets.all(8),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(c.time, style: const TextStyle(fontFamily: 'Courier New', fontSize: 18, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
                const SizedBox(height: 2),
                Text(c.label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: WaqtiColors.textLight), textAlign: TextAlign.center),
              ])));
        }).toList()),
      const SizedBox(height: 16),
      if (answered) _nextBtn(),
    ]);
  }

  // ── Set Hands ───────────────────────────────────────────────
  Widget _buildSetHands(TimeQuestion q) {
    final correctNow = answered && setH % 12 == q.hour % 12 && setM == q.minute;
    return Column(children: [
      Text.rich(TextSpan(children: [
        const TextSpan(text: 'حرّك العقارب إلى: ', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: WaqtiColors.textMid)),
        TextSpan(text: q.timeStr, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ]), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text(q.arabicTime, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: WaqtiColors.textLight)),
      const SizedBox(height: 16),
      InteractiveClock(
        initialHour: 12, initialMinute: 0,
        size: WaqtiSize.lessonClockSize(context), color: color,
        onChanged: answered ? (h, m) {} : (h, m) {
          _sound.click();
          setState(() { setH = h; setM = m; });
        },
      ),
      const SizedBox(height: 14),
      Text('${setH.toString().padLeft(2,'0')}:${setM.toString().padLeft(2,'0')}',
        style: TextStyle(fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.w800,
          color: answered ? (correctNow ? const Color(0xFF2E7D32) : const Color(0xFFC62828)) : color)),
      if (answered && !correctNow)
        Padding(padding: const EdgeInsets.only(top: 6),
          child: Text('الإجابة الصحيحة: ${q.timeStr} — ${q.arabicTime}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFC62828)))),
      const SizedBox(height: 6),
      const Text('☝️ المس الساعة واسحب العقرب الذي تريد تحريكه',
        style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: WaqtiColors.textLight)),
      const SizedBox(height: 16),
      if (!answered)
        ElevatedButton(
          onPressed: () { _sound.click(); _onAnswer(setH % 12 == q.hour % 12 && setM == q.minute); },
          style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14)),
          child: const Text('✓ تحقّق', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
        )
      else _nextBtn(),
    ]);
  }

  // ── Time Calc ───────────────────────────────────────────────
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
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_back, color: color, size: 28)),
        Column(children: [
          const Text('النهاية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: WaqtiColors.textLight)),
          const SizedBox(height: 4),
          DigitalClock(hour: q.endHour, minute: q.endMinute, second: q.endSecond > 0 ? q.endSecond : null, fontSize: 24),
        ]),
      ]),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(12)),
        child: const Text('🧮 كم من الوقت مرّ؟',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: WaqtiColors.textDark))),
      const SizedBox(height: 18),
      GridView.count(crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.4,
        children: q.options.map((opt) {
          final isCorrect = opt == q.elapsedStr;
          return GestureDetector(
            onTap: answered ? null : () { _sound.click(); _onAnswer(isCorrect); },
            child: AnimatedContainer(duration: 200.ms,
              decoration: BoxDecoration(
                color: answered && isCorrect ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: answered && isCorrect ? WaqtiColors.mint : color.withOpacity(.2), width: 2.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6, offset: const Offset(0,2))]),
              child: Center(child: Text(opt, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: WaqtiColors.textDark)))));
        }).toList()),
      const SizedBox(height: 16),
      if (answered) _nextBtn(),
    ]);
  }

  Widget _nextBtn() {
    final isLast = qi == totalQ - 1;
    return ElevatedButton(
      onPressed: _next,
      style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 52), padding: EdgeInsets.zero),
      child: Text(isLast ? 'أكمل الدرس 🎉' : 'السؤال التالي ←',
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
    ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(.92,.92));
  }

  // ── Finish screen ───────────────────────────────────────────
  Widget _buildFinish() {
    final stars = correct == totalQ ? 3 : correct >= (totalQ*2/3).ceil() ? 2 : 1;
    final pct   = (correct / totalQ * 100).round();
    final next  = CurriculumDatasource.instance.findNext(widget.unit.id, widget.lesson.id);
    final ads   = ref.watch(adServiceProvider);
    final isPremium = ref.watch(progressNotifierProvider).valueOrNull?.isPremium ?? false;

    return SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [
      const SizedBox(height: 12),
      ZaidMascot(
        mood: stars == 3 ? ZaidMood.celebrating : ZaidMood.happy, size: 120,
        speech: stars == 3 ? 'ممتاز! درجة مثالية! 🏆' : stars == 2 ? 'أحسنت! عمل رائع! 🌟' : 'استمر في التدريب! 💪'),
      const SizedBox(height: 20),
      const Text('انتهى الدرس!', style: TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) =>
          Text(i < stars ? '⭐' : '☆', style: const TextStyle(fontSize: 42))
            .animate(delay: Duration(milliseconds: 200+i*150)).scale(begin: const Offset(0,0)))),
      const SizedBox(height: 10),
      Text('$correct من $totalQ إجابات صحيحة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: WaqtiColors.textMid)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, alignment: WrapAlignment.center, children: [
        _pill('الدقة: $pct%'), _pill('✓ $correct / ✗ ${totalQ-correct}'),
      ]),
      const SizedBox(height: 20),
      if (next.lesson != null)
        Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _sound.click();
              context.pushReplacement('/lesson', extra: LessonRouteArgs(unit: next.unit!, lesson: next.lesson!));
            },
            style: ElevatedButton.styleFrom(backgroundColor: next.unit!.color, padding: const EdgeInsets.symmetric(vertical: 15)),
            child: Text('التالي: ${next.lesson!.title} ${next.unit!.emoji} ←',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700))))),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: () { _sound.click(); context.go('/'); },
        style: ElevatedButton.styleFrom(backgroundColor: WaqtiColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
        child: const Text('العودة للمسار 🏠', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)))),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: OutlinedButton(
        onPressed: () { _sound.click(); setState(() { qi=0; correct=0; finished=false; results=List.filled(totalQ,null); _resetQ(); }); },
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
        child: const Text('🔄 أعد الدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: WaqtiColors.textMid)))),
      if (!isPremium && ads.lessonBannerReady && ads.lessonBanner != null) ...[
        const SizedBox(height: 16),
        SizedBox(
          width:  ads.lessonBanner!.size.width.toDouble(),
          height: ads.lessonBanner!.size.height.toDouble(),
          child:  AdWidget(ad: ads.lessonBanner!),
        ),
      ],
    ])));
  }

  Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(color: WaqtiColors.sky, borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: WaqtiColors.primary)));

  // ── Choice generators ───────────────────────────────────────
  static const _minPool = [0,0,15,30,45,5,10,20,25,30,35,40,50,55];

  List<String> _genChoices(int h, int m) {
    String ts(int hh, int mm) {
      final h12 = hh>12?hh-12:(hh==0?12:hh);
      return '${h12.toString().padLeft(2,'0')}:${mm.toString().padLeft(2,'0')}';
    }
    final correct = ts(h, m);
    final pool = <String>{correct};
    final rng = math.Random();
    int tries = 0;
    while (pool.length < 4 && tries++ < 60) {
      pool.add(ts(rng.nextInt(12)+1, _minPool[rng.nextInt(_minPool.length)]));
    }
    return pool.toList()..shuffle();
  }

  List<_DigChoice> _genDigChoices(int h, int m) {
    String t24(int hh, int mm) => '${hh.toString().padLeft(2,'0')}:${mm.toString().padLeft(2,'0')}';
    String apAr(int hh) => hh < 12 ? 'صباحًا' : 'مساءً';
    final correct = t24(h, m);
    final seen = <String>{correct};
    final list = <_DigChoice>[_DigChoice(correct, '$correct ${apAr(h)}', true)];
    final swapH = h < 12 ? h + 12 : h - 12;
    final candidates = [
      _DigChoice(t24(swapH,m),          '${t24(swapH,m)} ${apAr(swapH)}',          false),
      _DigChoice(t24((h+1)%24,m),       '${t24((h+1)%24,m)} ${apAr((h+1)%24)}',   false),
      _DigChoice(t24((h+23)%24,m),      '${t24((h+23)%24,m)} ${apAr((h+23)%24)}', false),
    ];
    if (h==0)          candidates.add(const _DigChoice('12:00','12:00 PM — الظهيرة',false));
    if (h==12 && m==0) candidates.add(const _DigChoice('00:00','00:00 — منتصف الليل',false));
    for (final c in candidates) {
      if (!seen.contains(c.time) && list.length < 4) { seen.add(c.time); list.add(c); }
    }
    final rng = math.Random();
    while (list.length < 4) {
      final rh = rng.nextInt(24); final t = t24(rh,m);
      if (!seen.contains(t)) { seen.add(t); list.add(_DigChoice(t,'$t ${apAr(rh)}',false)); }
    }
    list.shuffle();
    return list;
  }
}

class _DigChoice {
  const _DigChoice(this.time, this.label, this.correct);
  final String time, label;
  final bool   correct;
}
