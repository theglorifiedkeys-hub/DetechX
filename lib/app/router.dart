import 'package:flutter/material.dart';
import '../core/surfaces.dart';

Future<T?> openFlow<T>(BuildContext context, Widget screen) {
  final reducedMotion = MediaQuery.disableAnimationsOf(context);
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: reducedMotion ? 140 : 420),
      reverseTransitionDuration: Duration(
        milliseconds: reducedMotion ? 140 : 270,
      ),
      pageBuilder: (_, _, _) => screen,
      transitionsBuilder: (_, animation, _, child) {
        final fade = animation.drive(CurveTween(curve: motionCurve));
        return FadeTransition(
          opacity: fade,
          child: reducedMotion
              ? child
              : SlideTransition(
                  position: fade.drive(
                    Tween(begin: const Offset(0, .045), end: Offset.zero),
                  ),
                  child: child,
                ),
        );
      },
    ),
  );
}
