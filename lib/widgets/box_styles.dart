import 'package:flutter/material.dart';

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
