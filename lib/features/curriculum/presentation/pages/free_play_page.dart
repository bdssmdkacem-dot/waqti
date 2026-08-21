import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/ads/data/ad_service.dart';
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

  void _onChanged(int h, int m) {
    setState(() { _h = h; _m = m; });
    if (!_throttle) {
      _throttle = true;
      ref.read(soundServiceProvider).play(WaqtiSound.click);
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _throttle = false;
      });
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
                    mood: ZaidMood.happy,
                    size: 82,
                    speech: 'حرّك العقارب واكتشف الوقت! 🎯',
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
                    child: const Text(
                      'اضبط الساعة ثم اقرأ الوقت بالعقارب والساعة الرقمية',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: WaqtiColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 18, 10, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: WaqtiColors.primary.withOpacity(.12), width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        InteractiveClock(
                          initialHour: 3,
                          initialMinute: 0,
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
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: WaqtiColors.primary),
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
                    Container(
                      width: ads.homeBanner!.size.width.toDouble(),
                      height: ads.homeBanner!.size.height.toDouble(),
                      color: Colors.white,
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
}
