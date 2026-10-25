import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'components.dart';
import 'color_engine.dart';
import 'search_text.dart';

@immutable
class UITableColumn<T> {
  const UITableColumn({
    required this.label,
    required this.value,
    this.cellBuilder,
    this.compare,
    this.numeric = false,
    this.minWidth = 180,
  });
  final String label;

  /// Plain text is also used by the default cell. Numeric sorting needs compare.
  final String Function(T row) value;
  final Widget Function(BuildContext context, T row)? cellBuilder;

  /// Null disables sorting for this column.
  final Comparator<T>? compare;
  final bool numeric;

  /// Minimum content width on desktop, excluding table cell padding.
  final double minWidth;
}

/// In-memory, paged table. Compact regions/large text use labeled cards.
/// Parent owns vertical scrolling; only the current page builds cells.
class UITable<T> extends StatefulWidget {
  const UITable({
    super.key,
    required this.columns,
    required this.rows,
    this.pageSize = 10,
    this.rowKey,
    this.selectedKeys = const {},
    this.onSelectionChanged,
    this.loading = false,
    this.empty,
    this.label = 'Bảng dữ liệu',
    this.searchQuery = '',
    this.searchText,
    this.showSelectAll = false,
    this.onPageSizeChanged,
    this.pageSizeOptions = const [5, 10, 20, 50],
    this.error,
    this.onRetry,
  });
  final List<UITableColumn<T>> columns;
  final List<T> rows;
  final int pageSize;
  final Object Function(T row)? rowKey;
  final Set<Object> selectedKeys;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final bool loading;
  final Widget? empty;
  final String label;

  /// Controlled local search. Default: search the plain values of all columns.
  final String searchQuery;
  final String Function(T row)? searchText;

  /// Select only the currently displayed page, preserving other selected keys.
  final bool showSelectAll;
  final ValueChanged<int>? onPageSizeChanged;
  final List<int> pageSizeOptions;
  final String? error;
  final VoidCallback? onRetry;
  @override
  State<UITable<T>> createState() => _UITableState<T>();
}

class _UITableState<T> extends State<UITable<T>> {
  int _page = 0;
  int? _sort;
  bool _ascending = true;
  List<int>? _order;
  bool _keysValidated = false;
  List<String>? _searchCache;
  final _horizontal = ScrollController();
  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UITable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.rows, oldWidget.rows) ||
        !identical(widget.columns, oldWidget.columns)) {
      _order = null;
      _searchCache = null;
    }
    if (oldWidget.searchText != widget.searchText) _searchCache = null;
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.searchText != widget.searchText) {
      _order = null;
    }
    if (oldWidget.searchQuery != widget.searchQuery) _page = 0;
    if (_sort != null &&
        (_sort! >= widget.columns.length ||
            widget.columns[_sort!].label != oldWidget.columns[_sort!].label ||
            widget.columns[_sort!].compare == null)) {
      _sort = null;
    }
    if (!identical(widget.rows, oldWidget.rows) ||
        widget.rowKey != oldWidget.rowKey) {
      _keysValidated = false;
    }
    if (widget.pageSize != oldWidget.pageSize) _page = 0;
  }

  void _sortBy(int index) => setState(() {
    _ascending = _sort == index ? !_ascending : true;
    _sort = index;
    _order = null;
    _page = 0;
  });
  void _select(T row, bool selected) {
    final keys = {...widget.selectedKeys};
    final key = widget.rowKey!(row);
    if (selected) {
      keys.add(key);
    } else {
      keys.remove(key);
    }
    widget.onSelectionChanged!(Set.unmodifiable(keys));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.columns.isEmpty) {
      throw ArgumentError('UITable needs at least one column.');
    }
    if (widget.columns.any((c) => !c.minWidth.isFinite || c.minWidth < 48)) {
      throw ArgumentError('Column minWidth must be finite and >= 48.');
    }
    if (widget.pageSizeOptions.any((n) => n < 1 || n > 100)) {
      throw ArgumentError('pageSizeOptions must be within 1–100.');
    }
    if (widget.pageSize < 1 || widget.pageSize > 100) {
      throw RangeError.range(widget.pageSize, 1, 100, 'pageSize');
    }
    final selectable = widget.onSelectionChanged != null;
    if (selectable && widget.rowKey == null) {
      throw ArgumentError('Selection requires rowKey.');
    }
    if (!_keysValidated) {
      if (widget.rowKey != null &&
          widget.rows.map(widget.rowKey!).toSet().length !=
              widget.rows.length) {
        throw ArgumentError('Row keys must be unique.');
      }
      _keysValidated = true;
    }
    final s = Theme.of(context).colorScheme;
    if (widget.loading) {
      return Semantics(
        label: '${widget.label}: đang tải',
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(24),
          color: s.surfaceContainerLow,
          child: const Center(child: Text('Đang tải dữ liệu…')),
        ),
      );
    }
    if (widget.error != null) {
      return UIAlert(
        message: widget.error!,
        tone: UITone.danger,
        actionLabel: widget.onRetry == null ? null : 'Thử lại',
        onAction: widget.onRetry,
      );
    }
    if (widget.rows.isEmpty) {
      return Semantics(
        label: widget.label,
        child:
            widget.empty ??
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Chưa có dữ liệu',
                  style: TextStyle(color: s.onSurfaceVariant),
                ),
              ),
            ),
      );
    }
    final order = _order ??= (() {
      final needle = normalizeSearchText(widget.searchQuery);
      if (needle.isNotEmpty) {
        _searchCache ??= [
          for (final row in widget.rows)
            normalizeSearchText(
              widget.searchText?.call(row) ??
                  widget.columns.map((c) => c.value(row)).join(' '),
            ),
        ];
      }
      final indices = [
        for (var i = 0; i < widget.rows.length; i++)
          if (needle.isEmpty || _searchCache![i].contains(needle)) i,
      ];
      if (_sort == null) return indices;
      return indices..sort((a, b) {
        final compare = widget.columns[_sort!].compare;
        if (compare == null) return a.compareTo(b);
        final result = _ascending
            ? compare(widget.rows[a], widget.rows[b])
            : compare(widget.rows[b], widget.rows[a]);
        return result == 0 ? a.compareTo(b) : result;
      });
    })();
    if (order.isEmpty) {
      return Semantics(
        label: widget.label,
        liveRegion: true,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Không có kết quả phù hợp')),
        ),
      );
    }
    final pages = (order.length / widget.pageSize).ceil();
    final page = math.min(_page, pages - 1);
    final start = page * widget.pageSize;
    final indices = order.skip(start).take(widget.pageSize).toList();
    Widget checkbox(T row) => MergeSemantics(
      child: Semantics(
        label: 'Chọn dòng ${widget.rowKey!(row)}',
        child: UICheckbox(
          value: widget.selectedKeys.contains(widget.rowKey!(row)),
          onChanged: (v) => _select(row, v ?? false),
        ),
      ),
    );
    Color rowColor(int index) =>
        selectable &&
            widget.selectedKeys.contains(widget.rowKey!(widget.rows[index]))
        ? s.primaryContainer
        : index.isOdd
        ? s.surfaceContainerLow
        : s.surfaceContainerLowest;
    Widget cell(UITableColumn<T> column, T row, Color surface) =>
        UISurfaceScope(
          color: surface,
          child: Builder(
            builder: (context) =>
                column.cellBuilder?.call(context, row) ??
                Text(
                  column.value(row),
                  softWrap: true,
                  style: TextStyle(
                    color:
                        selectable &&
                            widget.selectedKeys.contains(widget.rowKey!(row))
                        ? s.onPrimaryContainer
                        : s.onSurface,
                  ),
                ),
          ),
        );
    return UIAdaptiveBuilder(
      builder: (context, ui) {
        final compact = ui.compact || ui.textScale > 1.5;
        final sortOptions = [
          for (var i = 0; i < widget.columns.length; i++)
            if (widget.columns[i].compare != null) i,
        ];
        Widget pageContent;
        if (compact) {
          pageContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sortOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final i in sortOptions)
                        TextButton.icon(
                          onPressed: () => _sortBy(i),
                          icon: Icon(
                            _sort == i && !_ascending
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            size: 16,
                          ),
                          label: Text(
                            'Sắp xếp ${widget.columns[i].label}',
                            softWrap: true,
                          ),
                        ),
                    ],
                  ),
                ),
              for (final index in indices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    key: ValueKey(
                      widget.rowKey?.call(widget.rows[index]) ?? index,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: rowColor(index),
                      border: Border.all(color: s.outlineVariant),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (selectable)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: checkbox(widget.rows[index]),
                          ),
                        for (final column in widget.columns)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  column.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: s.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                cell(
                                  column,
                                  widget.rows[index],
                                  rowColor(index),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        } else {
          final contentWidth = widget.columns.fold(
            0.0,
            (sum, c) => sum + c.minWidth,
          );
          final chrome =
              32.0 +
              (widget.columns.length - 1 + (selectable ? 1 : 0)) * 20 +
              (selectable ? 96 : 0);
          final tableWidth = math.max(ui.width, contentWidth + chrome);
          final extraWidth =
              (tableWidth - contentWidth - chrome) / widget.columns.length;
          pageContent = Scrollbar(
            controller: _horizontal,
            thumbVisibility: tableWidth > ui.width,
            child: SingleChildScrollView(
              controller: _horizontal,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: DataTable(
                  sortColumnIndex: _sort == null
                      ? null
                      : _sort! + (selectable ? 1 : 0),
                  sortAscending: _ascending,
                  horizontalMargin: 16,
                  columnSpacing: 20,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: WidgetStatePropertyAll(
                    s.surfaceContainerHigh,
                  ),
                  headingTextStyle: TextStyle(
                    color: s.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  dataTextStyle: TextStyle(color: s.onSurface, fontSize: 14),
                  columns: [
                    if (selectable)
                      const DataColumn(
                        label: Text('Chọn'),
                        columnWidth: FixedColumnWidth(96),
                      ),
                    for (var i = 0; i < widget.columns.length; i++)
                      DataColumn(
                        columnWidth: FixedColumnWidth(
                          widget.columns[i].minWidth + extraWidth,
                        ),
                        numeric: widget.columns[i].numeric,
                        label: Expanded(
                          child: Text(widget.columns[i].label, softWrap: true),
                        ),
                        onSort: widget.columns[i].compare == null
                            ? null
                            : (_, ascending) => _sortBy(i),
                      ),
                  ],
                  rows: [
                    for (final index in indices)
                      DataRow(
                        key: ValueKey(
                          widget.rowKey?.call(widget.rows[index]) ?? index,
                        ),
                        color: WidgetStatePropertyAll(
                          selectable &&
                                  widget.selectedKeys.contains(
                                    widget.rowKey!(widget.rows[index]),
                                  )
                              ? s.primaryContainer
                              : index.isOdd
                              ? s.surfaceContainerLow
                              : s.surfaceContainerLowest,
                        ),
                        cells: [
                          if (selectable)
                            DataCell(checkbox(widget.rows[index])),
                          for (final column in widget.columns)
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: cell(
                                  column,
                                  widget.rows[index],
                                  rowColor(index),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        return Semantics(
          container: true,
          label: widget.label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selectable && widget.showSelectAll)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MergeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              tristate: true,
                              value:
                                  indices.every(
                                    (i) => widget.selectedKeys.contains(
                                      widget.rowKey!(widget.rows[i]),
                                    ),
                                  )
                                  ? true
                                  : indices.any(
                                      (i) => widget.selectedKeys.contains(
                                        widget.rowKey!(widget.rows[i]),
                                      ),
                                    )
                                  ? null
                                  : false,
                              onChanged: (_) {
                                final pageKeys = indices
                                    .map((i) => widget.rowKey!(widget.rows[i]))
                                    .toSet();
                                final keys = {...widget.selectedKeys};
                                if (keys.containsAll(pageKeys)) {
                                  keys.removeAll(pageKeys);
                                } else {
                                  keys.addAll(pageKeys);
                                }
                                widget.onSelectionChanged!(
                                  Set.unmodifiable(keys),
                                );
                              },
                            ),
                            const Flexible(child: Text('Chọn trang này')),
                          ],
                        ),
                      ),
                      Text('Đã chọn: ${widget.selectedKeys.length}'),
                    ],
                  ),
                ),
              pageContent,
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${start + 1}–${math.min(start + widget.pageSize, order.length)} / ${order.length}',
                  ),
                  if (widget.onPageSizeChanged != null)
                    SizedBox(
                      width: math.min(ui.width, 180),
                      child: UISelect<int>(
                        key: ValueKey(widget.pageSize),
                        label: 'Dòng mỗi trang',
                        initialValue: widget.pageSize,
                        searchable: false,
                        options:
                            ({
                                  ...widget.pageSizeOptions,
                                  widget.pageSize,
                                }.toList()..sort())
                                .map((n) => UIOption(value: n, label: '$n'))
                                .toList(),
                        onChanged: (n) {
                          if (n != null) widget.onPageSizeChanged!(n);
                        },
                      ),
                    ),
                  IconButton(
                    tooltip: 'Trang trước',
                    onPressed: page == 0
                        ? null
                        : () => setState(() => _page = page - 1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Trang ${page + 1} / $pages'),
                  IconButton(
                    tooltip: 'Trang sau',
                    onPressed: page + 1 >= pages
                        ? null
                        : () => setState(() => _page = page + 1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
