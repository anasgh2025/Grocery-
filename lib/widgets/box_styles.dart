import 'package:flutter/material.dart';
// Painter that draws a dashed rounded rectangle border. Used for create/add cards.
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.6,
    this.radius = 10.0,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dashWidth).clamp(0.0, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

/// Shared box decoration helpers used across the app so boxes have a
/// consistent background, corner radius and shadow, matching the landing
/// page style.
BoxDecoration appBoxDecoration(BuildContext context,
    {Color? color,
    double radius = 16.0,
    Border? border,
    List<BoxShadow>? boxShadow}) {
  final theme = Theme.of(context);
  return BoxDecoration(
    color: color ?? theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: border,
    boxShadow: boxShadow ?? const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.06),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  );
}
