import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'color_engine.dart';
import 'adaptive.dart';
import 'motion.dart';

part 'select.dart';
part 'form.dart';
part 'feedback.dart';

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

/// Text input with blur-first validation and optional server field binding.
enum UIInputVariant { outlined, filled }

class UITextField extends StatelessWidget {
  const UITextField({
    super.key,
    required this.label,
    this.name,
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
    this.focusNode,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.readOnly = false,
    this.clearable = false,
    this.initialValue,
    this.minLines,
    this.autofocus = false,
    this.errorText,
    this.prefixText,
    this.suffixText,
    this.variant = UIInputVariant.outlined,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
  }) : assert(controller == null || initialValue == null),
       assert(minLines == null || minLines > 0 && minLines <= maxLines);
  factory UITextField.search({
    Key? key,
    String label = 'Tìm kiếm',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
  }) => UITextField(
    key: key,
    label: label,
    controller: controller,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    prefixIcon: Icons.search_rounded,
    clearable: true,
    textInputAction: TextInputAction.search,
    variant: UIInputVariant.filled,
  );
  factory UITextField.multiline({
    Key? key,
    required String label,
    TextEditingController? controller,
    String? helper,
    int? maxLength,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) => UITextField(
    key: key,
    label: label,
    controller: controller,
    helper: helper,
    maxLength: maxLength,
    validator: validator,
    onChanged: onChanged,
    minLines: 3,
    maxLines: 6,
    keyboardType: TextInputType.multiline,
    textInputAction: TextInputAction.newline,
    textCapitalization: TextCapitalization.sentences,
  );
  final String label;
  final String? name, hint, helper;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged, onFieldSubmitted;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool enabled, readOnly, clearable;
  final int maxLines;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final String? initialValue, errorText, prefixText, suffixText;
  final int? minLines;
  final bool autofocus;
  final UIInputVariant variant;
  final TextCapitalization textCapitalization;
  @override
  Widget build(BuildContext context) => _UISmartField(input: this);
}

class UIPasswordField extends StatelessWidget {
  const UIPasswordField({
    super.key,
    this.label = 'Mật khẩu',
    this.name,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.autofillHints,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.helper,
    this.errorText,
    this.variant = UIInputVariant.outlined,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
  });
  final String label;
  final String? name, helper, errorText;
  final UIInputVariant variant;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged, onFieldSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final AutovalidateMode autovalidateMode;
  @override
  Widget build(BuildContext context) => _UISmartField(
    password: true,
    input: UITextField(
      label: label,
      name: name,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      autofillHints: autofillHints,
      focusNode: focusNode,
      helper: helper,
      errorText: errorText,
      variant: variant,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      prefixIcon: Icons.lock_outline_rounded,
      autovalidateMode: autovalidateMode,
    ),
  );
}

class _UISmartField extends StatefulWidget {
  const _UISmartField({required this.input, this.password = false});
  final UITextField input;
  final bool password;
  @override
  State<_UISmartField> createState() => _UISmartFieldState();
}

class _UISmartFieldState extends State<_UISmartField> {
  final field = GlobalKey<FormFieldState<String>>();
  late TextEditingController text;
  bool hidden = true;
  @override
  void initState() {
    super.initState();
    text =
        widget.input.controller ??
        TextEditingController(text: widget.input.initialValue);
  }

  @override
  void didUpdateWidget(covariant _UISmartField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.input.controller != widget.input.controller) {
      final value = text.value;
      if (oldWidget.input.controller == null) text.dispose();
      text = widget.input.controller ?? TextEditingController.fromValue(value);
    }
  }

  @override
  void dispose() {
    if (widget.input.controller == null) text.dispose();
    super.dispose();
  }

  void changed(String value) {
    final input = widget.input;
    final form = _UIFormScope.maybeOf(context);
    final hadError = field.currentState?.hasError ?? false;
    if (input.name != null) form?._clearFieldError(input.name!);
    input.onChanged?.call(value);
    // The first error is deferred to blur/submit. Once invalid, correct it live.
    if (hadError && input.autovalidateMode != AutovalidateMode.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) field.currentState?.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;
    final form = _UIFormScope.maybeOf(context);
    final enabled = input.enabled && !(form?.isSubmitting ?? false);
    return UIAdaptiveBuilder(
      builder: (context, ui) => UIAnimatedSize(
        duration: UIMotion.resolve(context, UIMotion.fast),
        alignment: AlignmentDirectional.topStart,
        curve: Curves.easeOutCubic,
        child: TextFormField(
          key: field,
          controller: text,
          focusNode: input.focusNode,
          validator: input.validator,
          forceErrorText: input.errorText ?? form?.fieldErrors[input.name],
          autovalidateMode: input.autovalidateMode,
          onChanged: changed,
          keyboardType: input.keyboardType,
          enabled: enabled,
          readOnly: input.readOnly,
          maxLines: input.maxLines,
          minLines: input.minLines,
          autofocus: input.autofocus,
          textCapitalization: input.textCapitalization,
          maxLength: input.maxLength,
          inputFormatters: input.inputFormatters,
          autofillHints: input.autofillHints,
          textInputAction: input.textInputAction,
          onFieldSubmitted:
              input.onFieldSubmitted ??
              (input.textInputAction == TextInputAction.done && form != null
                  ? (_) => unawaited(form.submit())
                  : null),
          obscureText: widget.password && hidden,
          enableSuggestions: !widget.password,
          autocorrect: !widget.password,
          decoration: InputDecoration(
            contentPadding: ui.controlPadding,
            labelText: input.label,
            hintText: input.hint,
            helperText: input.helper,
            prefixText: input.prefixText,
            suffixText: input.suffixText,
            fillColor: input.variant == UIInputVariant.filled
                ? Theme.of(context).colorScheme.surfaceContainerLow
                : Theme.of(context).colorScheme.surfaceContainerLowest,
            errorMaxLines: 4,
            helperMaxLines: 4,
            prefixIcon: input.prefixIcon == null
                ? null
                : Icon(input.prefixIcon, size: 20),
            suffixIcon: widget.password
                ? IconButton(
                    tooltip:
                        '${hidden ? 'Hiện' : 'Ẩn'} ${input.label.toLowerCase()}',
                    isSelected: !hidden,
                    onPressed: enabled
                        ? () => setState(() => hidden = !hidden)
                        : null,
                    icon: Icon(
                      hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  )
                : input.clearable
                ? ValueListenableBuilder<TextEditingValue>(
                    valueListenable: text,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Xoá ${input.label.toLowerCase()}',
                            onPressed: enabled && !input.readOnly
                                ? () {
                                    text.clear();
                                    field.currentState?.didChange('');
                                    changed('');
                                  }
                                : null,
                            icon: const Icon(Icons.close_rounded, size: 20),
                          ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
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
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.liveRegion = true,
  }) : assert((actionLabel == null) == (onAction == null));
  final String message;
  final String? title;
  final UITone tone;
  final String? actionLabel;
  final VoidCallback? onAction, onDismiss;
  final bool liveRegion;
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
      liveRegion: liveRegion,
      child: UIAnimatedSize(
        duration: UIMotion.resolve(context, UIMotion.standard),
        alignment: AlignmentDirectional.topStart,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: UIMotion.resolve(context, UIMotion.fast),
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
                    if (onAction != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: c),
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  tooltip: 'Đóng thông báo',
                  color: c,
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
            ],
          ),
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
