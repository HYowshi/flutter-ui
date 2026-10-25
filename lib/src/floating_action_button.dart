import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'color_engine.dart';

enum UIFabSize { small, regular, large }

/// Primary floating action. Place in Scaffold.floatingActionButton.
/// Labels collapse in compact regions by default; tooltip remains available.
/// Hero is opt-in so multiple instances do not share an implicit tag.
class UIFloatingActionButton extends StatelessWidget {
  const UIFloatingActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.label,
    this.extended,
    this.size = UIFabSize.regular,
    this.tone = UITone.primary,
    this.loading = false,
    this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.shape,
    this.elevation,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
         elevation == null || elevation >= 0 && elevation < double.infinity,
       );

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final String? label;

  /// Null: show label at >= compactBreakpoint; true: request extended on mobile.
  final bool? extended;
  final UIFabSize size;
  final UITone tone;
  final bool loading;
  final Object? heroTag;

  /// Override both colors together to preserve readable contrast.
  final Color? backgroundColor, foregroundColor;
  final ShapeBorder? shape;
  final double? elevation;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      final colors = YouthColors.of(context).button(
        tone,
        UIButtonVariant.solid,
        {if (loading || onPressed == null) WidgetState.disabled},
      );
      final foreground = foregroundColor ?? colors.foreground;
      final reduced = MediaQuery.disableAnimationsOf(context);
      final content = loading
          ? reduced
                ? const Icon(Icons.hourglass_top_rounded)
                : SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
          : Icon(icon);
      // Keep the native extended button within local width, including large text.
      final labelWidth = math.max(0.0, math.min(240.0, ui.width - 96));
      final showLabel =
          label != null &&
          label!.trim().isNotEmpty &&
          (extended ?? !ui.compact) &&
          labelWidth >= 64;
      final callback = loading ? null : onPressed;
      Widget button;
      if (showLabel) {
        button = FloatingActionButton.extended(
          onPressed: callback,
          tooltip: tooltip,
          heroTag: heroTag,
          icon: content,
          label: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: labelWidth),
            child: Text(label!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          backgroundColor: backgroundColor ?? colors.background,
          foregroundColor: foreground,
          shape: shape,
          elevation: elevation,
          focusNode: focusNode,
          autofocus: autofocus,
          materialTapTargetSize: MaterialTapTargetSize.padded,
        );
      } else {
        // Never force a 96px large control into a narrower region.
        final resolvedSize = size == UIFabSize.large && ui.width < 96
            ? UIFabSize.regular
            : size;
        final constructor = switch (resolvedSize) {
          UIFabSize.small => FloatingActionButton.small,
          UIFabSize.large => FloatingActionButton.large,
          UIFabSize.regular => FloatingActionButton.new,
        };
        button = constructor(
          onPressed: callback,
          tooltip: tooltip,
          heroTag: heroTag,
          child: content,
          backgroundColor: backgroundColor ?? colors.background,
          foregroundColor: foreground,
          shape: shape,
          elevation: elevation,
          focusNode: focusNode,
          autofocus: autofocus,
          materialTapTargetSize: MaterialTapTargetSize.padded,
        );
      }
      return Semantics(
        liveRegion: loading,
        value: loading ? 'Đang xử lý' : null,
        child: button,
      );
    },
  );
}
