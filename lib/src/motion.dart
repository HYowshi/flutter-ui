import 'package:flutter/material.dart';

/// Change the Key to replay. Respects the platform reduced-motion setting.
class UIEntrance extends StatelessWidget {
  const UIEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.distance = 18,
  });
  final Widget child;
  final Duration duration;
  final double distance;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, distance * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

class UIAnimatedContent extends StatelessWidget {
  const UIAnimatedContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  });
  final Widget child;
  final Duration duration;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration,
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: .96, end: 1.0).animate(animation),
        child: child,
      ),
    ),
    child: child,
  );
}
