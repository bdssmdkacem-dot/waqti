import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
  int  _h = 3, _m = 0;
  bool _throttle = false;

  static const _hw = [
    '','الواحدة','الثانية','الثالثة','الرابعة','الخامسة','السادسة',
    'السابعة','الثامنة','التاسعة','العاشرة','الحادية عشرة','الثانية عشرة',
  ];

  String get _arabicTime {
    final hr = _h == 0 ? 12 : (_h > 12 ? _h - 12 : _h);
    final pm = _h < 12 ? 'صباحًا' : 'مساءً';
    if (_h == 0  && _m == 0) return 'منتصف الليل';
    if (_h == 12 && _m == 0) return 'منتصف النهار';
    if (_m == 0)  return 'الساعة ${_hw[hr]} $pm';
    if (_m == 30) return 'الساعة ${_hw[hr]} والنصف $pm';
    if (_m == 15) return 'الساعة ${_hw[hr]} والربع $pm';
    if (_m == 45) return 'الساعة ${_hw[(hr%12)+1]} إلا ربعًا $pm';
    return 'الساعة ${_hw[hr]} و$_m دقيقة $pm';
  }

  void _onChanged(int h, int m) {
    setState(() { _h = h; _m = m; });
    if (!_throttle) {
      _throttle = true;
      ref.read(soundServiceProvider).play(WaqtiSound.click);
      Future.delayed(const Duration(milliseconds: 80), () => _throttle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h12 = _h > 12 ? _h - 12 : (_h == 0 ? 12 : _h);
    final clockSz = WaqtiSize.clockSize(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          title: const Text('🕐 العب بالساعة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          leading: BackButton(onPressed: () {
            ref.read(soundServiceProvider).click();
            Navigator.pop(context);
          }),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E9), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              ZaidMascot(mood: ZaidMood.happy, size: 90, speech: _arabicTime),
              const SizedBox(height: 20),
              InteractiveClock(
                initialHour: 3, initialMinute: 0,
                size: clockSz, color: const Color(0xFF2E7D32),
                onChanged: _onChanged,
              ),
              const SizedBox(height: 20),
              DigitalClock(hour: h12, minute: _m, fontSize: 38),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                child: Text(_arabicTime, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
              ),
              const SizedBox(height: 12),
              const Text('☝️ اسحب العقارب لتغيير الوقت',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: WaqtiColors.textLight)),
            ]),
          ),
        ),
      ),
    );
  }
}
