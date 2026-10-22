import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'components.dart';
import 'color_engine.dart';

/// Place inside UIRadioGroup/Flutter RadioGroup. Only the 48px control is tappable.
class UIRadio<T> extends StatelessWidget {
  const UIRadio({
    super.key,
    required this.value,
    this.label,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  });
  final T value;
  final String? label;
  final bool enabled, autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final colors = YouthColors.of(context);
    final control = Semantics(
      container: true,
      label: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Radio<T>(
          value: value,
          enabled: enabled,
          focusNode: focusNode,
          autofocus: autofocus,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? s.onSurface.withValues(alpha: .38)
                : states.contains(WidgetState.selected)
                ? s.primary
                : colors.fieldBorder,
          ),
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? Colors.transparent
                : s.primary.withValues(
                    alpha: states.contains(WidgetState.focused)
                        ? .16
                        : states.contains(WidgetState.pressed)
                        ? .12
                        : states.contains(WidgetState.hovered)
                        ? .08
                        : 0,
                  ),
          ),
        ),
      ),
    );
    if (label == null) return control;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        control,
        const SizedBox(width: 4),
        Flexible(
          child: ExcludeSemantics(
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? s.onSurface : s.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Controlled single choice. Arrow/Space/Tab behavior comes from RadioGroup.
class UIRadioGroup<T> extends StatelessWidget {
  const UIRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.direction = Axis.vertical,
  });
  final List<UIOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final values = options.map((o) => o.value).toSet();
    if (values.length != options.length || values.contains(null)) {
      throw ArgumentError('Radio option values must be unique and non-null.');
    }
    return Semantics(
      container: true,
      label: label,
      child: RadioGroup<T>(
        groupValue: value,
        onChanged: (next) {
          if (onChanged != null &&
              options.any((o) => o.value == next && o.enabled)) {
            onChanged!(next);
          }
        },
        child: UIAdaptiveBuilder(
          builder: (context, ui) {
            final children = [
              for (final o in options)
                UIRadio<T>(
                  key: ValueKey(o.value),
                  value: o.value,
                  label: o.label,
                  enabled: o.enabled && onChanged != null,
                ),
            ];
            return direction == Axis.vertical ||
                    ui.compact ||
                    ui.textScale > 1.5
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  )
                : Wrap(
                    spacing: 20,
                    runSpacing: 4,
                    children: [
                      for (final child in children)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: ui.width),
                          child: child,
                        ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
