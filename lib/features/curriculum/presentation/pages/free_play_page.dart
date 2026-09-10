import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/ads/data/ad_service.dart';
import '../../../../features/curriculum/data/datasources/curriculum_datasource.dart';
import '../../../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../../../../features/progress/domain/services/smart_review_engine.dart';
import '../../../../features/progress/presentation/providers/progress_provider.dart';
import '../../../../features/settings/data/sound_service.dart';
import '../../../../shared/widgets/analog_clock.dart';
import '../../../../shared/widgets/digital_clock.dart';
import '../../../../shared/widgets/zaid_mascot.dart';

class FreePlayPage extends ConsumerStatefulWidget {
  const FreePlayPage({super.key, this.smartReview = false});
  final bool smartReview;

  @override
  ConsumerState<FreePlayPage> createState() => _FreePlayPageState();
}

class _FreePlayPageState extends ConsumerState<FreePlayPage> {
  int _h = 3, _m = 0;
  bool _throttle = false;
  WaqtiLesson? _challengeLesson;
  int? _challengeIndex;
  bool _challengeAnswered = false;
  bool? _challengeCorrect;
  final Set<String> _reviewedKeys = <String>{};
  bool _reviewComplete = false;

  static const _hw = [
    '', 'الواحدة', 'الثانية', 'الثالثة', 'الرابعة', 'الخامسة', 'السادسة',
    'السابعة', 'الثامنة', 'التاسعة', 'العاشرة', 'الحادية عشرة', 'الثانية عشرة',
  ];

  String get _arabicTime {
    final hr = _h == 0 ? 12 : (_h > 12 ? _h - 12 : _h);
    final pm = _h < 12 ? 'صباحًا' : 'مساءً';
    if (_h == 0 && _m == 0) return 'منتصف الليل';
    if (_h == 12 && _m == 0) return 'منتصف النهار';
    if (_m == 0) return 'الساعة ${_hw[hr]} $pm';
    if (_m == 30) return 'الساعة ${_hw[hr]} والنصف $pm';
    if (_m == 15) return 'الساعة ${_hw[hr]} والربع $pm';
    if (_m == 45) return 'الساعة ${_hw[(hr % 12) + 1]} إلا ربعًا $pm';
    return 'الساعة ${_hw[hr]} و$_m دقيقة $pm';
  }

  TimeQuestion? get _challengeQuestion {
    final lesson = _challengeLesson;
    final index = _challengeIndex;
    if (lesson == null || index == null || index >= lesson.questions.length) return null;
    return lesson.questions[index];
  }

  @override
  void initState() {
    super.initState();
    if (widget.smartReview) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _newChallenge());
    }
  }

  void _onChanged(int h, int m) {
    setState(() {
      _h = h;
      _m = m;
      if (!_challengeAnswered) _challengeCorrect = null;
    });
    if (!_throttle) {
      _throttle = true;
      ref.read(soundServiceProvider).play(WaqtiSound.click);
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _throttle = false;
      });
    }
  }

  void _newChallenge() {
    if (widget.smartReview) {
      final progress = ref.read(progressNotifierProvider).valueOrNull;
      if (progress == null) return;
      final candidates = const SmartReviewEngine()
          .buildSession(
            units: CurriculumDatasource.instance.getUnits(),
            progress: progress,
          )
          .where((candidate) => !_reviewedKeys.contains(candidate.questionKey))
          .toList(growable: false);
      if (candidates.isEmpty) {
        setState(() {
          _challengeLesson = null;
          _challengeIndex = null;
          _challengeAnswered = false;
          _challengeCorrect = null;
          _reviewComplete = _reviewedKeys.isNotEmpty;
        });
        return;
      }
      final candidate = candidates.first;
      ref.read(soundServiceProvider).play(WaqtiSound.click);
      setState(() {
        _challengeLesson = candidate.lesson;
        _challengeIndex = candidate.questionIndex;
        _challengeAnswered = false;
        _challengeCorrect = null;
        _reviewComplete = false;
        _h = 3;
        _m = 0;
      });
      return;
    }

    final lessons = CurriculumDatasource.instance
        .getUnits()
        .expand((unit) => unit.lessons)
        .where((lesson) => lesson.questions.isNotEmpty)
        .toList();
    if (lessons.isEmpty) return;

    final random = Random();
    final lesson = lessons[random.nextInt(lessons.length)];
    final index = random.nextInt(lesson.questions.length);

    ref.read(soundServiceProvider).play(WaqtiSound.click);
    setState(() {
      _challengeLesson = lesson;
      _challengeIndex = index;
      _challengeAnswered = false;
      _challengeCorrect = null;
      _h = 3;
      _m = 0;
    });
  }

  Future<void> _checkChallenge() async {
    final question = _challengeQuestion;
    final lesson = _challengeLesson;
    final index = _challengeIndex;
    if (question == null || lesson == null || index == null || _challengeAnswered) return;

    final ok = _h == question.hour && _m == question.minute;
    setState(() {
      _challengeAnswered = true;
      _challengeCorrect = ok;
    });

    await ref.read(progressNotifierProvider.notifier).recordQuestionResult(
      questionKey: SmartReviewEngine.questionKey(lesson.id, index),
      skillKey: SmartReviewEngine.skillKey(lesson.id),
      correct: ok,
    );
    if (widget.smartReview) _reviewedKeys.add(SmartReviewEngine.questionKey(lesson.id, index));

    if (ok) {
      await ref.read(soundServiceProvider).correct();
    } else {
      await ref.read(soundServiceProvider).wrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final h12 = _h > 12 ? _h - 12 : (_h == 0 ? 12 : _h);
    final clockSz = WaqtiSize.clockSize(context).clamp(230.0, 320.0);
    final ads = ref.watch(adServiceProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WaqtiColors.offWhite,
        appBar: AppBar(
          backgroundColor: WaqtiColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.smartReview ? '🧠 المراجعة الذكية' : '🕐 العب بالساعة',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [WaqtiColors.sky, WaqtiColors.offWhite],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                children: [
                  ZaidMascot(
                    mood: _challengeCorrect == true
                        ? ZaidMood.celebrating
                        : _challengeCorrect == false
                            ? ZaidMood.encouraging
                            : ZaidMood.happy,
                    size: 82,
                    speech: _reviewComplete
                        ? 'أحسنت! أنهيت المراجعة المطلوبة 🎉'
                        : _challengeQuestion == null
                            ? 'حرّك العقارب واكتشف الوقت! 🎯'
                            : widget.smartReview
                                ? 'سنركز على هذا السؤال لأنه يحتاج تدريبًا أكثر. 🧠'
                                : 'تحدٍ سريع: اضبط الساعة على الوقت المطلوب! 🎯',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
                    ),
                    child: Text(
                      widget.smartReview
                          ? 'الأسئلة تتغير حسب أخطائك، وعند تحسن مهارة ننتقل للأولوية التالية.'
                          : 'اضبط الساعة ثم اقرأ الوقت بالعقارب والساعة الرقمية',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: WaqtiColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChallengeCard(),
                  const SizedBox(height: 14),
                  if (!_reviewComplete)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 18, 10, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: WaqtiColors.primary.withValues(alpha: .12), width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 5))],
                      ),
                      child: Column(children: [
                        InteractiveClock(
                          key: ValueKey('${_challengeLesson?.id}:$_challengeIndex'),
                          initialHour: _h,
                          initialMinute: _m,
                          size: clockSz,
                          color: WaqtiColors.primary,
                          onChanged: _onChanged,
                        ),
                        const SizedBox(height: 12),
                        DigitalClock(hour: h12, minute: _m, fontSize: 36),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: WaqtiColors.sky, borderRadius: BorderRadius.circular(14)),
                          child: Text(_arabicTime, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: WaqtiColors.primary)),
                        ),
                        const SizedBox(height: 10),
                        const Text('☝️ اسحب العقارب لتغيير الوقت', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: WaqtiColors.textLight)),
                      ]),
                    ),
                  if (ads.homeBannerReady && ads.homeBanner != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: ads.homeBanner!.size.width.toDouble(),
                      height: ads.homeBanner!.size.height.toDouble(),
                      child: AdWidget(ad: ads.homeBanner!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard() {
    if (_reviewComplete) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(18), border: Border.all(color: WaqtiColors.mint, width: 2)),
        child: Column(children: [
          const Text('🎉', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          const Text('انتهت المراجعة الذكية', style: TextStyle(fontFamily: 'Cairo', fontSize: 19, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
          const SizedBox(height: 6),
          Text('راجعنا ${_reviewedKeys.length} سؤالًا مرتبطًا بأخطائك.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: WaqtiColors.textLight)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check),
            label: const Text('العودة للتقدم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ]),
      );
    }

    final question = _challengeQuestion;
    if (question == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _newChallenge,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(widget.smartReview ? 'ابدأ المراجعة الذكية' : 'ابدأ تحدي قراءة الساعة', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(backgroundColor: WaqtiColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ),
      );
    }

    final message = _challengeCorrect == null
        ? 'اضبط العقارب على: ${question.arabicTime}'
        : _challengeCorrect == true
            ? 'أحسنت! إجابة صحيحة ⭐'
            : 'حاول مرة أخرى. الوقت الصحيح: ${question.arabicTime}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _challengeCorrect == true ? const Color(0xFFE8F5E9) : _challengeCorrect == false ? const Color(0xFFFFF3F1) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _challengeCorrect == true ? WaqtiColors.mint : _challengeCorrect == false ? WaqtiColors.coral : WaqtiColors.primary.withValues(alpha: .15), width: 2),
      ),
      child: Column(children: [
        Text(message, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: WaqtiColors.textDark)),
        const SizedBox(height: 10),
        if (!_challengeAnswered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _checkChallenge,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('تحقق من إجابتي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(backgroundColor: WaqtiColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _newChallenge,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(widget.smartReview ? 'السؤال التالي' : 'تحدٍ جديد', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(foregroundColor: WaqtiColors.primary, side: const BorderSide(color: WaqtiColors.primary), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
      ]),
    );
  }
}
