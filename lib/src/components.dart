import 'package:flutter/material.dart';

import 'theme.dart';

enum UIButtonVariant { solid, soft, outline, ghost }

class UIButton extends StatelessWidget {
  const UIButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = UIButtonVariant.solid,
    this.tone = UITone.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final UIButtonVariant variant;
  final UITone tone;
  final IconData? icon;
  final bool loading, fullWidth;
  @override
  Widget build(BuildContext context) {
    final c = tone.color(context), s = Theme.of(context).colorScheme;
    final foreground = variant == UIButtonVariant.solid
        ? uiForeground(c)
        : uiReadable(c, s.surface);
    final style = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? s.onSurface.withValues(alpha: .38)
            : foreground,
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return s.onSurface.withValues(alpha: .08);
        }
        return switch (variant) {
          UIButtonVariant.solid => c,
          UIButtonVariant.soft => c.withValues(alpha: .10),
          _ => Colors.transparent,
        };
      }),
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: .10)),
      side: WidgetStatePropertyAll(
        variant == UIButtonVariant.outline
            ? BorderSide(
                color: onPressed == null || loading ? s.outlineVariant : c,
              )
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
              color: s.onSurface.withValues(alpha: .5),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 9),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
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
    return Semantics(
      button: true,
      liveRegion: loading,
      child: fullWidth ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
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
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    onChanged: onChanged,
    keyboardType: keyboardType,
    enabled: enabled,
    maxLines: maxLines,
    autofillHints: autofillHints,
    textInputAction: textInputAction,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
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
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    validator: widget.validator,
    onChanged: widget.onChanged,
    enabled: widget.enabled,
    autofillHints: widget.autofillHints,
    obscureText: hidden,
    enableSuggestions: false,
    autocorrect: false,
    decoration: InputDecoration(
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
  );
}

class UICard extends StatefulWidget {
  const UICard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  @override
  State<UICard> createState() => _UICardState();
}

class _UICardState extends State<UICard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
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
            ? Padding(padding: widget.padding, child: widget.child)
            : InkWell(
                onTap: widget.onTap,
                child: Padding(padding: widget.padding, child: widget.child),
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
    final c = tone.color(context);
    final bg = Color.alphaBlend(
      c.withValues(alpha: .10),
      Theme.of(context).colorScheme.surface,
    );
    final fg = uiReadable(c, bg);
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
                overflow: TextOverflow.ellipsis,
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
    final c = tone.color(context);
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
          color: c.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withValues(alpha: .25)),
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
                      color: Theme.of(context).colorScheme.onSurface,
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

class UICheckbox extends StatelessWidget {
  const UICheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  @override
  Widget build(BuildContext context) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    title: Text(label, style: const TextStyle(fontSize: 14)),
    value: value,
    onChanged: onChanged,
  );
}

class UISwitch extends StatelessWidget {
  const UISwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: const TextStyle(fontSize: 14)),
    value: value,
    onChanged: onChanged,
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
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    decoration: InputDecoration(labelText: label),
    initialValue: initialValue,
    items: items,
    onChanged: onChanged,
    validator: validator,
    isExpanded: true,
  );
}
