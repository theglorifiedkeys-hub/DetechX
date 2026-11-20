import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Route overlays are independent of the background; supply a production map
/// as [background] and replace normalized waypoints with projected GPS points.
class DottedVectorMapCanvas extends StatelessWidget {
  const DottedVectorMapCanvas({
    super.key,
    required this.route,
    required this.trip,
    this.background,
  });
  final Animation<double> route, trip;
  final Widget? background;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Stack(
      fit: StackFit.expand,
      children: [
        background ??
            const RepaintBoundary(child: CustomPaint(painter: _CityTexture())),
        RepaintBoundary(
          child: CustomPaint(
            painter: _RoutePainter(
              route,
              trip,
              MediaQuery.disableAnimationsOf(context),
            ),
          ),
        ),
      ],
    ),
  );
}

class _CityTexture extends CustomPainter {
  const _CityTexture();
  @override
  void paint(Canvas canvas, Size size) {
    for (var y = 0.0; y < size.height; y += 6) {
      for (var x = 0.0; x < size.width; x += 6) {
        final nx = x / size.width, ny = y / size.height;
        final canal = .22 + .14 * math.sin(ny * 5 + 2) + ny * .16;
        final river = (nx - canal).abs() < .073;
        final street =
            ((x * .83 + y * .55) % 38 < 5) ||
            ((y * .83 - x * .55) % 48).abs() < 6;
        final opacity = river
            ? .07
            : (street ? .12 : .27 + .09 * math.sin(nx * 13 + ny * 10));
        canvas.drawCircle(
          Offset(x, y),
          river ? .72 : 1.06,
          Paint()..color = const Color(0xffa46753).withValues(alpha: opacity),
        );
      }
    }
    for (final (text, x, y) in [
      ('DOWNTOWN', .09, .44),
      ('FORT GREENE', .51, .27),
      ('BROOKLYN', .55, .66),
    ]) {
      final label = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Color(0xff8d6759),
            fontSize: 9,
            letterSpacing: 1.7,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      label.layout();
      label.paint(canvas, Offset(size.width * x, size.height * y));
      label.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _CityTexture oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.route, this.trip, this.reduce)
    : super(repaint: Listenable.merge([route, trip]));
  final Animation<double> route, trip;
  final bool reduce;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    Offset at(double x, double y) => Offset(size.width * x, size.height * y);
    final start = at(.16, .73), home = at(.77, .37);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * .26,
        size.height * .79,
        size.width * .31,
        size.height * .55,
        size.width * .45,
        size.height * .55,
      )
      ..cubicTo(
        size.width * .63,
        size.height * .56,
        size.width * .61,
        size.height * .33,
        home.dx,
        home.dy,
      );
    final metric = path.computeMetrics().first;
    final length =
        metric.length *
        (reduce ? 1 : Curves.easeOutQuart.transform(route.value));
    final active = metric.extractPath(0, length);
    canvas.drawPath(
      active,
      Paint()
        ..color = Colors.white.withValues(alpha: .86)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      active,
      Paint()
        ..color = AppColors.auraCoralDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final halo = reduce ? 0.0 : math.sin(trip.value * math.pi * 38);
    canvas.drawCircle(
      home,
      29 + 4 * halo,
      Paint()..color = AppColors.auraCoralWarm.withValues(alpha: .28),
    );
    canvas.drawCircle(
      home,
      20,
      Paint()..color = Colors.white.withValues(alpha: .95),
    );
    canvas.drawCircle(home, 16, Paint()..color = AppColors.auraCoralDeep);
    canvas.drawPath(
      Path()
        ..moveTo(home.dx - 7, home.dy)
        ..lineTo(home.dx, home.dy - 6)
        ..lineTo(home.dx + 7, home.dy)
        ..moveTo(home.dx - 5, home.dy - 1)
        ..lineTo(home.dx - 5, home.dy + 6)
        ..lineTo(home.dx + 5, home.dy + 6)
        ..lineTo(home.dx + 5, home.dy - 1),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(start, 13, Paint()..color = Colors.white);
    canvas.drawCircle(start, 9, Paint()..color = AppColors.inkPrimary);
    canvas.drawCircle(
      start.translate(0, -2.5),
      2.5,
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromCenter(center: start.translate(0, 4), width: 9, height: 4),
      Paint()..color = Colors.white,
    );
    final van = metric.getTangentForOffset(
      math.min(length, metric.length * (reduce ? .40 : .22 + .78 * trip.value)),
    );
    if (van == null || length < 6 || (!reduce && trip.isCompleted)) return;
    canvas.save();
    canvas.translate(van.position.dx, van.position.dy);
    canvas.rotate(van.angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, -5, 33, 17),
        const Radius.circular(5),
      ),
      Paint()
        ..color = const Color(0x58783323)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    for (final y in [-8.0, 5.0]) {
      for (final x in [-10.0, 7.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 6, 3),
            const Radius.circular(1),
          ),
          Paint()..color = AppColors.inkPrimary,
        );
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, -6, 30, 12),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, -5, 5, 10),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xff625654),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -3, 13, 6),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.badgePeachBg,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.trip != trip ||
      oldDelegate.reduce != reduce;
}
