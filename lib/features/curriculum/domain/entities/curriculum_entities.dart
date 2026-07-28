import 'dart:ui' show Color;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'curriculum_entities.freezed.dart';

// ══════════════════════════════════════════════════════════════
// Enums
// ══════════════════════════════════════════════════════════════
enum QuestionType {
  multipleChoice,  // show analog clock → pick time string
  setHands,        // drag hands to target time
  digitalMC,       // show digital display → pick meaning
  timeCalc,        // elapsed time calculation
}

enum LessonType { analog, digital, mixed, timeCalc }

// ══════════════════════════════════════════════════════════════
// TimeQuestion — for analog/digital/mixed lessons
// ══════════════════════════════════════════════════════════════
@freezed
class TimeQuestion with _$TimeQuestion {
  const factory TimeQuestion({
    required int hour,
    required int minute,
    required QuestionType type,
    required String prompt,
  }) = _TimeQuestion;

  const TimeQuestion._();

  /// e.g. "03:00" (12-hour, for MC display)
  String get timeStr {
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// e.g. "15:30" (24-hour, for digital display)
  String get time24Str =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String get amPmStr => hour < 12 ? 'AM' : 'PM';

  String get arabicTime {
    const hw = [
      '', 'الواحدة', 'الثانية', 'الثالثة', 'الرابعة', 'الخامسة',
      'السادسة', 'السابعة', 'الثامنة', 'التاسعة', 'العاشرة',
      'الحادية عشرة', 'الثانية عشرة',
    ];
    final hr  = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final pm  = hour < 12 ? 'صباحًا' : 'مساءً';
    final word = hw[hr];
    if (hour == 0  && minute == 0) return 'منتصف الليل — 00:00';
    if (hour == 12 && minute == 0) return 'منتصف النهار — 12:00 PM';
    if (minute == 0)  return 'الساعة $word $pm';
    if (minute == 30) return 'الساعة $word والنصف $pm';
    if (minute == 15) return 'الساعة $word والربع $pm';
    if (minute == 45) return 'الساعة ${hw[(hr % 12) + 1]} إلا ربعًا $pm';
    return 'الساعة $word و$minute دقيقة $pm';
  }
}

// ══════════════════════════════════════════════════════════════
// TimeCalcQuestion — for Unit 13 (elapsed time)
// ══════════════════════════════════════════════════════════════
@freezed
class TimeCalcQuestion with _$TimeCalcQuestion {
  const factory TimeCalcQuestion({
    required int startHour,
    required int startMinute,
    @Default(0) int startSecond,
    required int endHour,
    required int endMinute,
    @Default(0) int endSecond,
    required String prompt,
  }) = _TimeCalcQuestion;

  const TimeCalcQuestion._();

  int get elapsedSeconds {
    final s = startHour * 3600 + startMinute * 60 + startSecond;
    int   e = endHour   * 3600 + endMinute   * 60 + endSecond;
    if (e < s) e += 86400;
    return e - s;
  }

  int get elapsedHours   => elapsedSeconds ~/ 3600;
  int get elapsedMinutes => (elapsedSeconds % 3600) ~/ 60;
  int get elapsedSecs    => elapsedSeconds % 60;

  String get elapsedStr {
    final h = elapsedHours, m = elapsedMinutes, s = elapsedSecs;
    if (h > 0 && m > 0 && s > 0) return '${h}س ${m}د ${s}ث';
    if (h > 0 && m > 0)           return '${h}س ${m}د';
    if (h > 0)                     return '$h ساعة';
    if (m > 0 && s > 0)           return '${m}د ${s}ث';
    if (m > 0)                     return '$m دقيقة';
    return '$s ثانية';
  }

  String get startStr =>
      '${startHour.toString().padLeft(2,'0')}:${startMinute.toString().padLeft(2,'0')}'
      '${startSecond > 0 ? ':${startSecond.toString().padLeft(2,'0')}' : ''}';

  String get endStr =>
      '${endHour.toString().padLeft(2,'0')}:${endMinute.toString().padLeft(2,'0')}'
      '${endSecond > 0 ? ':${endSecond.toString().padLeft(2,'0')}' : ''}';

  List<String> get options {
    final correct = elapsedStr;
    final opts = <String>{correct};
    final tweaks = [
      _tweak(elapsedHours, elapsedMinutes + 30, elapsedSecs),
      _tweak(elapsedHours + 1, elapsedMinutes, elapsedSecs),
      _tweak(elapsedHours, elapsedMinutes > 15 ? elapsedMinutes - 15 : 0, 0),
      _tweak(elapsedMinutes, elapsedHours, 0),
      _tweak(elapsedHours, elapsedMinutes + 15, 0),
    ];
    for (final t in tweaks) {
      if (opts.length < 4 && t != correct) opts.add(t);
    }
    return opts.toList()..shuffle();
  }

  String _tweak(int h, int m, int s) {
    var mh = h; var mm = m; var ms = s;
    if (mm >= 60) { mh += mm ~/ 60; mm %= 60; }
    if (mm < 0) mm = 0; if (mh < 0) mh = 0;
    if (mh > 0 && mm > 0 && ms > 0) return '${mh}س ${mm}د ${ms}ث';
    if (mh > 0 && mm > 0)            return '${mh}س ${mm}د';
    if (mh > 0)                       return '$mh ساعة';
    if (mm > 0 && ms > 0)            return '${mm}د ${ms}ث';
    if (mm > 0)                       return '$mm دقيقة';
    return '$ms ثانية';
  }
}

// ══════════════════════════════════════════════════════════════
// Lesson
// ══════════════════════════════════════════════════════════════
@freezed
class WaqtiLesson with _$WaqtiLesson {
  const factory WaqtiLesson({
    required String id,
    required String title,
    required String subtitle,
    required LessonType type,
    @Default([]) List<TimeQuestion> questions,
    @Default([]) List<TimeCalcQuestion> calcQuestions,
    @Default(false) bool isFree,
  }) = _WaqtiLesson;

  const WaqtiLesson._();
  int get totalQuestions => questions.length + calcQuestions.length;
}

// ══════════════════════════════════════════════════════════════
// Unit
// ══════════════════════════════════════════════════════════════
@freezed
class WaqtiUnit with _$WaqtiUnit {
  const factory WaqtiUnit({
    required String id,
    required String title,
    required String subtitle,
    required String emoji,
    required List<WaqtiLesson> lessons,
    @Default(false) bool isFree,
    required Color color,
  }) = _WaqtiUnit;
}
