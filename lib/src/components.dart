import 'package:flutter/material.dart';

import 'theme.dart';
import 'color_engine.dart';
import 'adaptive.dart';

class UIButton extends StatelessWidget {
  const UIButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = UIButtonVariant.solid,
    this.tone = UITone.primary,
    this.icon,
    this.loading = false,
    this.fullWidth,
    this.selected,
  });
  final String label;
  final VoidCallback? onPressed;
  final UIButtonVariant variant;
  final UITone tone;
  final IconData? icon;
  final bool loading;
  final bool? fullWidth;
  final bool? selected;
  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      final tokens = YouthColors.of(context);
      UIControlColors resolve(Set<WidgetState> states) => tokens.button(
        tone,
        variant,
        {...states, if (selected == true) WidgetState.selected},
        surface: UISurfaceScope.of(context),
      );
      final style = ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.padded,
        padding: WidgetStatePropertyAll(ui.controlPadding),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => resolve(states).foreground,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => resolve(states).background,
        ),
        // States already resolve to an opaque checked color. Disable extra alpha.
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? BorderSide(color: resolve(states).border, width: 2)
              : variant == UIButtonVariant.outline
              ? BorderSide(color: resolve(states).border)
              : BorderSide.none,
        ),
      );
      final content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading) ...[
            SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tokens.button(tone, variant, {
                  WidgetState.disabled,
                }).foreground,
              ),
            ),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 9),
          ],
          Flexible(
            child: Text(label, softWrap: true, textAlign: TextAlign.center),
          ),
        ],
      );
      final child = switch (variant) {
        UIButtonVariant.outline => OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: style,
          child: content,
        ),
        UIButtonVariant.ghost => TextButton(
          onPressed: loading ? null : onPressed,
          style: style,
          child: content,
        ),
        _ => FilledButton(
          onPressed: loading ? null : onPressed,
          style: style,
          child: content,
        ),
      };
      final result = Semantics(
        liveRegion: loading,
        toggled: selected,
        child: (fullWidth ?? ui.compact) && ui.boundedWidth
            ? SizedBox(width: double.infinity, child: child)
            : child,
      );
      return selected == null ? result : MergeSemantics(child: result);
    },
  );
}

class UITextField extends StatelessWidget {
  const UITextField({
    super.key,
    required this.label,
    this.hint,
    this.helper,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
    this.textInputAction,
  });
  final String label;
  final String? hint, helper;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool enabled;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) => TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        contentPadding: ui.controlPadding,
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
      ),
    ),
  );
}

class UIPasswordField extends StatefulWidget {
  const UIPasswordField({
    super.key,
    this.label = 'Mật khẩu',
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.autofillHints,
  });
  final String label;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final Iterable<String>? autofillHints;
  @override
  State<UIPasswordField> createState() => _UIPasswordFieldState();
}

class _UIPasswordFieldState extends State<UIPasswordField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) => TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      obscureText: hidden,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        contentPadding: ui.controlPadding,
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          tooltip: '${hidden ? 'Hiện' : 'Ẩn'} ${widget.label.toLowerCase()}',
          isSelected: !hidden,
          onPressed: widget.enabled
              ? () => setState(() => hidden = !hidden)
              : null,
          icon: Icon(
            hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
          ),
        ),
      ),
    ),
  );
}

class UICard extends StatefulWidget {
  const UICard({super.key, required this.child, this.padding, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  @override
  State<UICard> createState() => _UICardState();
}

class _UICardState extends State<UICard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) => MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedSlide(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        offset: hover && widget.onTap != null
            ? const Offset(0, -.025)
            : Offset.zero,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: widget.onTap == null
              ? Padding(
                  padding:
                      widget.padding ?? EdgeInsets.all(ui.compact ? 16 : 24),
                  child: UISurfaceScope(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: widget.child,
                  ),
                )
              : InkWell(
                  onTap: widget.onTap,
                  child: Padding(
                    padding:
                        widget.padding ?? EdgeInsets.all(ui.compact ? 16 : 24),
                    child: UISurfaceScope(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerLowest,
                      child: widget.child,
                    ),
                  ),
                ),
        ),
      ),
    ),
  );
}

class UIBadge extends StatelessWidget {
  const UIBadge({
    super.key,
    required this.label,
    this.tone = UITone.primary,
    this.icon,
  });
  final String label;
  final UITone tone;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final colors = tone.colors(context);
    final bg = colors.soft;
    final fg = colors.onSoft;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                softWrap: true,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UIAlert extends StatelessWidget {
  const UIAlert({
    super.key,
    required this.message,
    this.tone = UITone.primary,
    this.title,
  });
  final String message;
  final String? title;
  final UITone tone;
  @override
  Widget build(BuildContext context) {
    final colors = tone.colors(context);
    final c = colors.onSoft;
    final icon = switch (tone) {
      UITone.success => Icons.check_circle_outline,
      UITone.warning => Icons.warning_amber_rounded,
      UITone.danger => Icons.error_outline,
      _ => Icons.info_outline,
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.soft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: TextStyle(color: c, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      color: colors.onSoft,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact control: only the 48px checkbox target is interactive.
/// The label and unused row space never paint hover or trigger a toggle.
class UICheckbox extends StatelessWidget {
  const UICheckbox({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });
  final String? label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
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
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          focusNode: focusNode,
          autofocus: autofocus,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          splashRadius: 21,
          side: WidgetStateBorderSide.resolveWith(
            (states) => BorderSide(
              width: states.contains(WidgetState.focused) ? 2.5 : 1.7,
              color: states.contains(WidgetState.disabled)
                  ? s.onSurface.withValues(alpha: .25)
                  : states.contains(WidgetState.selected)
                  ? s.primary
                  : colors.fieldBorder,
            ),
          ),
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? s.onSurface.withValues(
                    alpha: states.contains(WidgetState.selected) ? .38 : .08,
                  )
                : states.contains(WidgetState.selected)
                ? s.primary
                : s.surfaceContainerLowest,
          ),
          checkColor: onChanged == null ? s.surface : s.onPrimary,
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
                color: onChanged == null ? s.onSurfaceVariant : s.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Label is separate from the switch hit target. Works with or without a label.
class UISwitch extends StatelessWidget {
  const UISwitch({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });
  final String? label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final tokens = YouthColors.of(context);
    final control = Semantics(
      container: true,
      label: label,
      child: SizedBox(
        width: 60,
        height: 48,
        child: Switch(
          value: value,
          onChanged: onChanged,
          focusNode: focusNode,
          autofocus: autofocus,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? s.onSurface.withValues(alpha: .38)
                : states.contains(WidgetState.selected)
                ? s.onPrimary
                : s.onSurfaceVariant,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? s.onSurface.withValues(alpha: .08)
                : states.contains(WidgetState.selected)
                ? s.primary
                : s.surfaceContainerHigh,
          ),
          trackOutlineColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? s.onSurface.withValues(alpha: .25)
                : states.contains(WidgetState.selected)
                ? s.primary
                : tokens.fieldBorder,
          ),
          trackOutlineWidth: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused) ? 2 : 1.5,
          ),
          thumbIcon: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: states.contains(WidgetState.disabled)
                        ? s.onSurfaceVariant
                        : s.primary,
                  )
                : null,
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
        const SizedBox(width: 12),
        Flexible(
          child: ExcludeSemantics(
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                color: onChanged == null ? s.onSurfaceVariant : s.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A reusable selected/unselected button with inherited theme and semantics.
class UIToggleButton extends StatelessWidget {
  const UIToggleButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    this.selectedIcon,
    this.tone = UITone.primary,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon, selectedIcon;
  final UITone tone;
  @override
  Widget build(BuildContext context) => UIButton(
    label: label,
    selected: value,
    tone: tone,
    variant: value ? UIButtonVariant.soft : UIButtonVariant.outline,
    icon: value ? selectedIcon ?? Icons.check_rounded : icon,
    onPressed: onChanged == null ? null : () => onChanged!(!value),
  );
}

@immutable
class UIOption<T> {
  const UIOption({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });
  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// Mutually exclusive choices. Effects are clipped to each actual segment.
class UISegmentedControl<T> extends StatelessWidget {
  const UISegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<UIOption<T>> options;
  final T value;
  final ValueChanged<T>? onChanged;
  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      if (options.isEmpty ||
          options.where((o) => o.value == value).length != 1 ||
          options.map((o) => o.value).toSet().length != options.length) {
        throw ArgumentError(
          'Use unique, nonempty options containing the selected value.',
        );
      }
      final tokens = YouthColors.of(context);
      UIControlColors resolve(Set<WidgetState> states) => tokens.button(
        UITone.primary,
        UIButtonVariant.outline,
        states,
        surface: UISurfaceScope.of(context),
      );
      final textStyle = Theme.of(context).textTheme.labelLarge!;
      var largestLabel = 0.0;
      for (final option in options) {
        final painter = TextPainter(
          text: TextSpan(text: option.label, style: textStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        if (painter.width > largestLabel) largestLabel = painter.width;
        painter.dispose();
      }
      // Native segments use equal widths. Reserve an icon/check slot in each.
      final requiredWidth = (largestLabel + 64) * options.length;
      if (ui.boundedWidth && requiredWidth > ui.width) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              UIButton(
                key: ValueKey(options[i].value),
                label: options[i].label,
                selected: options[i].value == value,
                fullWidth: true,
                icon: options[i].value == value
                    ? Icons.check_rounded
                    : options[i].icon,
                variant: options[i].value == value
                    ? UIButtonVariant.soft
                    : UIButtonVariant.outline,
                onPressed: onChanged == null || !options[i].enabled
                    ? null
                    : () => onChanged!(options[i].value),
              ),
            ],
          ],
        );
      }
      return SegmentedButton<T>(
        segments: [
          for (final option in options)
            ButtonSegment<T>(
              value: option.value,
              label: Text(option.label),
              enabled: option.enabled,
              icon: option.icon == null ? null : Icon(option.icon),
            ),
        ],
        selected: {value},
        onSelectionChanged: onChanged == null
            ? null
            : (v) => onChanged!(v.single),
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.padded,
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => resolve(states).foreground,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => resolve(states).background,
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: resolve(states).border,
              width: states.contains(WidgetState.focused) ? 2 : 1,
            ),
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      );
    },
  );
}

class UISelect<T> extends StatelessWidget {
  const UISelect({
    super.key,
    required this.label,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
  });
  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) => DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: ui.controlPadding,
      ),
      itemHeight: null,
      isDense: false,
      menuMaxHeight: MediaQuery.sizeOf(context).height * .5,
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    ),
  );
}
