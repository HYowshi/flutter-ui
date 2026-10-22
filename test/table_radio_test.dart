import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

final theme = YouthUI.init(primary: Colors.blue);
Widget host(
  Widget child, {
  double width = 900,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
}) => MaterialApp(
  theme: theme,
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

List<UITableColumn<int>> columns() => [
  UITableColumn<int>(
    label: 'Number',
    value: (r) => 'N$r',
    compare: (a, b) => a.compareTo(b),
    numeric: true,
  ),
];

void main() {
  testWidgets(
    'radio chooses only through control and skips disabled options on keyboard',
    (tester) async {
      int? selected = 1;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => UIRadioGroup<int>(
              value: selected,
              onChanged: (v) => setState(() => selected = v),
              options: const [
                UIOption(value: 1, label: 'One'),
                UIOption(value: 2, label: 'Disabled', enabled: false),
                UIOption(value: 3, label: 'Three'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Three'));
      expect(selected, 1);
      await tester.tap(find.byType(Radio<int>).last);
      await tester.pumpAndSettle();
      expect(selected, 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(selected, 1);
      await tester.tap(find.byType(Radio<int>).at(1));
      expect(selected, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('disabled radio group never emits changes', (tester) async {
    await tester.pumpWidget(
      host(
        const UIRadioGroup<int>(
          value: 1,
          onChanged: null,
          options: [
            UIOption(value: 1, label: 'One'),
            UIOption(value: 2, label: 'Two'),
          ],
        ),
      ),
    );
    expect(
      tester
          .widgetList<Radio<int>>(find.byType(Radio<int>))
          .every((r) => r.enabled == false),
      isTrue,
    );
    await tester.tap(find.byType(Radio<int>).last);
    expect(tester.takeException(), isNull);
  });
  testWidgets('radio groups are independent and expose labeled semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Column(
          children: [
            UIRadioGroup<int>(
              label: 'First',
              value: 1,
              onChanged: (_) {},
              options: const [UIOption(value: 1, label: 'First One')],
            ),
            UIRadioGroup<int>(
              label: 'Second',
              value: 1,
              onChanged: (_) {},
              options: const [UIOption(value: 1, label: 'Second One')],
            ),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('First One'), findsOneWidget);
    expect(find.bySemanticsLabel('Second One'), findsOneWidget);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
  testWidgets('table sorts both ways and pages without mutating input', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rows = [3, 1, 2, 4];
    await tester.pumpWidget(
      host(UITable<int>(rows: rows, columns: columns(), pageSize: 2)),
    );
    expect(find.text('N3'), findsOneWidget);
    expect(find.text('N2'), findsNothing);
    await tester.tap(find.text('Number'));
    await tester.pumpAndSettle();
    expect(find.text('N2'), findsOneWidget);
    expect(find.text('N3'), findsNothing);
    await tester.tap(find.byTooltip('Trang sau'));
    await tester.pumpAndSettle();
    expect(find.text('N3'), findsOneWidget);
    expect(find.text('Trang 2 / 2'), findsOneWidget);
    await tester.tap(find.text('Number'));
    await tester.pumpAndSettle();
    expect(find.text('N4'), findsOneWidget);
    expect(find.text('Trang 1 / 2'), findsOneWidget);
    expect(rows, [3, 1, 2, 4]);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'selection rebuild preserves sort/page with inline column declarations',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Set<Object> selected = {};
      final rows = [4, 3, 2, 1];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => UITable<int>(
              rows: rows,
              columns: columns(),
              pageSize: 2,
              rowKey: (r) => r,
              selectedKeys: selected,
              onSelectionChanged: (keys) => setState(() => selected = keys),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Number'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Trang sau'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(selected, {3});
      expect(find.text('Trang 2 / 2'), findsOneWidget);
      expect(find.text('N3'), findsOneWidget);
      expect(find.text('N1'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('table builds only page cells and supports custom content', (
    tester,
  ) async {
    var built = 0;
    await tester.pumpWidget(
      host(
        UITable<int>(
          rows: List.generate(1000, (i) => i),
          pageSize: 5,
          columns: [
            UITableColumn(
              label: 'Name',
              value: (r) => '$r',
              cellBuilder: (context, row) {
                built++;
                return Text('Custom $row');
              },
            ),
          ],
        ),
      ),
    );
    expect(built, 5);
    expect(find.text('Custom 5'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('empty/loading and reduced row counts are safe', (tester) async {
    await tester.pumpWidget(
      host(
        UITable<int>(
          rows: const [],
          columns: columns(),
          empty: const Text('Empty custom'),
        ),
      ),
    );
    expect(find.text('Empty custom'), findsOneWidget);
    await tester.pumpWidget(
      host(UITable<int>(rows: const [], columns: columns(), loading: true)),
    );
    expect(find.text('Đang tải dữ liệu…'), findsOneWidget);
    await tester.pumpWidget(
      host(
        UITable<int>(rows: const [1, 2, 3], columns: columns(), pageSize: 1),
      ),
    );
    await tester.tap(find.byTooltip('Trang sau'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      host(UITable<int>(rows: const [1], columns: columns(), pageSize: 1)),
    );
    expect(find.text('Trang 1 / 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [280.0, 640.0, 1280.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('table and radio fit width $width scale $scale in RTL', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          host(
            Column(
              children: [
                UIRadioGroup<int>(
                  direction: Axis.horizontal,
                  value: 1,
                  onChanged: (_) {},
                  options: const [
                    UIOption(
                      value: 1,
                      label: 'A long radio label that needs to wrap on narrow screens',
                    ),
                    UIOption(value: 2, label: 'Another option'),
                  ],
                ),
                UITable<int>(
                  rows: const [1, 2],
                  columns: [
                    UITableColumn(
                      label: 'A longer column heading',
                      value: (r) =>
                          'Long text for this row with multiple words',
                      compare: (a, b) => a.compareTo(b),
                    ),
                    UITableColumn(label: 'Value', value: (r) => '$r'),
                  ],
                ),
              ],
            ),
            width: width,
            scale: scale,
            direction: TextDirection.rtl,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byType(DataTable),
          width >= 600 && scale < 1.5 ? findsOneWidget : findsNothing,
        );
        expect(tester.binding.hasScheduledFrame, isFalse);
      });
    }
  }
}
