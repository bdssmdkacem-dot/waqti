import 'dart:ui';

import '../../domain/entities/curriculum_entities.dart';

/// Pure in-memory curriculum data source.
/// All 13 units, 50+ lessons, 300+ questions.
class CurriculumDatasource {
  const CurriculumDatasource._();
  static const CurriculumDatasource instance = CurriculumDatasource._();

  List<WaqtiUnit> getUnits() => _units;

  WaqtiUnit? findUnit(String uid) {
    try { return _units.firstWhere((u) => u.id == uid); }
    catch (_) { return null; }
  }

  WaqtiLesson? findLesson(String uid, String lid) {
    final u = findUnit(uid);
    if (u == null) return null;
    try { return u.lessons.firstWhere((l) => l.id == lid); }
    catch (_) { return null; }
  }

  ({WaqtiUnit? unit, WaqtiLesson? lesson}) findNext(String uid, String lid) {
    for (int ui = 0; ui < _units.length; ui++) {
      final unit = _units[ui];
      for (int li = 0; li < unit.lessons.length; li++) {
        if (unit.id == uid && unit.lessons[li].id == lid) {
          if (li + 1 < unit.lessons.length) {
            return (unit: unit, lesson: unit.lessons[li + 1]);
          }
          if (ui + 1 < _units.length) {
            return (unit: _units[ui+1], lesson: _units[ui+1].lessons[0]);
          }
          return (unit: null, lesson: null);
        }
      }
    }
    return (unit: null, lesson: null);
  }
}

// ══════════════════════════════════════════════════════════════
// CURRICULUM DATA — 13 Units
// ══════════════════════════════════════════════════════════════
const _units = <WaqtiUnit>[
  // ── Unit 1: Full Hours ──────────────────────────────────────
  WaqtiUnit(
    id: 'u1', title: 'أبطال الساعة', subtitle: 'الساعات الكاملة',
    emoji: '⭐', isFree: true, color: Color(0xFF1565C0),
    lessons: [
      WaqtiLesson(id:'u1l1', title:'عقارب الساعة', subtitle:'الدرس ١',
        type: LessonType.analog, isFree: true, questions: [
          TimeQuestion(hour:3,  minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة الآن؟'),
          TimeQuestion(hour:6,  minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:9,  minute:0, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:12, minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة الآن؟'),
          TimeQuestion(hour:1,  minute:0, type:QuestionType.setHands,       prompt:'حرّك للساعة الواحدة'),
        ]),
      WaqtiLesson(id:'u1l2', title:'الواحدة حتى السادسة', subtitle:'الدرس ٢',
        type: LessonType.analog, isFree: true, questions: [
          TimeQuestion(hour:1, minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:2, minute:0, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:4, minute:0, type:QuestionType.setHands,       prompt:'حرّك للرابعة'),
          TimeQuestion(hour:5, minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة الآن؟'),
          TimeQuestion(hour:6, minute:0, type:QuestionType.setHands,       prompt:'اضبط على السادسة'),
        ]),
      WaqtiLesson(id:'u1l3', title:'السابعة حتى الثانية عشرة', subtitle:'الدرس ٣',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:7,  minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:8,  minute:0, type:QuestionType.setHands,       prompt:'حرّك للثامنة'),
          TimeQuestion(hour:10, minute:0, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:11, minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة الآن؟'),
          TimeQuestion(hour:12, minute:0, type:QuestionType.setHands,       prompt:'اضبط على الثانية عشرة'),
        ]),
      WaqtiLesson(id:'u1l4', title:'مراجعة الساعات الكاملة', subtitle:'الدرس ٤',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:3,  minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:7,  minute:0, type:QuestionType.setHands,       prompt:'حرّك للسابعة'),
          TimeQuestion(hour:11, minute:0, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:2,  minute:0, type:QuestionType.setHands,       prompt:'اضبط على الثانية'),
          TimeQuestion(hour:9,  minute:0, type:QuestionType.multipleChoice, prompt:'كم الساعة الآن؟'),
        ]),
    ],
  ),

  // ── Unit 2: Half Hours ──────────────────────────────────────
  WaqtiUnit(
    id:'u2', title:'النصف الجميل', subtitle:'الساعة والنصف',
    emoji:'🌙', color:Color(0xFF6A1B9A),
    lessons: [
      WaqtiLesson(id:'u2l1', title:'والنصف - مقدمة', subtitle:'الدرس ١',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:3,  minute:30, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:6,  minute:30, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:9,  minute:30, type:QuestionType.setHands,       prompt:'حرّك للتاسعة والنصف'),
          TimeQuestion(hour:12, minute:30, type:QuestionType.multipleChoice, prompt:'كم الساعة الآن؟'),
        ]),
      WaqtiLesson(id:'u2l2', title:'تدريب النصف', subtitle:'الدرس ٢',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:1,  minute:30, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:4,  minute:30, type:QuestionType.setHands,       prompt:'حرّك للرابعة والنصف'),
          TimeQuestion(hour:7,  minute:30, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:10, minute:30, type:QuestionType.setHands,       prompt:'اضبط العاشرة والنصف'),
        ]),
      WaqtiLesson(id:'u2l3', title:'بطل النصف', subtitle:'الدرس ٣',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:2,  minute:30, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:5,  minute:30, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:8,  minute:30, type:QuestionType.setHands,       prompt:'حرّك للثامنة والنصف'),
          TimeQuestion(hour:11, minute:30, type:QuestionType.multipleChoice, prompt:'كم الساعة الآن؟'),
        ]),
    ],
  ),

  // ── Unit 3: Quarters ────────────────────────────────────────
  WaqtiUnit(
    id:'u3', title:'مغامرة الربع', subtitle:'والربع وإلا ربعًا',
    emoji:'🌟', color:Color(0xFF00695C),
    lessons: [
      WaqtiLesson(id:'u3l1', title:'والربع', subtitle:'الدرس ١',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:3, minute:15, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:6, minute:15, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:9, minute:15, type:QuestionType.setHands,       prompt:'حرّك للتاسعة والربع'),
          TimeQuestion(hour:12,minute:15, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u3l2', title:'إلا ربعًا', subtitle:'الدرس ٢',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:3,  minute:45, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:6,  minute:45, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:9,  minute:45, type:QuestionType.setHands,       prompt:'حرّك للعاشرة إلا ربعًا'),
          TimeQuestion(hour:11, minute:45, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u3l3', title:'الربع والنصف معاً', subtitle:'الدرس ٣',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:2,  minute:15, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:4,  minute:45, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:7,  minute:30, type:QuestionType.setHands,       prompt:'حرّك للسابعة والنصف'),
          TimeQuestion(hour:10, minute:15, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:5,  minute:45, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
        ]),
      WaqtiLesson(id:'u3l4', title:'بطل الربع 🏅', subtitle:'الدرس ٤',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:1,  minute:15, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:5,  minute:45, type:QuestionType.multipleChoice, prompt:'ما هذا الوقت؟'),
          TimeQuestion(hour:11, minute:30, type:QuestionType.setHands,       prompt:'حرّك للحادية عشرة والنصف'),
          TimeQuestion(hour:8,  minute:45, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
    ],
  ),

  // ── Unit 4: Five-minute steps ───────────────────────────────
  WaqtiUnit(
    id:'u4', title:'عدّ بالخمسة', subtitle:'الدقائق بالخمسات',
    emoji:'🚀', color:Color(0xFFBF360C),
    lessons: [
      WaqtiLesson(id:'u4l1', title:'٥ و١٠ دقائق', subtitle:'الدرس ١',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:3, minute:5,  type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:7, minute:10, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:1, minute:5,  type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:9, minute:10, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u4l2', title:'٢٠ و٢٥ و٤٠ دقيقة', subtitle:'الدرس ٢',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:4, minute:20, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:9, minute:25, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:2, minute:40, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:6, minute:25, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u4l3', title:'٣٥ و٥٠ و٥٥ دقيقة', subtitle:'الدرس ٣',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:6,  minute:35, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:11, minute:50, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:8,  minute:55, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:3,  minute:40, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u4l4', title:'بطل الخمسات 🚀', subtitle:'الدرس ٤',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:1,  minute:25, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:5,  minute:50, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:9,  minute:35, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:11, minute:20, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:4,  minute:55, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
        ]),
    ],
  ),

  // ── Unit 5: Any minute ──────────────────────────────────────
  WaqtiUnit(
    id:'u5', title:'أسياد الوقت', subtitle:'أي دقيقة في الساعة',
    emoji:'👑', color:Color(0xFFAD1457),
    lessons: [
      WaqtiLesson(id:'u5l1', title:'الدقيقة بالدقيقة', subtitle:'الدرس ١',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:11, minute:43, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:2,  minute:51, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:7,  minute:17, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:4,  minute:38, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u5l2', title:'الأوقات الصعبة', subtitle:'الدرس ٢',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:4, minute:37, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:8, minute:23, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:1, minute:58, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:6, minute:44, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u5l3', title:'تحدي الدقائق', subtitle:'الدرس ٣',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:6,  minute:47, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:3,  minute:13, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:10, minute:29, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:9,  minute:52, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:2,  minute:7,  type:QuestionType.setHands,       prompt:'اضبط الساعة'),
        ]),
      WaqtiLesson(id:'u5l4', title:'بطل الدقائق 👑', subtitle:'الدرس ٤',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:9,  minute:41, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:5,  minute:3,  type:QuestionType.setHands,       prompt:'اضبط الساعة'),
          TimeQuestion(hour:12, minute:59, type:QuestionType.multipleChoice, prompt:'ما الوقت؟'),
          TimeQuestion(hour:7,  minute:27, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
          TimeQuestion(hour:2,  minute:48, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
        ]),
    ],
  ),

  // ── Unit 6: Digital clock ────────────────────────────────────
  WaqtiUnit(
    id:'u6', title:'الساعة الرقمية', subtitle:'AM/PM و00:00 vs 12:00',
    emoji:'📱', color:Color(0xFF1A237E),
    lessons: [
      WaqtiLesson(id:'u6l1', title:'مقدمة: AM و PM', subtitle:'الدرس ١',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:9,  minute:0,  type:QuestionType.digitalMC, prompt:'ما هذا الوقت الرقمي؟'),
          TimeQuestion(hour:3,  minute:0,  type:QuestionType.digitalMC, prompt:'ما هذا الوقت الرقمي؟'),
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC, prompt:'12:00 — صباح أم مساء؟'),
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC, prompt:'00:00 — متى تكون؟'),
        ]),
      WaqtiLesson(id:'u6l2', title:'منتصف الليل vs الظهر', subtitle:'الدرس ٢',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC, prompt:'00:00 ماذا يعني؟'),
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC, prompt:'12:00 PM ماذا يعني؟'),
          TimeQuestion(hour:0,  minute:30, type:QuestionType.digitalMC, prompt:'00:30 متى هذا؟'),
          TimeQuestion(hour:12, minute:30, type:QuestionType.digitalMC, prompt:'12:30 PM متى هذا؟'),
          TimeQuestion(hour:1,  minute:0,  type:QuestionType.digitalMC, prompt:'01:00 AM كم الساعة؟'),
          TimeQuestion(hour:23, minute:59, type:QuestionType.digitalMC, prompt:'23:59 متى هذا بالضبط؟'),
        ]),
      WaqtiLesson(id:'u6l3', title:'تحويل AM → رقمي', subtitle:'الدرس ٣',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:6,  minute:0,  type:QuestionType.digitalMC, prompt:'السادسة صباحًا بالرقمي؟'),
          TimeQuestion(hour:8,  minute:30, type:QuestionType.digitalMC, prompt:'الثامنة والنصف صباحًا؟'),
          TimeQuestion(hour:11, minute:45, type:QuestionType.digitalMC, prompt:'الحادية عشرة إلا ربعًا صباحًا؟'),
          TimeQuestion(hour:7,  minute:15, type:QuestionType.digitalMC, prompt:'السابعة والربع صباحًا؟'),
        ]),
      WaqtiLesson(id:'u6l4', title:'تحويل PM → رقمي (24h)', subtitle:'الدرس ٤',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:13, minute:0,  type:QuestionType.digitalMC, prompt:'الواحدة مساءً بنظام 24 ساعة؟'),
          TimeQuestion(hour:15, minute:30, type:QuestionType.digitalMC, prompt:'الثالثة والنصف بعد الظهر؟'),
          TimeQuestion(hour:18, minute:0,  type:QuestionType.digitalMC, prompt:'السادسة مساءً؟'),
          TimeQuestion(hour:21, minute:45, type:QuestionType.digitalMC, prompt:'التاسعة وثلاثة أرباع مساءً؟'),
          TimeQuestion(hour:23, minute:0,  type:QuestionType.digitalMC, prompt:'الحادية عشرة ليلاً؟'),
        ]),
    ],
  ),

  // ── Unit 7: AM vs PM ─────────────────────────────────────────
  WaqtiUnit(
    id:'u7', title:'صباح ومساء', subtitle:'الفرق بين AM و PM',
    emoji:'🌅', color:Color(0xFFE65100),
    lessons: [
      WaqtiLesson(id:'u7l1', title:'الصباح الباكر (AM)', subtitle:'الدرس ١',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:6,  minute:0,  type:QuestionType.digitalMC, prompt:'السادسة صباحًا رقمياً؟'),
          TimeQuestion(hour:7,  minute:30, type:QuestionType.digitalMC, prompt:'السابعة والنصف صباحًا؟'),
          TimeQuestion(hour:11, minute:0,  type:QuestionType.digitalMC, prompt:'الحادية عشرة صباحًا؟'),
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC, prompt:'منتصف الليل رقمياً؟'),
        ]),
      WaqtiLesson(id:'u7l2', title:'بعد الظهر (PM)', subtitle:'الدرس ٢',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC, prompt:'الظهيرة رقمياً؟'),
          TimeQuestion(hour:14, minute:0,  type:QuestionType.digitalMC, prompt:'الثانية بعد الظهر (24h)؟'),
          TimeQuestion(hour:16, minute:30, type:QuestionType.digitalMC, prompt:'الرابعة والنصف مساءً؟'),
          TimeQuestion(hour:20, minute:0,  type:QuestionType.digitalMC, prompt:'الثامنة مساءً؟'),
        ]),
      WaqtiLesson(id:'u7l3', title:'مقارنة AM و PM', subtitle:'الدرس ٣',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:3,  minute:0,  type:QuestionType.digitalMC, prompt:'03:00 AM متى هذا؟'),
          TimeQuestion(hour:15, minute:0,  type:QuestionType.digitalMC, prompt:'15:00 متى هذا؟'),
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC, prompt:'12:00 صباح أم مساء؟'),
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC, prompt:'00:00 صباح أم مساء؟'),
          TimeQuestion(hour:11, minute:59, type:QuestionType.digitalMC, prompt:'11:59 AM متى بالضبط؟'),
        ]),
      WaqtiLesson(id:'u7l4', title:'بطل AM/PM 🏆', subtitle:'الدرس ٤',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:0,  minute:0, type:QuestionType.digitalMC, prompt:'00:00 يساوي؟'),
          TimeQuestion(hour:12, minute:0, type:QuestionType.digitalMC, prompt:'12:00 PM يساوي؟'),
          TimeQuestion(hour:23, minute:59,type:QuestionType.digitalMC, prompt:'23:59 يساوي؟'),
          TimeQuestion(hour:1,  minute:0, type:QuestionType.digitalMC, prompt:'01:00 AM يساوي؟'),
          TimeQuestion(hour:13, minute:0, type:QuestionType.digitalMC, prompt:'01:00 PM بنظام 24h؟'),
        ]),
    ],
  ),

  // ── Unit 8: Analog ↔ Digital ─────────────────────────────────
  WaqtiUnit(
    id:'u8', title:'رقمي ↔ تناظري', subtitle:'ربط النوعين معاً',
    emoji:'🔄', color:Color(0xFF4527A0),
    lessons: [
      WaqtiLesson(id:'u8l1', title:'من تناظري إلى رقمي', subtitle:'الدرس ١',
        type: LessonType.mixed, questions: [
          TimeQuestion(hour:3,  minute:0,  type:QuestionType.multipleChoice, prompt:'ما الوقت الرقمي (AM)؟'),
          TimeQuestion(hour:6,  minute:30, type:QuestionType.multipleChoice, prompt:'ما الوقت الرقمي؟'),
          TimeQuestion(hour:9,  minute:15, type:QuestionType.multipleChoice, prompt:'ما الوقت الرقمي؟'),
          TimeQuestion(hour:11, minute:45, type:QuestionType.multipleChoice, prompt:'ما الوقت الرقمي؟'),
        ]),
      WaqtiLesson(id:'u8l2', title:'من رقمي إلى تناظري', subtitle:'الدرس ٢',
        type: LessonType.mixed, questions: [
          TimeQuestion(hour:4,  minute:0,  type:QuestionType.setHands, prompt:'اضبط لـ 04:00 AM'),
          TimeQuestion(hour:7,  minute:30, type:QuestionType.setHands, prompt:'اضبط لـ 07:30 AM'),
          TimeQuestion(hour:10, minute:15, type:QuestionType.setHands, prompt:'اضبط لـ 10:15 AM'),
          TimeQuestion(hour:2,  minute:45, type:QuestionType.setHands, prompt:'اضبط لـ 02:45 AM'),
        ]),
      WaqtiLesson(id:'u8l3', title:'بطل الربط', subtitle:'الدرس ٣',
        type: LessonType.mixed, questions: [
          TimeQuestion(hour:8,  minute:20, type:QuestionType.multipleChoice, prompt:'ما الوقت الرقمي؟'),
          TimeQuestion(hour:1,  minute:55, type:QuestionType.multipleChoice, prompt:'ما الوقت الرقمي؟'),
          TimeQuestion(hour:5,  minute:10, type:QuestionType.setHands,       prompt:'اضبط لـ 05:10 AM'),
          TimeQuestion(hour:11, minute:35, type:QuestionType.multipleChoice, prompt:'ما الوقت الرقمي؟'),
          TimeQuestion(hour:3,  minute:48, type:QuestionType.setHands,       prompt:'اضبط الساعة'),
        ]),
    ],
  ),

  // ── Unit 9: Daily Routine ────────────────────────────────────
  WaqtiUnit(
    id:'u9', title:'يومي مع الساعة', subtitle:'روتين يومي',
    emoji:'🌈', color:Color(0xFF00838F),
    lessons: [
      WaqtiLesson(id:'u9l1', title:'الصباح', subtitle:'الدرس ١',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:6, minute:30, type:QuestionType.digitalMC, prompt:'وقت الاستيقاظ؟'),
          TimeQuestion(hour:7, minute:0,  type:QuestionType.digitalMC, prompt:'وقت الفطور؟'),
          TimeQuestion(hour:8, minute:0,  type:QuestionType.digitalMC, prompt:'وقت المدرسة؟'),
          TimeQuestion(hour:7, minute:45, type:QuestionType.digitalMC, prompt:'وقت الخروج؟'),
        ]),
      WaqtiLesson(id:'u9l2', title:'المدرسة والمساء', subtitle:'الدرس ٢',
        type: LessonType.digital, questions: [
          TimeQuestion(hour:8,  minute:30, type:QuestionType.digitalMC, prompt:'بداية الدراسة؟'),
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC, prompt:'وقت الغداء؟'),
          TimeQuestion(hour:15, minute:0,  type:QuestionType.digitalMC, prompt:'وقت اللعب؟'),
          TimeQuestion(hour:21, minute:0,  type:QuestionType.digitalMC, prompt:'وقت النوم؟'),
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC, prompt:'منتصف الليل رقمياً؟'),
        ]),
    ],
  ),

  // ── Unit 10: Speed Challenge ─────────────────────────────────
  WaqtiUnit(
    id:'u10', title:'تحدي السرعة', subtitle:'اقرأ الوقت بسرعة',
    emoji:'⚡', color:Color(0xFF558B2F),
    lessons: [
      WaqtiLesson(id:'u10l1', title:'سريع — ساعات', subtitle:'الدرس ١',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:4,  minute:0, type:QuestionType.multipleChoice, prompt:'سريع!'),
          TimeQuestion(hour:8,  minute:0, type:QuestionType.multipleChoice, prompt:'سريع!'),
          TimeQuestion(hour:11, minute:0, type:QuestionType.multipleChoice, prompt:'سريع!'),
          TimeQuestion(hour:2,  minute:0, type:QuestionType.setHands,       prompt:'اضبط سريعاً!'),
          TimeQuestion(hour:7,  minute:0, type:QuestionType.multipleChoice, prompt:'سريع!'),
        ]),
      WaqtiLesson(id:'u10l2', title:'سريع — دقائق صعبة', subtitle:'الدرس ٢',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:3,  minute:25, type:QuestionType.multipleChoice, prompt:'سريع!'),
          TimeQuestion(hour:7,  minute:42, type:QuestionType.multipleChoice, prompt:'سريع!'),
          TimeQuestion(hour:11, minute:8,  type:QuestionType.setHands,       prompt:'اضبط سريعاً!'),
          TimeQuestion(hour:5,  minute:37, type:QuestionType.multipleChoice, prompt:'سريع!'),
          TimeQuestion(hour:9,  minute:53, type:QuestionType.multipleChoice, prompt:'سريع!'),
        ]),
      WaqtiLesson(id:'u10l3', title:'بطل السرعة 🏆', subtitle:'الدرس ٣',
        type: LessonType.mixed, questions: [
          TimeQuestion(hour:2,  minute:47, type:QuestionType.multipleChoice, prompt:'هيا!'),
          TimeQuestion(hour:6,  minute:13, type:QuestionType.multipleChoice, prompt:'هيا!'),
          TimeQuestion(hour:10, minute:58, type:QuestionType.setHands,       prompt:'هيا!'),
          TimeQuestion(hour:4,  minute:32, type:QuestionType.multipleChoice, prompt:'هيا!'),
          TimeQuestion(hour:8,  minute:19, type:QuestionType.multipleChoice, prompt:'هيا!'),
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC,      prompt:'هيا! منتصف الليل؟'),
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC,      prompt:'هيا! الظهر؟'),
        ]),
    ],
  ),

  // ── Unit 11: Elapsed Time ────────────────────────────────────
  WaqtiUnit(
    id:'u11', title:'كم مرّ من الوقت؟', subtitle:'حساب المدة الزمنية',
    emoji:'⏳', color:Color(0xFF37474F),
    lessons: [
      WaqtiLesson(id:'u11l1', title:'نصف ساعة وساعة', subtitle:'الدرس ١',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:3, minute:30, type:QuestionType.multipleChoice, prompt:'نصف ساعة بعد الثالثة؟'),
          TimeQuestion(hour:7, minute:30, type:QuestionType.multipleChoice, prompt:'نصف ساعة بعد السابعة؟'),
          TimeQuestion(hour:4, minute:0,  type:QuestionType.multipleChoice, prompt:'ساعة بعد الثالثة؟'),
          TimeQuestion(hour:9, minute:0,  type:QuestionType.multipleChoice, prompt:'ساعة بعد الثامنة؟'),
        ]),
      WaqtiLesson(id:'u11l2', title:'بطل المدة ⏳', subtitle:'الدرس ٢',
        type: LessonType.analog, questions: [
          TimeQuestion(hour:5,  minute:0,  type:QuestionType.multipleChoice, prompt:'ساعتان بعد الثالثة؟'),
          TimeQuestion(hour:6,  minute:15, type:QuestionType.multipleChoice, prompt:'ربع ساعة بعد السادسة؟'),
          TimeQuestion(hour:3,  minute:30, type:QuestionType.setHands,       prompt:'ساعة ونصف بعد الثانية'),
          TimeQuestion(hour:10, minute:0,  type:QuestionType.multipleChoice, prompt:'ساعتان بعد الثامنة؟'),
        ]),
    ],
  ),

  // ── Unit 12: Grand Master ────────────────────────────────────
  WaqtiUnit(
    id:'u12', title:'أسطورة الوقت', subtitle:'التحدي الأكبر',
    emoji:'🏆', color:Color(0xFF4E342E),
    lessons: [
      WaqtiLesson(id:'u12l1', title:'تحدي مختلط', subtitle:'الدرس ١',
        type: LessonType.mixed, questions: [
          TimeQuestion(hour:11, minute:43, type:QuestionType.multipleChoice, prompt:'دقيقة بدقيقة!'),
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC,      prompt:'منتصف الليل رقمياً؟'),
          TimeQuestion(hour:7,  minute:17, type:QuestionType.setHands,       prompt:'اضبط بدقة'),
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC,      prompt:'الظهيرة رقمياً؟'),
          TimeQuestion(hour:4,  minute:38, type:QuestionType.multipleChoice, prompt:'كم الساعة؟'),
        ]),
      WaqtiLesson(id:'u12l2', title:'تتويج الأسطورة 👑', subtitle:'الدرس ٢',
        type: LessonType.mixed, questions: [
          TimeQuestion(hour:9,  minute:41, type:QuestionType.multipleChoice, prompt:'أنت أسطورة؟'),
          TimeQuestion(hour:23, minute:59, type:QuestionType.digitalMC,      prompt:'23:59 متى هذا؟'),
          TimeQuestion(hour:5,  minute:3,  type:QuestionType.setHands,       prompt:'أثبت!'),
          TimeQuestion(hour:12, minute:0,  type:QuestionType.digitalMC,      prompt:'12:00 PM الظهر أم منتصف الليل؟'),
          TimeQuestion(hour:0,  minute:0,  type:QuestionType.digitalMC,      prompt:'00:00 الظهر أم منتصف الليل؟'),
          TimeQuestion(hour:11, minute:16, type:QuestionType.multipleChoice, prompt:'أثبت أنك أسطورة!'),
        ]),
    ],
  ),

  // ── Unit 13: Time Calculation ────────────────────────────────
  WaqtiUnit(
    id:'u13', title:'حساب الوقت', subtitle:'جمع وطرح الساعات والدقائق والثواني',
    emoji:'🧮', color:Color(0xFF1B5E20),
    lessons: [
      WaqtiLesson(id:'u13l1', title:'جمع الدقائق', subtitle:'الدرس ١',
        type: LessonType.timeCalc, calcQuestions: [
          TimeCalcQuestion(startHour:2,startMinute:30,endHour:3,endMinute:0,   prompt:'من الثانية والنصف إلى الثالثة — كم مرّ؟'),
          TimeCalcQuestion(startHour:9,startMinute:0, endHour:9,endMinute:45,  prompt:'من التاسعة إلى التاسعة وثلاثة أرباع؟'),
          TimeCalcQuestion(startHour:7,startMinute:15,endHour:7,endMinute:45,  prompt:'من السابعة والربع إلى السابعة والثلاثة أرباع؟'),
          TimeCalcQuestion(startHour:11,startMinute:30,endHour:12,endMinute:0, prompt:'من الحادية عشرة والنصف إلى الثانية عشرة؟'),
        ]),
      WaqtiLesson(id:'u13l2', title:'جمع الساعات', subtitle:'الدرس ٢',
        type: LessonType.timeCalc, calcQuestions: [
          TimeCalcQuestion(startHour:8, startMinute:0, endHour:10,endMinute:0,  prompt:'من الثامنة إلى العاشرة — كم مرّ؟'),
          TimeCalcQuestion(startHour:6, startMinute:30,endHour:9, endMinute:30, prompt:'من السادسة والنصف إلى التاسعة والنصف؟'),
          TimeCalcQuestion(startHour:10,startMinute:0, endHour:14,endMinute:0,  prompt:'من العاشرة صباحًا إلى الثانية بعد الظهر؟'),
          TimeCalcQuestion(startHour:7, startMinute:15,endHour:10,endMinute:45, prompt:'من السابعة وربع إلى العاشرة وثلاثة أرباع؟'),
        ]),
      WaqtiLesson(id:'u13l3', title:'جمع الساعات والدقائق', subtitle:'الدرس ٣',
        type: LessonType.timeCalc, calcQuestions: [
          TimeCalcQuestion(startHour:8, startMinute:20,endHour:10,endMinute:50, prompt:'من ٨:٢٠ إلى ١٠:٥٠ — كم مرّ؟'),
          TimeCalcQuestion(startHour:9, startMinute:45,endHour:11,endMinute:15, prompt:'من ٩:٤٥ إلى ١١:١٥؟'),
          TimeCalcQuestion(startHour:7, startMinute:30,endHour:9, endMinute:15, prompt:'من ٧:٣٠ إلى ٩:١٥؟'),
          TimeCalcQuestion(startHour:13,startMinute:10,endHour:15,endMinute:40, prompt:'من ١:١٠ م إلى ٣:٤٠ م؟'),
          TimeCalcQuestion(startHour:6, startMinute:5, endHour:8, endMinute:35, prompt:'من ٦:٠٥ إلى ٨:٣٥؟'),
        ]),
      WaqtiLesson(id:'u13l4', title:'مع الثواني', subtitle:'الدرس ٤',
        type: LessonType.timeCalc, calcQuestions: [
          TimeCalcQuestion(startHour:3,startMinute:0,startSecond:30,  endHour:3,endMinute:1,endSecond:0,   prompt:'من ٣:٠٠:٣٠ إلى ٣:٠١:٠٠ — كم مرّ؟'),
          TimeCalcQuestion(startHour:9,startMinute:10,startSecond:0,  endHour:9,endMinute:11,endSecond:30, prompt:'من ٩:١٠:٠٠ إلى ٩:١١:٣٠؟'),
          TimeCalcQuestion(startHour:2,startMinute:45,startSecond:15, endHour:2,endMinute:46,endSecond:45, prompt:'من ٢:٤٥:١٥ إلى ٢:٤٦:٤٥؟'),
        ]),
      WaqtiLesson(id:'u13l5', title:'مسابقة الوقت 🏅', subtitle:'الدرس ٥',
        type: LessonType.timeCalc, calcQuestions: [
          TimeCalcQuestion(startHour:6, startMinute:30,endHour:8, endMinute:45, prompt:'كم من الوقت بين ٦:٣٠ و٨:٤٥؟'),
          TimeCalcQuestion(startHour:10,startMinute:15,endHour:13,endMinute:30, prompt:'كم من الوقت بين ١٠:١٥ و١:٣٠ م؟'),
          TimeCalcQuestion(startHour:8, startMinute:0, endHour:17,endMinute:0,  prompt:'يوم مدرسي من ٨ إلى ٥ م — كم ساعة؟'),
          TimeCalcQuestion(startHour:7, startMinute:0, endHour:7, endMinute:30, prompt:'وقت التحضير للمدرسة — كم دقيقة؟'),
          TimeCalcQuestion(startHour:21,startMinute:0, endHour:7, endMinute:0,  prompt:'من النوم ٩ م إلى الاستيقاظ ٧ ص — كم ساعة نمت؟'),
        ]),
    ],
  ),
];
