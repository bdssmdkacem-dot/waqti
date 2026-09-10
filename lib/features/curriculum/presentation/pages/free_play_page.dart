import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/ads/data/ad_service.dart';
import '../../../../features/curriculum/data/datasources/curriculum_datasource.dart';
import '../../../../features/curriculum/domain/entities/curriculum_entities.dart';
import '../../../../features/progress/presentation/providers/progress_provider.dart';
import '../../../../features/settings/data/sound_service.dart';
import '../../../../shared/widgets/analog_clock.dart';
import '../../../../shared/widgets/digital_clock.dart';
import '../../../../shared/widgets/zaid_mascot.dart';

class FreePlayPage extends ConsumerStatefulWidget {
  const FreePlayPage({super.key});

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

  static const _hw = [
    '',
    'الواحدة',
    'الثانية',
    'الثالثة',
    'الرابعة',
    'الخامسة',
    'السادسة',
    'السابعة',
    'الثامنة',
    'التاسعة',
    'العاشرة',
    'الحادية عشرة',
    'الثانية عشرة',
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
      questionKey: 'question:${lesson.id}:$index',
      skillKey: 'lesson:${lesson.id}',
      correct: ok,
    );

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
          title: const Text(
            '🕐 العب بالساعة',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
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
                    speech: _challengeQuestion == null
                        ? 'حرّك العقارب واكتشف الوقت! 🎯'
                        : 'تحدٍ سريع: اضبط الساعة على الوقت المطلوب! 🎯',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: const Text(
                      'اضبط الساعة ثم اقرأ الوقت بالعقارب والساعة الرقمية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: WaqtiColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChallengeCard(),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 18, 10, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: WaqtiColors.primary.withValues(alpha: .12),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
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
                          decoration: BoxDecoration(
                            color: WaqtiColors.sky,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _arabicTime,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: WaqtiColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '☝️ اسحب العقارب لتغيير الوقت',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: WaqtiColors.textLight),
                        ),
                      ],
                    ),
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
    final question = _challengeQuestion;
    if (question == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _newChallenge,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            'ابدأ تحدي قراءة الساعة',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: WaqtiColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
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
        color: _challengeCorrect == true
            ? const Color(0xFFE8F5E9)
            : _challengeCorrect == false
                ? const Color(0xFFFFF3F1)
                : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _challengeCorrect == true
              ? WaqtiColors.mint
              : _challengeCorrect == false
                  ? WaqtiColors.coral
                  : WaqtiColors.primary.withValues(alpha: .15),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: WaqtiColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          if (!_challengeAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _checkChallenge,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'تحقق من إجابتي',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WaqtiColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _newChallenge,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'تحدٍ جديد',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: WaqtiColors.primary,
                  side: const BorderSide(color: WaqtiColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
