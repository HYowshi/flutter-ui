import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'components.dart';
import 'color_engine.dart';
import 'motion.dart';

enum UIPresentation { auto, dialog, sheet }

abstract final class UIAdaptiveDialog {
  /// Adaptive at opening time. Native route keeps its presentation on resize,
  /// preserving edits/focus; constraints continue adapting while it is open.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
    List<Widget> Function(BuildContext context)? actionsBuilder,
    UIPresentation presentation = UIPresentation.auto,
    bool dismissible = true,
    bool showClose = true,
    bool useRootNavigator = true,
    double maxWidth = 560,
    RouteSettings? routeSettings,
  }) {
    if (!maxWidth.isFinite || maxWidth < 280) {
      throw ArgumentError.value(
        maxWidth,
        'maxWidth',
        'Must be finite and >= 280',
      );
    }
    final sheet =
        presentation == UIPresentation.sheet ||
        presentation == UIPresentation.auto &&
            MediaQuery.sizeOf(context).width <
                UIAdaptiveConfig.of(context).compactBreakpoint;
    final locale = Localizations.localeOf(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final motion = reduced
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: UIMotion.standard,
            reverseDuration: UIMotion.fast,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
    Widget content(BuildContext routeContext) => PopScope<T>(
      canPop: dismissible,
      child: Localizations.override(
        context: routeContext,
        locale: locale,
        child: _DialogContent(
          title: title,
          builder: builder,
          actionsBuilder: actionsBuilder,
          showClose: showClose,
        ),
      ),
    );
    if (sheet) {
      return showModalBottomSheet<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: dismissible,
        enableDrag: dismissible,
        showDragHandle: dismissible,
        requestFocus: true,
        sheetAnimationStyle: motion,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        constraints: BoxConstraints(maxWidth: maxWidth),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        builder: (routeContext) {
          final media = MediaQuery.of(routeContext);
          final height = math.max(
            0.0,
            media.size.height -
                media.viewInsets.bottom -
                media.padding.vertical -
                48,
          );
          return Padding(
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: height),
                child: content(routeContext),
              ),
            ),
          );
        },
      );
    }
    return showDialog<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      barrierDismissible: dismissible,
      requestFocus: true,
      animationStyle: motion,
      builder: (routeContext) => Dialog(
        backgroundColor: Theme.of(routeContext)
            .colorScheme
            .surfaceContainerLowest,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        constraints: BoxConstraints(minWidth: 0, maxWidth: maxWidth),
        child: content(routeContext),
      ),
    );
  }

  /// Returns true only after the primary action. Does not run business logic.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Hủy',
    bool danger = false,
    bool dismissible = true,
    UIPresentation presentation = UIPresentation.auto,
    bool useRootNavigator = true,
  }) async =>
      await show<bool>(
        context,
        title: title,
        presentation: presentation,
        dismissible: dismissible,
        useRootNavigator: useRootNavigator,
        builder: (_) => Text(message, style: const TextStyle(height: 1.6)),
        actionsBuilder: (routeContext) => [
          UIButton(
            label: cancelLabel,
            variant: UIButtonVariant.ghost,
            onPressed: () => Navigator.of(routeContext).pop(false),
          ),
          UIButton(
            label: confirmLabel,
            tone: danger ? UITone.danger : UITone.primary,
            onPressed: () => Navigator.of(routeContext).pop(true),
          ),
        ],
      ) ??
      false;
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.title,
    required this.builder,
    required this.actionsBuilder,
    required this.showClose,
  });
  final String title;
  final WidgetBuilder builder;
  final List<Widget> Function(BuildContext)? actionsBuilder;
  final bool showClose;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    primary: false,
    padding: const EdgeInsets.all(24),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  namesRoute: true,
                  header: true,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (showClose)
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 16),
          builder(context),
          if (actionsBuilder != null) ...[
            const SizedBox(height: 24),
            UIActions(children: actionsBuilder!(context)),
          ],
        ],
      ),
    ),
  );
}
