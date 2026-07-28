import 'package:flutter/material.dart';

class DigitalClock extends StatelessWidget {
  const DigitalClock({
    super.key,
    required this.hour,
    required this.minute,
    this.second,
    this.fontSize = 44,
  });

  final int    hour, minute;
  final int?   second;
  final double fontSize;

  String get _display {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    if (second != null) {
      return '$h:$m:${second!.toString().padLeft(2, '0')}';
    }
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: fontSize * .6,
      vertical:   fontSize * .3,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1B2A),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.3),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Text(
      _display,
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize:   fontSize,
        fontWeight: FontWeight.w800,
        color:      const Color(0xFF4FC3F7),
        letterSpacing: 4,
      ),
    ),
  );
}

class AmPmBadge extends StatelessWidget {
  const AmPmBadge({super.key, required this.hour});
  final int hour;

  @override
  Widget build(BuildContext context) {
    String text;
    Color bg, fg;

    if (hour == 0) {
      text = '00:00 — منتصف الليل';
      bg = const Color(0xFFFFF9C4); fg = const Color(0xFFF57F17);
    } else if (hour == 12) {
      text = '12:00 PM — منتصف النهار';
      bg = const Color(0xFFFCE4EC); fg = const Color(0xFFAD1457);
    } else if (hour < 12) {
      text = 'AM — صباحًا';
      bg = const Color(0xFFFFF9C4); fg = const Color(0xFFF57F17);
    } else {
      text = 'PM — مساءً';
      bg = const Color(0xFFFCE4EC); fg = const Color(0xFFAD1457);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
