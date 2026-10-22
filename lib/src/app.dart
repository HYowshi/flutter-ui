import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'adaptive.dart';
import 'color_engine.dart';
import 'theme.dart';

/// Theme mode shared by UIApp and UIThemeToggle. The caller owns supplied controllers.
class UIThemeController extends ChangeNotifier {
  factory UIThemeController({ThemeMode mode = ThemeMode.system}) =>
      UIThemeController._(mode);
  UIThemeController._(this._mode);
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  set mode(ThemeMode value) {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
  }

  void toggle({Brightness systemBrightness = Brightness.light}) {
    final dark =
        mode == ThemeMode.dark ||
        mode == ThemeMode.system && systemBrightness == Brightness.dark;
    mode = dark ? ThemeMode.light : ThemeMode.dark;
  }
}

class _UIAppScope extends InheritedNotifier<UIThemeController> {
  const _UIAppScope({
    required UIThemeController controller,
    required super.child,
  }) : super(notifier: controller);
}

/// One initializer: cached light/dark themes, system mode and bounded fade transitions.
class UIApp extends StatefulWidget {
  const UIApp({
    super.key,
    required this.primary,
    required this.home,
    this.secondary,
    this.accent,
    this.profile = UIProfile.balanced,
    this.contrastLevel = 0,
    this.fontFamily,
    this.adaptive = const UIAdaptiveConfig(),
    this.controller,
    this.initialThemeMode = ThemeMode.system,
    this.reduceMotion = false,
    this.title = '',
    this.debugShowCheckedModeBanner = false,
  });
  final Color primary;
  final Color? secondary, accent;
  final Widget home;
  final UIProfile profile;
  final double contrastLevel;
  final String? fontFamily;
  final UIAdaptiveConfig adaptive;
  final UIThemeController? controller;
  final ThemeMode initialThemeMode;
  final bool reduceMotion, debugShowCheckedModeBanner;
  final String title;
  static UIThemeController controllerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_UIAppScope>();
    if (scope == null) {
      throw FlutterError(
        'Place UIThemeToggle inside UIApp, or use your own theme controller.',
      );
    }
    return scope.notifier!;
  }

  @override
  State<UIApp> createState() => _UIAppState();
}

class _UIAppState extends State<UIApp> {
  late YouthThemeSet _themes;
  late UIThemeController _controller;
  @override
  void initState() {
    super.initState();
    _makeThemes();
    _controller =
        widget.controller ?? UIThemeController(mode: widget.initialThemeMode);
  }

  void _makeThemes() => _themes = YouthUI.colors(
    primary: widget.primary,
    secondary: widget.secondary,
    accent: widget.accent,
    profile: widget.profile,
    contrastLevel: widget.contrastLevel,
    fontFamily: widget.fontFamily,
    adaptive: widget.adaptive,
  );
  @override
  void didUpdateWidget(covariant UIApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((
          oldWidget.primary,
          oldWidget.secondary,
          oldWidget.accent,
          oldWidget.profile,
          oldWidget.contrastLevel,
          oldWidget.fontFamily,
          oldWidget.adaptive,
        ) !=
        (
          widget.primary,
          widget.secondary,
          widget.accent,
          widget.profile,
          widget.contrastLevel,
          widget.fontFamily,
          widget.adaptive,
        )) {
      _makeThemes();
    }
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) _controller.dispose();
      _controller =
          widget.controller ?? UIThemeController(mode: widget.initialThemeMode);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _UIAppScope(
    controller: _controller,
    child: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => MaterialApp(
        title: widget.title,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        theme: _themes.light,
        darkTheme: _themes.dark,
        themeMode: _controller.mode,
        themeAnimationDuration: Duration.zero,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final reduced =
              media.disableAnimations ||
              widget.reduceMotion ||
              widget.contrastLevel >= .5;
          return MediaQuery(
            data: media.copyWith(disableAnimations: reduced),
            child: UIThemeTransition(theme: Theme.of(context), child: child!),
          );
        },
        home: widget.home,
      ),
    ),
  );
}

class UIThemeToggle extends StatelessWidget {
  const UIThemeToggle({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Đổi sáng / tối',
    onPressed: () =>
        UIApp.controllerOf(context)
            .toggle(systemBrightness: MediaQuery.platformBrightnessOf(context)),
    icon: Icon(
      Theme.of(context).brightness == Brightness.dark
          ? Icons.light_mode_outlined
          : Icons.dark_mode_outlined,
    ),
  );
}

/// Fades one bounded raster of the old theme over the live new theme.
/// No HCT/color interpolation or widget cloning on animation frames.
/// Unsupported snapshots fall back to an immediate update.
class UIThemeTransition extends StatefulWidget {
  const UIThemeTransition({
    super.key,
    required this.theme,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });
  final ThemeData theme;
  final Widget child;
  final Duration duration;
  @override
  State<UIThemeTransition> createState() => _UIThemeTransitionState();
}

class _UIThemeTransitionState extends State<UIThemeTransition>
    with SingleTickerProviderStateMixin {
  final _boundary = GlobalKey();
  late ThemeData _displayed;
  late final AnimationController _animation;
  late final Animation<double> _opacity;
  ui.Image? _snapshot;
  bool _busy = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _displayed = widget.theme;
    _animation = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animation, curve: Curves.easeInOutCubic),
    );
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dropSnapshot();
        _busy = false;
        if (mounted && _displayed != widget.theme) _schedule();
      }
    });
  }

  void _dropSnapshot() {
    final image = _snapshot;
    if (mounted) {
      setState(() => _snapshot = null);
    } else {
      _snapshot = null;
    }
    if (image != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => image.dispose());
    }
  }

  @override
  void didUpdateWidget(covariant UIThemeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animation.duration = widget.duration;
    if (widget.theme != _displayed) _schedule();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _generation++;
      _animation.stop();
      _busy = false;
      _displayed = widget.theme;
      _dropSnapshot();
    }
  }

  void _schedule() {
    if (MediaQuery.disableAnimationsOf(context) ||
        widget.duration == Duration.zero) {
      _generation++;
      _animation.stop();
      _busy = false;
      _displayed = widget.theme;
      _dropSnapshot();
      return;
    }
    if (_busy) return;
    _busy = true;
    final generation = ++_generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation) return;
      final boundary =
          _boundary.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      ui.Image? image;
      try {
        if (boundary != null &&
            boundary.hasSize &&
            boundary.size.width > 0 &&
            boundary.size.height > 0) {
          final pixels = boundary.size.width * boundary.size.height;
          final ratio = math.min(
            MediaQuery.devicePixelRatioOf(context),
            math.min(1.5, math.sqrt(2000000 / pixels)),
          );
          image = boundary.toImageSync(pixelRatio: ratio);
        }
      } catch (_) {
        /* Platform views / renderer snapshot support: immediate fallback. */
      }
      if (!mounted || generation != _generation) {
        image?.dispose();
        return;
      }
      setState(() {
        _displayed = widget.theme;
        _snapshot = image;
      });
      if (image == null) {
        _busy = false;
        return;
      }
      _animation.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _generation++;
    _animation.dispose();
    _snapshot?.dispose();
    _snapshot = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      Theme(
        data: _displayed,
        child: RepaintBoundary(key: _boundary, child: widget.child),
      ),
      if (_snapshot != null)
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: FadeTransition(
                opacity: _opacity,
                child: RawImage(
                  image: _snapshot,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
