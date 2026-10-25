part of 'components.dart';

abstract final class UIDatePicker {
  static (DateTime, DateTime) _bounds(DateTime? first, DateTime? last) {
    final start = DateUtils.dateOnly(first ?? DateTime(1900));
    final end = DateUtils.dateOnly(last ?? DateTime(2100, 12, 31));
    if (end.isBefore(start)) {
      throw ArgumentError('lastDate must be >= firstDate');
    }
    return (start, end);
  }

  static bool _allowed(
    DateTime date,
    DateTime first,
    DateTime last,
    SelectableDayPredicate? predicate,
  ) {
    final day = DateUtils.dateOnly(date);
    return !day.isBefore(first) &&
        !day.isAfter(last) &&
        (predicate?.call(day) ?? true);
  }

  /// Native accessible calendar/input, date-only values; cancellation returns null.
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    SelectableDayPredicate? selectableDayPredicate,
    Locale? locale,
    String? title,
    String? confirmLabel,
    String? cancelLabel,
    DatePickerEntryMode entryMode = DatePickerEntryMode.calendar,
    bool useRootNavigator = true,
  }) {
    final (first, last) = _bounds(firstDate, lastDate);
    if (initialDate != null &&
        !_allowed(initialDate, first, last, selectableDayPredicate)) {
      throw ArgumentError.value(
        initialDate,
        'initialDate',
        'Must be a selectable date within the bounds',
      );
    }
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: first,
      lastDate: last,
      selectableDayPredicate: selectableDayPredicate,
      locale:
          locale ??
          DatePickerTheme.of(context).locale ??
          Localizations.localeOf(context),
      helpText: title,
      confirmText: confirmLabel,
      cancelText: cancelLabel,
      initialEntryMode: entryMode,
      useRootNavigator: useRootNavigator,
    );
  }

  static DatePickerEntryMode _rangeMode(
    BuildContext context,
    DatePickerEntryMode? requested,
  ) {
    if (requested != null) return requested;
    final media = MediaQuery.of(context);
    if (media.size.width >= 400) return DatePickerEntryMode.calendar;
    if (media.textScaler.scale(14) / 14 > 1.3) {
      return DatePickerEntryMode.inputOnly;
    }
    // Native range header has an inflexible start-date label. Measure only at
    // opening, preserving the user's font scale instead of shrinking it to fit.
    final theme = Theme.of(context);
    final painter = TextPainter(
      text: TextSpan(
        text: '${MaterialLocalizations.of(context).dateRangeStartLabel} – ',
        style:
            theme.datePickerTheme.rangePickerHeaderHeadlineStyle ??
            theme.textTheme.titleLarge,
      ),
      textScaler: media.textScaler,
      textDirection: Directionality.of(context),
    )..layout();
    final available =
        media.size.width - (media.size.width < 360 ? 42 : 72) - 64;
    final fits = painter.width < available;
    painter.dispose();
    return fits ? DatePickerEntryMode.calendar : DatePickerEntryMode.inputOnly;
  }

  static Future<DateTimeRange?> range(
    BuildContext context, {
    DateTimeRange? initialRange,
    DateTime? firstDate,
    DateTime? lastDate,
    Locale? locale,
    String? title,
    String? confirmLabel,
    String? cancelLabel,
    DatePickerEntryMode? entryMode,
    bool useRootNavigator = true,
  }) {
    final (first, last) = _bounds(firstDate, lastDate);
    if (initialRange != null &&
        (!_allowed(initialRange.start, first, last, null) ||
            !_allowed(initialRange.end, first, last, null))) {
      throw ArgumentError.value(
        initialRange,
        'initialRange',
        'Must be within the bounds',
      );
    }
    return showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      initialEntryMode: _rangeMode(context, entryMode),
      firstDate: first,
      lastDate: last,
      locale:
          locale ??
          DatePickerTheme.of(context).locale ??
          Localizations.localeOf(context),
      helpText: title,
      confirmText: confirmLabel,
      saveText: confirmLabel,
      cancelText: cancelLabel,
      useRootNavigator: useRootNavigator,
      builder: (pickerContext, child) {
        final theme = Theme.of(pickerContext);
        if (MediaQuery.sizeOf(pickerContext).width >= 400 ||
            theme.datePickerTheme.rangePickerHeaderHeadlineStyle != null) {
          return child!;
        }
        return Theme(
          data: theme.copyWith(
            datePickerTheme: theme.datePickerTheme.copyWith(
              rangePickerHeaderHeadlineStyle: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

/// A date-only controlled input. Update value in onChanged; null disables edits.
/// Participates in Form and optional UIForm server errors by name.
class UIDateField extends StatefulWidget {
  const UIDateField({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.name,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.validator,
    this.errorText,
    this.hint = 'Chọn ngày',
    this.invalidDateMessage = 'Ngày không nằm trong lựa chọn hợp lệ',
    this.helper,
    this.clearable = true,
    this.enabled = true,
    this.format,
    this.locale,
    this.focusNode,
    this.autofocus = false,
    this.entryMode = DatePickerEntryMode.calendar,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });
  final String label;
  final DateTime? value, firstDate, lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final String? name, helper, errorText;
  final String hint, invalidDateMessage;
  final SelectableDayPredicate? selectableDayPredicate;
  final FormFieldValidator<DateTime>? validator;
  final String Function(DateTime date)? format;
  final Locale? locale;
  final bool clearable, enabled, autofocus;
  final FocusNode? focusNode;
  final DatePickerEntryMode entryMode;
  final AutovalidateMode autovalidateMode;
  @override
  State<UIDateField> createState() => _UIDateFieldState();
}

class _UIDateFieldState extends State<UIDateField> {
  late FocusNode _focus;
  bool _opening = false, _focused = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _focus =
        widget.focusNode ??
        FocusNode(debugLabel: 'UIDateField ${widget.label}');
  }

  @override
  void didUpdateWidget(covariant UIDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) _focus.dispose();
      _focus =
          widget.focusNode ??
          FocusNode(debugLabel: 'UIDateField ${widget.label}');
    }
    if (!DateUtils.isSameDay(oldWidget.value, widget.value) ||
        oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate ||
        oldWidget.name != widget.name ||
        oldWidget.enabled != widget.enabled) {
      _generation++;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  bool get _enabled =>
      widget.enabled &&
      widget.onChanged != null &&
      !(_UIFormScope.maybeOf(context)?.isSubmitting ?? false);

  void _pick(FormFieldState<DateTime> field, DateTime? value) {
    if (!mounted || !field.mounted || !_enabled) return;
    final (first, last) = UIDatePicker._bounds(
      widget.firstDate,
      widget.lastDate,
    );
    if (value != null &&
        !UIDatePicker._allowed(
          value,
          first,
          last,
          widget.selectableDayPredicate,
        )) {
      return;
    }
    field.didChange(value);
    if (widget.name != null) {
      _UIFormScope.maybeOf(context)?._clearFieldError(widget.name!);
    }
    widget.onChanged?.call(value);
  }

  Future<void> _open(FormFieldState<DateTime> field) async {
    if (!_enabled || _opening) return;
    final token = ++_generation;
    final (first, last) = UIDatePicker._bounds(
      widget.firstDate,
      widget.lastDate,
    );
    final current = field.value;
    setState(() => _opening = true);
    try {
      final result = await UIDatePicker.show(
        context,
        title: widget.label,
        initialDate:
            current != null &&
                UIDatePicker._allowed(
                  current,
                  first,
                  last,
                  widget.selectableDayPredicate,
                )
            ? current
            : null,
        firstDate: first,
        lastDate: last,
        selectableDayPredicate: widget.selectableDayPredicate,
        locale: widget.locale,
        entryMode: widget.entryMode,
      );
      if (mounted && token == _generation && result != null) {
        _pick(field, result);
      }
    } finally {
      if (mounted) {
        setState(() => _opening = false);
        if (_enabled) _focus.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final (first, last) = UIDatePicker._bounds(
      widget.firstDate,
      widget.lastDate,
    );
    final form = _UIFormScope.maybeOf(context);
    final enabled = _enabled;
    return _DateFormInput(
      value: widget.value == null ? null : DateUtils.dateOnly(widget.value!),
      enabled: enabled,
      autovalidateMode: widget.autovalidateMode,
      forceErrorText: widget.errorText ?? form?.fieldErrors[widget.name],
      validator: (date) =>
          date != null &&
              !UIDatePicker._allowed(
                date,
                first,
                last,
                widget.selectableDayPredicate,
              )
          ? widget.invalidDateMessage
          : widget.validator?.call(date),
      builder: (field) => _buildControl(context, field, enabled),
    );
  }

  Widget _buildControl(
    BuildContext context,
    FormFieldState<DateTime> field,
    bool enabled,
  ) {
    final s = Theme.of(context).colorScheme;
    final display = field.value == null
        ? widget.hint
        : widget.format?.call(field.value!) ??
              MaterialLocalizations.of(context).formatMediumDate(field.value!);
    final trigger = Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      value: display,
      onTap: enabled ? () => _open(field) : null,
      child: ExcludeSemantics(
        child: InkWell(
          focusNode: _focus,
          autofocus: widget.autofocus,
          onFocusChange: (value) => setState(() => _focused = value),
          onTap: enabled ? () => _open(field) : null,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: enabled ? s.onSurfaceVariant : s.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      color: enabled ? s.onSurface : s.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
    return UIAnimatedSize(
      duration: UIMotion.fast,
      child: Material(
        type: MaterialType.transparency,
        child: InputDecorator(
          isFocused: _focused || _opening,
          isEmpty: false,
          decoration: InputDecoration(
            label: ExcludeSemantics(child: Text(widget.label)),
            helperText: widget.helper,
            errorText: field.errorText,
            errorMaxLines: 4,
            helperMaxLines: 4,
            enabled: enabled,
            contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 4, 4, 4),
          ),
          child: Row(
            children: [
              Expanded(child: trigger),
              if (widget.clearable &&
                  field.value != null &&
                  widget.onChanged != null)
                IconButton(
                  tooltip: 'Xóa ${widget.label.toLowerCase()}',
                  onPressed: enabled && !_opening
                      ? () => _pick(field, null)
                      : null,
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateFormInput extends FormField<DateTime> {
  const _DateFormInput({
    required this.value,
    required super.builder,
    required super.enabled,
    required super.validator,
    required super.forceErrorText,
    required super.autovalidateMode,
  }) : super(initialValue: value);
  final DateTime? value;
  @override
  FormFieldState<DateTime> createState() => _DateFormInputState();
}

class _DateFormInputState extends FormFieldState<DateTime> {
  @override
  void didUpdateWidget(covariant _DateFormInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final input = widget as _DateFormInput;
    if (!DateUtils.isSameDay(oldWidget.value, input.value)) {
      setValue(input.value);
    }
  }
}
