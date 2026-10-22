part of 'components.dart';

/// A form select with a themed anchored menu or compact touch sheet.
/// Existing DropdownMenuItem callers remain supported; options add searchable labels.
class UISelect<T> extends StatefulWidget {
  const UISelect({
    super.key,
    required this.label,
    this.items = const [],
    this.options = const [],
    this.initialValue,
    this.onChanged,
    this.validator,
    this.hint = 'Chọn một mục',
    this.helper,
    this.searchable,
    this.optionLabel,
    this.searchHint = 'Tìm lựa chọn…',
    this.emptyLabel = 'Không tìm thấy lựa chọn',
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.disabled,
  });
  final String label, hint, searchHint, emptyLabel;
  final String? helper;
  final List<DropdownMenuItem<T>> items;
  final List<UIOption<T>> options;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled, autofocus;
  final bool? searchable;
  final String Function(T)? optionLabel;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;
  @override
  State<UISelect<T>> createState() => _UISelectState<T>();
}

class _SelectEntry<T> {
  const _SelectEntry({
    required this.value,
    required this.child,
    required this.label,
    required this.enabled,
    this.icon,
    this.onTap,
    this.measurable = true,
  });
  final T value;
  final Widget child;
  final String? label;
  final bool enabled, measurable;
  final IconData? icon;
  final VoidCallback? onTap;
}

class _UISelectState<T> extends State<UISelect<T>> {
  final _menu = MenuController();
  final _anchorKey = GlobalKey();
  double? _popupHeight;
  late FocusNode _focus;
  bool _open = false, _focused = false, _hovered = false;

  @override
  void initState() {
    super.initState();
    _focus =
        widget.focusNode ?? FocusNode(debugLabel: 'UISelect ${widget.label}');
  }

  @override
  void didUpdateWidget(covariant UISelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) _focus.dispose();
      _focus =
          widget.focusNode ?? FocusNode(debugLabel: 'UISelect ${widget.label}');
    }
    if ((!widget.enabled || widget.onChanged == null) && _menu.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _menu.close();
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  List<_SelectEntry<T>> get _entries {
    if (widget.options.isNotEmpty && widget.items.isNotEmpty) {
      throw ArgumentError('Use either options or items, not both.');
    }
    if (widget.items.any((item) => item.value == null)) {
      throw ArgumentError('Select values must be unique and non-null.');
    }
    final result = widget.options.isNotEmpty
        ? [
            for (final o in widget.options)
              _SelectEntry<T>(
                value: o.value,
                label: o.label,
                child: Text(o.label),
                icon: o.icon,
                enabled: o.enabled,
              ),
          ]
        : [
            for (final o in widget.items)
              _SelectEntry<T>(
                value: o.value as T,
                child: o.child,
                enabled: o.enabled,
                onTap: o.onTap,
                label:
                    widget.optionLabel?.call(o.value as T) ??
                    (o.child is Text
                        ? ((o.child as Text).data ??
                              (o.child as Text).textSpan?.toPlainText())
                        : null),
                measurable: o.child is Text,
              ),
          ];
    if (result.any((e) => e.value == null) ||
        result.map((e) => e.value).toSet().length != result.length) {
      throw ArgumentError('Select values must be unique and non-null.');
    }
    return result;
  }

  void _pick(_SelectEntry<T> entry, FormFieldState<T> field) {
    if (!mounted ||
        !field.mounted ||
        !widget.enabled ||
        widget.onChanged == null) {
      return;
    }
    if (!_entries.any((e) => e.value == entry.value && e.enabled)) return;
    field.didChange(entry.value);
    entry.onTap?.call();
    widget.onChanged!(entry.value);
  }

  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      final entries = _entries;
      final searchable =
          widget.searchable ??
          (entries.length >= 8 && entries.every((e) => e.label != null));
      if (searchable && entries.any((e) => e.label == null)) {
        throw ArgumentError(
          'Search requires UIOption labels or optionLabel for custom items.',
        );
      }
      final enabled =
          widget.enabled &&
          widget.onChanged != null &&
          entries.any((e) => e.enabled);
      final colors = YouthColors.of(context);
      final scheme = colors.scheme;
      final viewport = MediaQuery.sizeOf(context);
      final textScaler = MediaQuery.textScalerOf(context);
      final reducedMotion = MediaQuery.disableAnimationsOf(context);
      final width = math.min(ui.width, math.max(48.0, viewport.width - 32));
      final height =
          _popupHeight ?? math.min(420.0, math.max(96.0, viewport.height * .6));
      return FormField<T>(
        initialValue: widget.initialValue,
        enabled: enabled,
        autovalidateMode: widget.autovalidateMode,
        validator: (value) =>
            value != null && !entries.any((e) => e.value == value)
            ? 'Lựa chọn không còn khả dụng'
            : widget.validator?.call(value),
        builder: (field) {
          final selected = entries
              .where((e) => e.value == field.value)
              .firstOrNull;
          Widget panel(
            BuildContext panelContext, {
            required bool sheet,
            required VoidCallback dismiss,
          }) => MediaQuery(
            data: MediaQuery.of(panelContext).copyWith(
              textScaler: textScaler,
              disableAnimations: reducedMotion,
            ),
            child: _SelectPanel<T>(
              entries: entries,
              value: field.value,
              title: widget.label,
              width: sheet ? MediaQuery.sizeOf(panelContext).width : width,
              maxHeight: sheet
                  ? math.max(
                      96,
                      (MediaQuery.sizeOf(panelContext).height -
                              MediaQuery.viewInsetsOf(panelContext).bottom -
                              MediaQuery.viewPaddingOf(panelContext).top) *
                          .85,
                    )
                  : height,
              searchable: searchable,
              searchHint: widget.searchHint,
              emptyLabel: widget.emptyLabel,
              sheet: sheet,
              onDismiss: dismiss,
              onPick: (entry) {
                dismiss();
                _pick(entry, field);
              },
            ),
          );
          Future<void> open() async {
            if (!enabled || _open) {
              if (_menu.isOpen) _menu.close();
              return;
            }
            // Presentation follows the viewport/input; a narrow desktop field still anchors a popup.
            if (viewport.width < ui.config.compactBreakpoint && !ui.pointer) {
              setState(() => _open = true);
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                requestFocus: true,
                showDragHandle: true,
                backgroundColor: scheme.surfaceContainerLowest,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (sheetContext) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                  ),
                  child: panel(
                    sheetContext,
                    sheet: true,
                    dismiss: () => Navigator.pop(sheetContext),
                  ),
                ),
              );
              if (mounted) {
                setState(() => _open = false);
                _focus.requestFocus();
              }
            } else {
              final box =
                  _anchorKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null && box.hasSize) {
                final top = box.localToGlobal(Offset.zero).dy;
                final padding = MediaQuery.paddingOf(context);
                final above = top - padding.top - 12;
                final below =
                    viewport.height -
                    padding.bottom -
                    top -
                    box.size.height -
                    12;
                final available = below >= 200 || below >= above
                    ? below
                    : above;
                setState(
                  () =>
                      _popupHeight = math.max(48.0, math.min(420.0, available)),
                );
              }
              _menu.open();
            }
          }

          return MenuAnchor(
            controller: _menu,
            childFocusNode: _focus,
            consumeOutsideTap: true,
            useRootOverlay: true,
            crossAxisUnconstrained: false,
            animated: !MediaQuery.disableAnimationsOf(context),
            alignmentOffset: const Offset(0, 6),
            onOpen: () {
              if (mounted) setState(() => _open = true);
            },
            onClose: () {
              if (mounted) setState(() => _open = false);
            },
            style: MenuStyle(
              alignment: AlignmentDirectional.bottomStart,
              backgroundColor: WidgetStatePropertyAll(
                scheme.surfaceContainerLowest,
              ),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              elevation: const WidgetStatePropertyAll(8),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              minimumSize: WidgetStatePropertyAll(Size(width, 0)),
              maximumSize: WidgetStatePropertyAll(Size(width, height)),
              side: WidgetStatePropertyAll(
                BorderSide(color: scheme.outlineVariant),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            menuChildren: [panel(context, sheet: false, dismiss: _menu.close)],
            builder: (context, controller, child) => Semantics(
              key: _anchorKey,
              container: true,
              button: true,
              enabled: enabled,
              expanded: _open,
              label: widget.label,
              value: selected?.label,
              onTap: enabled ? open : null,
              child: ExcludeSemantics(
                child: Focus(
                  canRequestFocus: false,
                  onKeyEvent: (_, event) {
                    if (enabled &&
                        event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      open();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: InkWell(
                    focusNode: _focus,
                    autofocus: widget.autofocus,
                    onTap: enabled ? open : null,
                    onFocusChange: (v) => setState(() => _focused = v),
                    borderRadius: BorderRadius.circular(14),
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onHover: (v) => setState(() => _hovered = v),
                    child: InputDecorator(
                      isFocused: _focused || _open,
                      isHovering: enabled && _hovered,
                      isEmpty: selected == null,
                      decoration: InputDecoration(
                        labelText: widget.label,
                        hoverColor: scheme.primary.withValues(alpha: .04),
                        hintText: widget.hint,
                        helperText: widget.helper,
                        errorText: field.errorText,
                        enabled: enabled,
                        contentPadding: ui.controlPadding,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: selected == null
                                ? const Text('')
                                : DefaultTextStyle.merge(
                                    style: TextStyle(
                                      color: enabled
                                          ? scheme.onSurface
                                          : scheme.onSurfaceVariant,
                                    ),
                                    child: selected.child,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedRotation(
                            turns: _open ? .5 : 0,
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 160),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 22,
                              color: enabled
                                  ? scheme.onSurfaceVariant
                                  : scheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

String _selectSearchKey(String input) {
  var result = input.toLowerCase().trim();
  const groups = [
    'àáạảãâầấậẩẫăằắặẳẵ',
    'èéẹẻẽêềếệểễ',
    'ìíịỉĩ',
    'òóọỏõôồốộổỗơờớợởỡ',
    'ùúụủũưừứựửữ',
    'ỳýỵỷỹ',
    'đ',
  ];
  const plain = ['a', 'e', 'i', 'o', 'u', 'y', 'd'];
  for (var i = 0; i < groups.length; i++) {
    result = result.replaceAll(RegExp('[${groups[i]}]'), plain[i]);
  }
  return result;
}

class _SelectPanel<T> extends StatefulWidget {
  const _SelectPanel({
    required this.entries,
    required this.value,
    required this.title,
    required this.width,
    required this.maxHeight,
    required this.searchable,
    required this.searchHint,
    required this.emptyLabel,
    required this.sheet,
    required this.onPick,
    required this.onDismiss,
  });
  final List<_SelectEntry<T>> entries;
  final T? value;
  final String title, searchHint, emptyLabel;
  final double width, maxHeight;
  final bool searchable, sheet;
  final ValueChanged<_SelectEntry<T>> onPick;
  final VoidCallback onDismiss;
  @override
  State<_SelectPanel<T>> createState() => _SelectPanelState<T>();
}

class _SelectPanelState<T> extends State<_SelectPanel<T>> {
  late final ScrollController _scroll;
  final _searchFocus = FocusNode();
  final _search = TextEditingController();
  final _nodes = <T, FocusNode>{};
  String _query = '';
  int _active = -1;
  bool _positioned = false;
  List<double> _heights = [];
  List<_SelectEntry<T>>? _sourceCache, _filterCache;
  String? _queryCache;
  Map<T, String>? _normalizedLabels;
  Object? _heightKey;
  List<_SelectEntry<T>> get _filtered {
    if (identical(_sourceCache, widget.entries) && _queryCache == _query) {
      return _filterCache!;
    }
    if (!identical(_sourceCache, widget.entries)) _normalizedLabels = null;
    _sourceCache = widget.entries;
    _queryCache = _query;
    final needle = _selectSearchKey(_query);
    if (needle.isNotEmpty) {
      _normalizedLabels ??= {
        for (final entry in widget.entries)
          entry.value: _selectSearchKey(entry.label ?? ''),
      };
    }
    return _filterCache = needle.isEmpty
        ? widget.entries
        : widget.entries
              .where(
                (entry) => _normalizedLabels![entry.value]!.contains(needle),
              )
              .toList();
  }

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchFocus.dispose();
    _search.dispose();
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _move(int index, List<_SelectEntry<T>> entries) {
    if (index < 0 || index >= entries.length) return;
    _active = index;
    final offset = _heights.take(index).fold(0.0, (a, b) => a + b);
    if (_scroll.hasClients) {
      _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final node = _nodes[entries[index].value];
      node?.requestFocus();
      if (node?.context != null) {
        Scrollable.ensureVisible(node!.context!, alignment: .5);
      }
    });
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    final entries = _filtered;
    final enabled = [
      for (var i = 0; i < entries.length; i++)
        if (entries[i].enabled) i,
    ];
    if (enabled.isEmpty) return KeyEventResult.ignored;
    if (_searchFocus.hasFocus &&
        key != LogicalKeyboardKey.arrowDown &&
        key != LogicalKeyboardKey.arrowUp) {
      return KeyEventResult.ignored;
    }
    int? target;
    if (key == LogicalKeyboardKey.home) target = enabled.first;
    if (key == LogicalKeyboardKey.end) target = enabled.last;
    if (key == LogicalKeyboardKey.arrowDown) {
      target = enabled.firstWhere(
        (i) => i > _active,
        orElse: () => enabled.first,
      );
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      target = enabled.reversed.firstWhere(
        (i) => i < _active,
        orElse: () => enabled.last,
      );
    }
    if (target == null) return KeyEventResult.ignored;
    _move(target, entries);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filtered;
    final colors = YouthColors.of(context);
    final s = colors.scheme;
    final style = Theme.of(context).textTheme.labelLarge!;
    final contentWidth = math.max(24.0, widget.width - 16);
    final textWidth = math.max(
      16.0,
      contentWidth - 64 - (entries.any((e) => e.icon != null) ? 32 : 0),
    );
    final heightKey = (
      entries,
      textWidth,
      style.copyWith(color: Colors.transparent),
      MediaQuery.textScalerOf(context),
      Directionality.of(context),
    );
    if (_heightKey != heightKey) {
      _heightKey = heightKey;
      _heights = [
        for (final entry in entries)
          (() {
            if (!entry.measurable) return 56.0;
            final painter = TextPainter(
              text: TextSpan(text: entry.label, style: style),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(maxWidth: textWidth);
            final result = math.max(48.0, painter.height.ceilToDouble() + 24);
            painter.dispose();
            return result;
          })(),
      ];
    }
    if (!_positioned) {
      _positioned = true;
      final index = entries.indexWhere((e) => e.value == widget.value);
      _active = index >= 0 ? index : entries.indexWhere((e) => e.enabled);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scroll.hasClients || index < 0) return;
        final offset = _heights.take(index).fold(0.0, (a, b) => a + b);
        _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
      });
    }
    final allMeasured = entries.every((e) => e.measurable);
    return Focus(
      onKeyEvent: _key,
      child: SizedBox(
        width: widget.width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: SafeArea(
            top: false,
            bottom: widget.sheet,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.sheet)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 12,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Đóng',
                            onPressed: widget.onDismiss,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  if (widget.searchable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _search,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          hintText: widget.searchHint,
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Xóa tìm kiếm',
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _search.clear();
                                    setState(() {
                                      _query = '';
                                      _active = -1;
                                    });
                                    if (_scroll.hasClients) _scroll.jumpTo(0);
                                    _searchFocus.requestFocus();
                                  },
                                ),
                          prefixIcon: const Icon(Icons.search_rounded),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {
                            _query = v;
                            _active = -1;
                          });
                          if (_scroll.hasClients) _scroll.jumpTo(0);
                        },
                        onSubmitted: (_) {
                          final first = entries
                              .where((e) => e.enabled)
                              .firstOrNull;
                          if (first != null) widget.onPick(first);
                        },
                      ),
                    ),
                  if (entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          widget.emptyLabel,
                          style: TextStyle(color: s.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: Scrollbar(
                        controller: _scroll,
                        child: ListView.builder(
                          controller: _scroll,
                          shrinkWrap: true,
                          primary: false,
                          padding: EdgeInsets.zero,
                          itemCount: entries.length,
                          itemExtentBuilder: allMeasured
                              ? (index, _) => _heights[index]
                              : null,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final selected = entry.value == widget.value;
                            final focus = _nodes.putIfAbsent(
                              entry.value,
                              () => FocusNode(),
                            );
                            UIControlColors resolve(Set<WidgetState> states) =>
                                colors.button(
                                  UITone.primary,
                                  UIButtonVariant.outline,
                                  {
                                    ...states,
                                    if (selected) WidgetState.selected,
                                  },
                                  surface: s.surfaceContainerLowest,
                                );
                            return Semantics(
                              container: true,
                              selected: selected,
                              child: MenuItemButton(
                                overflowAxis: Axis.vertical,
                                requestFocusOnHover: false,
                                focusNode: focus,
                                autofocus: !widget.sheet && index == _active,
                                onFocusChange: (focused) {
                                  if (focused) _active = index;
                                },
                                onPressed: entry.enabled
                                    ? () => widget.onPick(entry)
                                    : null,
                                style: ButtonStyle(
                                  minimumSize: const WidgetStatePropertyAll(
                                    Size(48, 48),
                                  ),
                                  visualDensity: VisualDensity.standard,
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) => resolve(states).background,
                                      ),
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) => resolve(states).foreground,
                                      ),
                                  overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  side: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.focused)
                                        ? BorderSide(
                                            color: colors.focus,
                                            width: 2,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (entry.icon != null) ...[
                                      Icon(entry.icon, size: 20),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(child: entry.child),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 20,
                                      child: selected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 20,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
