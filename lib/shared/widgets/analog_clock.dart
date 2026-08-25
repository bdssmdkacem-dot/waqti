import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, required this.hour, required this.minute, this.size = 200, this.color = WaqtiColors.primary});
  final int hour, minute;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: CustomPaint(painter: _ClockPainter(hour: hour, minute: minute, color: color)),
  );
}

class InteractiveClock extends StatefulWidget {
  const InteractiveClock({super.key, required this.initialHour, required this.initialMinute, required this.onChanged, this.size = 240, this.color = WaqtiColors.primary});
  final int initialHour, initialMinute;
  final void Function(int h, int m) onChanged;
  final double size;
  final Color color;

  @override
  State<InteractiveClock> createState() => _InteractiveClockState();
}

class _InteractiveClockState extends State<InteractiveClock> {
  late int _h, _m;
  String? _dragging;

  @override
  void initState() {
    super.initState();
    _h = widget.initialHour;
    _m = widget.initialMinute;
  }

  double _angleDeg(Offset local) {
    final cx = widget.size / 2, cy = widget.size / 2;
    return (math.atan2(local.dy - cy, local.dx - cx) * 180 / math.pi + 90 + 360) % 360;
  }

  double _diff(double a, double b) {
    final d = (a - b).abs() % 360;
    return d > 180 ? 360 - d : d;
  }

  void _onStart(Offset local) {
    final deg = _angleDeg(local);
    final hourDeg = ((_h % 12) * 30 + _m * .5 + 360) % 360;
    final minDeg = (_m * 6.0 + 360) % 360;
    _dragging = _diff(deg, hourDeg) < _diff(deg, minDeg) ? 'hour' : 'minute';
    _onMove(local);
  }

  void _onMove(Offset local) {
    if (_dragging == null) return;
    final deg = _angleDeg(local);
    setState(() {
      if (_dragging == 'minute') {
        _m = (deg / 6).round() % 60;
      } else {
        int h = (deg / 30).round() % 12;
        _h = h == 0 ? 12 : h;
      }
    });
    widget.onChanged(_h, _m);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onPanStart: (d) => _onStart(d.localPosition),
    onPanUpdate: (d) => _onMove(d.localPosition),
    onPanEnd: (_) => _dragging = null,
    child: AnalogClock(hour: _h, minute: _m, size: widget.size, color: widget.color),
  );
}

class _ClockPainter extends CustomPainter {
  const _ClockPainter({required this.hour, required this.minute, required this.color});
  final int hour, minute;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, r = size.width / 2;

    canvas.drawCircle(
      Offset(cx + 2, cx + 4), r - 4,
      Paint()..color = Colors.black.withValues(alpha: .12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(Offset(cx, cx), r - 4, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(cx, cx), r - 4,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = r * .065,
    );
    canvas.drawCircle(
      Offset(cx, cx), r * .91,
      Paint()..color = color.withValues(alpha: .18)..style = PaintingStyle.stroke..strokeWidth = r * .022,
    );

    for (int i = 0; i < 60; i++) {
      final a = (i * 6 - 90) * math.pi / 180;
      final maj = i % 5 == 0;
      final s = r * (maj ? .815 : .875);
      final tl = r * (maj ? .13 : .065);
      canvas.drawLine(
        Offset(cx + s * math.cos(a), cx + s * math.sin(a)),
        Offset(cx + (s + tl) * math.cos(a), cx + (s + tl) * math.sin(a)),
        Paint()..color = maj ? color : color.withValues(alpha: .35)..strokeWidth = maj ? r * .038 : r * .018..strokeCap = StrokeCap.round,
      );
    }

    for (int i = 1; i <= 12; i++) {
      final a = (i * 30 - 90) * math.pi / 180;
      final nr = r * .64;
      final tp = TextPainter(
        text: TextSpan(text: '$i', style: TextStyle(color: const Color(0xFF1A237E), fontSize: r * .165, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx + nr * math.cos(a), cx + nr * math.sin(a)) - Offset(tp.width / 2, tp.height / 2));
    }

    void hand(double angle, double len, double w, Color c) {
      canvas.drawLine(
        Offset(cx - len * .2 * math.cos(angle), cx - len * .2 * math.sin(angle)),
        Offset(cx + len * math.cos(angle), cx + len * math.sin(angle)),
        Paint()..color = c..strokeWidth = w..strokeCap = StrokeCap.round,
      );
    }

    hand(((hour % 12) * 30 + minute * .5 - 90) * math.pi / 180, r * .47, r * .046, color);
    hand((minute * 6 - 90) * math.pi / 180, r * .67, r * .030, const Color(0xFFE53935));
    canvas.drawCircle(Offset(cx, cx), r * .06, Paint()..color = WaqtiColors.accent);
    canvas.drawCircle(Offset(cx, cx), r * .027, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.hour != hour || old.minute != minute || old.color != color;
}
