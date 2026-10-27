import 'package:flutter/material.dart';

/// Shared timing; resolve against the user's preference at the point of use.
abstract final class UIMotion {
  static const fast = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
  static const entrance = Duration(milliseconds: 320);
  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

/// Size interpolation with a true immediate path for reduced motion. Retains
/// the child subtree when changing that preference at runtime.
class UIAnimatedSize extends StatefulWidget {
  const UIAnimatedSize({
    super.key,
    required this.child,
    this.duration = UIMotion.standard,
    this.curve = Curves.easeOutCubic,
    this.alignment = AlignmentDirectional.topStart,
  });
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry alignment;
  @override
  State<UIAnimatedSize> createState() => _UIAnimatedSizeState();
}

class _UIAnimatedSizeState extends State<UIAnimatedSize> {
  final _child = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _child, child: widget.child);
    if (UIMotion.resolve(context, widget.duration) == Duration.zero) {
      return Align(alignment: widget.alignment, heightFactor: 1, child: child);
    }
    return AnimatedSize(
      duration: widget.duration,
      curve: widget.curve,
      alignment: widget.alignment,
      child: child,
    );
  }
}

/// Change the Key to replay. Respects the platform reduced-motion setting.
class UIEntrance extends StatefulWidget {
  const UIEntrance({
    super.key,
    required this.child,
    this.duration = UIMotion.entrance,
    this.distance = 18,
    this.curve = Curves.easeOutCubic,
  }) : assert(distance >= 0 && distance < double.infinity);
  final Widget child;
  final Duration duration;
  final double distance;
  final Curve curve;
  @override
  State<UIEntrance> createState() => _UIEntranceState();
}

class _UIEntranceState extends State<UIEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled ||
        widget.duration == Duration.zero) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant UIEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.duration == Duration.zero) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final value = widget.curve.transform(_controller.value);
      return IgnorePointer(
        ignoring: value < .15,
        child: ExcludeFocus(
          excluding: value < .15,
          child: Opacity(
            opacity: value.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, widget.distance * (1 - value)),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

class UIAnimatedContent extends StatelessWidget {
  const UIAnimatedContent({
    super.key,
    required this.child,
    this.duration = UIMotion.standard,
  });
  final Widget child;
  final Duration duration;
  @override
  Widget build(BuildContext context) => UIAnimatedSize(
    duration: UIMotion.resolve(context, duration),
    curve: Curves.easeOutCubic,
    alignment: AlignmentDirectional.topStart,
    child: AnimatedSwitcher(
      duration: UIMotion.resolve(context, duration),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .98, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          for (final old in previous)
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: IgnorePointer(
                child: TickerMode(
                  enabled: false,
                  child: ExcludeFocus(child: ExcludeSemantics(child: old)),
                ),
              ),
            ),
          ?current,
        ],
      ),
      child: child,
    ),
  );
}

/// Animated disclosure that retains child state while removing hidden input,
/// focus, semantics and tickers. Parent controls visibility.
class UIReveal extends StatelessWidget {
  const UIReveal({
    super.key,
    required this.visible,
    required this.child,
    this.duration = UIMotion.standard,
  });
  final bool visible;
  final Widget child;
  final Duration duration;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: visible ? 1 : 0, end: visible ? 1 : 0),
    duration: UIMotion.resolve(context, duration),
    curve: Curves.easeOutCubic,
    child: IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: ExcludeSemantics(
          excluding: !visible,
          child: TickerMode(
            enabled: visible && TickerMode.valuesOf(context).enabled,
            child: child,
          ),
        ),
      ),
    ),
    builder: (context, value, child) => ClipRect(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        heightFactor: value,
        child: Opacity(opacity: value.clamp(0, 1), child: child),
      ),
    ),
  );
}
