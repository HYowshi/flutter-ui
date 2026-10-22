import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'components.dart';
import 'color_engine.dart';

@immutable
class UITableColumn<T> {
  const UITableColumn({
    required this.label,
    required this.value,
    this.cellBuilder,
    this.compare,
    this.numeric = false,
  });
  final String label;

  /// Plain text is also used by the default cell. Numeric sorting needs compare.
  final String Function(T row) value;
  final Widget Function(BuildContext context, T row)? cellBuilder;

  /// Null disables sorting for this column.
  final Comparator<T>? compare;
  final bool numeric;
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
  @override
  State<UITable<T>> createState() => _UITableState<T>();
}

class _UITableState<T> extends State<UITable<T>> {
  int _page = 0;
  int? _sort;
  bool _ascending = true;
  List<int>? _order;
  bool _keysValidated = false;
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
    }
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
      final indices = List.generate(widget.rows.length, (i) => i);
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
                Text(column.value(row), softWrap: true),
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
                        if (selectable) checkbox(widget.rows[index]),
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
          final minWidth =
              widget.columns.length * 180.0 + (selectable ? 96 : 0);
          final tableWidth = math.max(ui.width, minWidth);
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
                        columnWidth: const FlexColumnWidth(),
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
              pageContent,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${start + 1}–${math.min(start + widget.pageSize, order.length)} / ${order.length}',
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
