import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Shared defaults. Components work without installing an extra wrapper.
@immutable
class UIAdaptiveConfig extends ThemeExtension<UIAdaptiveConfig> {
  const UIAdaptiveConfig({
    this.compactBreakpoint = 600,
    this.expandedBreakpoint = 1024,
    this.maxContentWidth = 1120,
    this.minColumnWidth = 280,
  }) : assert(compactBreakpoint > 0),
       assert(expandedBreakpoint > compactBreakpoint),
       assert(maxContentWidth > 0),
       assert(minColumnWidth > 0);

  final double compactBreakpoint, expandedBreakpoint;
  final double maxContentWidth, minColumnWidth;

  static UIAdaptiveConfig of(BuildContext context) =>
      Theme.of(context).extension<UIAdaptiveConfig>() ??
      const UIAdaptiveConfig();

  @override
  UIAdaptiveConfig copyWith({
    double? compactBreakpoint,
    double? expandedBreakpoint,
    double? maxContentWidth,
    double? minColumnWidth,
  }) => UIAdaptiveConfig(
    compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
    expandedBreakpoint: expandedBreakpoint ?? this.expandedBreakpoint,
    maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    minColumnWidth: minColumnWidth ?? this.minColumnWidth,
  );

  @override
  UIAdaptiveConfig lerp(covariant UIAdaptiveConfig? other, double t) =>
      other == null
      ? this
      : t < .5
      ? this
      : other;
}

@immutable
class UIAdaptiveData {
  const UIAdaptiveData({
    required this.width,
    required this.boundedWidth,
    required this.pointer,
    required this.textScale,
    required this.config,
  });
  final double width, textScale;
  final bool boundedWidth, pointer;
  final UIAdaptiveConfig config;
  bool get compact => width < config.compactBreakpoint;
  bool get expanded => width >= config.expandedBreakpoint;
  double get gap => compact ? 12 : 20;
  double get pagePadding => compact
      ? 16
      : expanded
      ? 32
      : 24;
  EdgeInsets get controlPadding => EdgeInsets.symmetric(
    horizontal: compact ? 16 : 20,
    vertical: pointer ? 12 : 16,
  );
}

/// Rebuilds for local constraints, text scaling and mouse connection changes.
class UIAdaptiveBuilder extends StatelessWidget {
  const UIAdaptiveBuilder({super.key, required this.builder});
  final Widget Function(BuildContext, UIAdaptiveData) builder;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: RendererBinding.instance.mouseTracker,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) => builder(
        context,
        UIAdaptiveData(
          width: constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width,
          boundedWidth: constraints.hasBoundedWidth,
          pointer: RendererBinding.instance.mouseTracker.mouseIsConnected,
          textScale: MediaQuery.textScalerOf(context).scale(14) / 14,
          config: UIAdaptiveConfig.of(context),
        ),
      ),
    ),
  );
}

/// Scrollable safe page, centered and width-limited on desktop.
class UIPage extends StatelessWidget {
  const UIPage({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: UIAdaptiveBuilder(
      builder: (context, ui) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.all(ui.pagePadding),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ui.config.maxContentWidth),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) SizedBox(height: ui.gap),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Content-height tiles: no fixed aspect ratio or nested scrolling.
/// Fewer columns when space shrinks or the user's text size increases.
class UIGrid extends StatelessWidget {
  const UIGrid({
    super.key,
    required this.children,
    this.maxColumns = 4,
    this.minItemWidth,
  }) : assert(maxColumns > 0),
       assert(minItemWidth == null || minItemWidth > 0);
  final List<Widget> children;
  final int maxColumns;
  final double? minItemWidth;

  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      final minimum =
          (minItemWidth ?? ui.config.minColumnWidth) * ui.textScale.clamp(1, 2);
      final columns = math.max(
        1,
        math.min(
          maxColumns,
          ((ui.width + ui.gap) / (minimum + ui.gap)).floor(),
        ),
      );
      final width = math.max(
        0.0,
        (ui.width - ui.gap * (columns - 1)) / columns,
      );
      return Wrap(
        spacing: ui.gap,
        runSpacing: ui.gap,
        children: [
          for (final child in children)
            SizedBox(
              // Preserve keyed children when fields/cards change order. Wrap
              // GlobalKeys in a local key instead of assigning one twice.
              key: child.key == null ? null : ValueKey(child.key),
              width: width,
              child: child,
            ),
        ],
      );
    },
  );
}

/// Stacked full-width actions in narrow regions; wrapping actions on desktop.
class UIActions extends StatelessWidget {
  const UIActions({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) => ui.compact && ui.boundedWidth
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: ui.gap),
                children[i],
              ],
            ],
          )
        : Wrap(spacing: ui.gap, runSpacing: ui.gap, children: children),
  );
}
