import 'dart:ui' show Color;

// ══════════════════════════════════════════════════════════════
// Enums
// ══════════════════════════════════════════════════════════════
enum QuestionType { multipleChoice, setHands, digitalMC, timeCalc }
enum LessonType   { analog, digital, mixed, timeCalc }

// ══════════════════════════════════════════════════════════════
// TimeQuestion
// ══════════════════════════════════════════════════════════════
class TimeQuestion {
  const TimeQuestion({
    required this.hour,
    required this.minute,
    required this.type,
    required this.prompt,
  });

  final int          hour, minute;
  final QuestionType type;
  final String       prompt;

  String get timeStr {
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h.toString().padLeft(2,'0')}:${minute.toString().padLeft(2,'0')}';
  }

  String get time24Str =>
      '${hour.toString().padLeft(2,'0')}:${minute.toString().padLeft(2,'0')}';

  String get amPmStr => hour < 12 ? 'AM' : 'PM';

  String get arabicTime {
    const hw = ['','الواحدة','الثانية','الثالثة','الرابعة','الخامسة',
      'السادسة','السابعة','الثامنة','التاسعة','العاشرة','الحادية عشرة','الثانية عشرة'];
    final hr   = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final pm   = hour < 12 ? 'صباحًا' : 'مساءً';
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
// TimeCalcQuestion
// ══════════════════════════════════════════════════════════════
class TimeCalcQuestion {
  const TimeCalcQuestion({
    required this.startHour,
    required this.startMinute,
    this.startSecond = 0,
    required this.endHour,
    required this.endMinute,
    this.endSecond = 0,
    required this.prompt,
  });

  final int startHour, startMinute, startSecond;
  final int endHour,   endMinute,   endSecond;
  final String prompt;

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
      _tweak(elapsedHours, elapsedMinutes > 15 ? elapsedMinutes - 15 : 5, 0),
      _tweak(elapsedMinutes, elapsedHours, 0),
      _tweak(elapsedHours, elapsedMinutes + 15, 0),
    ];
    for (final t in tweaks) { if (opts.length < 4 && t != correct) opts.add(t); }
    while (opts.length < 4) { opts.add(_tweak(opts.length * 7, opts.length * 3, 0)); }
    return opts.toList()..shuffle();
  }

  String _tweak(int h, int m, int s) {
    if (m >= 60) { h += m ~/ 60; m %= 60; }
    if (m < 0) m = 0; if (h < 0) h = 0;
    if (h > 0 && m > 0 && s > 0) return '${h}س ${m}د ${s}ث';
    if (h > 0 && m > 0)           return '${h}س ${m}د';
    if (h > 0)                     return '$h ساعة';
    if (m > 0 && s > 0)           return '${m}د ${s}ث';
    if (m > 0)                     return '$m دقيقة';
    return '$s ثانية';
  }
}

// ══════════════════════════════════════════════════════════════
// Lesson
// ══════════════════════════════════════════════════════════════
class WaqtiLesson {
  const WaqtiLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.questions       = const [],
    this.calcQuestions   = const [],
    this.isFree          = false,
  });

  final String             id, title, subtitle;
  final LessonType         type;
  final List<TimeQuestion>     questions;
  final List<TimeCalcQuestion> calcQuestions;
  final bool               isFree;

  int get totalQuestions => questions.length + calcQuestions.length;
}

// ══════════════════════════════════════════════════════════════
// Unit
// ══════════════════════════════════════════════════════════════
class WaqtiUnit {
  const WaqtiUnit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.lessons,
    required this.color,
    this.isFree = false,
  });

  final String           id, title, subtitle, emoji;
  final List<WaqtiLesson> lessons;
  final Color            color;
  final bool             isFree;
}
