import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

enum ZaidMood { happy, thinking, celebrating, encouraging }

class ZaidMascot extends StatelessWidget {
  const ZaidMascot({
    super.key,
    this.mood   = ZaidMood.happy,
    this.size   = 100,
    this.speech,
  });

  final ZaidMood mood;
  final double   size;
  final String?  speech;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (speech != null) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          constraints: BoxConstraints(maxWidth: size * 2.8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WaqtiColors.primary.withOpacity(.2)),
            boxShadow: [
              BoxShadow(
                color: WaqtiColors.primary.withOpacity(.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            speech!,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: GoogleFonts.cairo().fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: WaqtiColors.textDark,
            ),
          ),
        ),
        // Tail
        CustomPaint(
          size: const Size(16, 8),
          painter: _TailPainter(),
        ),
        const SizedBox(height: 4),
      ],
      SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _ZaidPainter(mood: mood)),
      )
          .animate(onPlay: (c) => c.repeat())
          .moveY(
            begin: 0,
            end: mood == ZaidMood.celebrating ? -10 : -5,
            duration: 1200.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .moveY(begin: -5, end: 0, duration: 1200.ms, curve: Curves.easeInOut),
    ]);
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawPath(
      p,
      Paint()
        ..color = WaqtiColors.primary.withOpacity(.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
  @override
  bool shouldRepaint(_) => false;
}

class _ZaidPainter extends CustomPainter {
  const _ZaidPainter({required this.mood});
  final ZaidMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width * .38;

    void rr(double x, double y, double w, double h, double rad, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(rad)),
        Paint()..color = c,
      );
    }

    // Body
    rr(cx-r*.7, cy-r*.65, r*1.4, r*1.6, r*.35, WaqtiColors.primary);

    // Shine gradient
    final g = Paint()
      ..shader = LinearGradient(
        colors: [WaqtiColors.primary.withOpacity(.0), Colors.white.withOpacity(.25)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(cx-r*.7, cy-r*.65, r*1.4, r*1.6));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx-r*.7, cy-r*.65, r*1.4, r*1.6), Radius.circular(r*.35)),
      g,
    );

    // Belly panel
    rr(cx-r*.42, cy, r*.85, r*.7, r*.15, WaqtiColors.sky);

    // Mini clock on belly
    canvas.drawCircle(Offset(cx, cy+r*.3), r*.27, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy+r*.3), r*.27,
        Paint()..color = WaqtiColors.accent..style = PaintingStyle.stroke..strokeWidth = 2);

    // Head
    rr(cx-r*.65, cy-r*1.17, r*1.3, r*1.05, r*.4, WaqtiColors.primary);

    // Antenna
    canvas.drawLine(
      Offset(cx, cy-r*1.17), Offset(cx, cy-r*1.42),
      Paint()..color = WaqtiColors.accent..strokeWidth = r*.07..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy-r*1.45), r*.12, Paint()..color = WaqtiColors.accent);

    // Eyes
    final ey = cy - r * .82;
    for (final ex in [cx - r * .28, cx + r * .28]) {
      canvas.drawCircle(Offset(ex, ey), r*.17, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(ex, ey), r*.09, Paint()..color = WaqtiColors.textDark);
      canvas.drawCircle(Offset(ex-r*.04, ey-r*.05), r*.036, Paint()..color = Colors.white);
    }

    // Mouth
    final mp = Paint()
      ..color = Colors.white
      ..strokeWidth = r * .065
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final mouthPath = Path();
    if (mood == ZaidMood.celebrating) {
      mouthPath.moveTo(cx-r*.28, cy-r*.54);
      mouthPath.quadraticBezierTo(cx, cy-r*.34, cx+r*.28, cy-r*.54);
    } else if (mood == ZaidMood.thinking) {
      mouthPath.moveTo(cx-r*.2, cy-r*.5);
      mouthPath.lineTo(cx+r*.2, cy-r*.5);
    } else {
      mouthPath.moveTo(cx-r*.22, cy-r*.52);
      mouthPath.quadraticBezierTo(cx, cy-r*.4, cx+r*.22, cy-r*.52);
    }
    canvas.drawPath(mouthPath, mp);

    // Blush
    final blush = Paint()..color = WaqtiColors.coral.withOpacity(.3);
    for (final bx in [cx - r * .48, cx + r * .48]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(bx, cy-r*.62), width: r*.24, height: r*.14),
        blush,
      );
    }

    // Arms
    final arm = Paint()
      ..color = WaqtiColors.primary
      ..strokeWidth = r * .22
      ..strokeCap = StrokeCap.round;
    if (mood == ZaidMood.celebrating) {
      canvas.drawLine(Offset(cx-r*.7, cy-r*.1), Offset(cx-r*1.15, cy-r*.62), arm);
      canvas.drawLine(Offset(cx+r*.7, cy-r*.1), Offset(cx+r*1.15, cy-r*.62), arm);
    } else {
      canvas.drawLine(Offset(cx-r*.7, cy-r*.05), Offset(cx-r*1.1, cy+r*.35), arm);
      canvas.drawLine(Offset(cx+r*.7, cy-r*.05), Offset(cx+r*1.1, cy+r*.35), arm);
    }
    // Legs
    canvas.drawLine(Offset(cx-r*.3, cy+r*.95), Offset(cx-r*.33, cy+r*1.35), arm);
    canvas.drawLine(Offset(cx+r*.3, cy+r*.95), Offset(cx+r*.33, cy+r*1.35), arm);
  }

  @override
  bool shouldRepaint(_ZaidPainter old) => old.mood != mood;
}
