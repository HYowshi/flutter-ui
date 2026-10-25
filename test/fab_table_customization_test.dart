import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child, {bool reduced = false, double scale = 1}) =>
    MaterialApp(
      theme: YouthUI.init(primary: Colors.indigo),
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: reduced,
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  testWidgets(
    'FAB adapts label, supports keyboard and avoids duplicate Hero tags',
    (tester) async {
      var taps = 0;
      Widget content(double width) => host(
        SizedBox(
          width: width,
          child: Column(
            children: [
              UIFloatingActionButton(
                icon: Icons.add,
                tooltip: 'Create',
                label: 'Create item',
                onPressed: () => taps++,
              ),
              UIFloatingActionButton(
                icon: Icons.edit,
                tooltip: 'Edit',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(content(700));
      expect(find.text('Create item'), findsOneWidget);
      expect(
        tester
            .widgetList<FloatingActionButton>(find.byType(FloatingActionButton))
            .every((fab) => fab.heroTag == null),
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);
      await tester.pumpWidget(content(320));
      await tester.pumpAndSettle();
      expect(find.text('Create item'), findsNothing);
      expect(find.byTooltip('Create'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'FAB loading disables tap, reduced motion has no repeating frames',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          UIFloatingActionButton(
            icon: Icons.add,
            tooltip: 'Save',
            loading: true,
            onPressed: () => taps++,
          ),
          reduced: true,
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 180,
            child: UIFloatingActionButton(
              icon: Icons.add,
              tooltip: 'Create',
              extended: true,
              label: 'Very long label that must fit',
              onPressed: () {},
            ),
          ),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(FloatingActionButton)).width,
        lessThanOrEqualTo(180),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('button style merges defaults and loading blocks long press', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        UIButton(
          label: 'Export',
          loading: true,
          onPressed: () => calls++,
          onLongPress: () => calls++,
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
        ),
      ),
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.style!.minimumSize!.resolve({}), const Size(48, 48));
    expect(button.style!.shape!.resolve({}), isA<StadiumBorder>());
    await tester.longPress(find.byType(FilledButton));
    expect(calls, 0);
  });

  testWidgets(
    'table search resets page and bulk selection only affects current page',
    (tester) async {
      var query = '';
      Set<Object> selected = {'outside'};
      const rows = ['Bình', 'An', 'Dũng', 'Chi'];
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return UITable<String>(
                rows: rows,
                searchQuery: query,
                pageSize: 2,
                rowKey: (r) => r,
                selectedKeys: selected,
                showSelectAll: true,
                onSelectionChanged: (keys) => setState(() => selected = keys),
                columns: [
                  UITableColumn(
                    label: 'Name',
                    value: (r) => r,
                    compare: (a, b) => a.compareTo(b),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(selected, {'outside', 'Bình', 'An'});
      await tester.tap(find.byTooltip('Trang sau'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(selected, {'outside', ...rows});
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(selected, {'outside', 'Bình', 'An'});
      update(() => query = 'binh');
      await tester.pumpAndSettle();
      expect(find.text('Bình'), findsOneWidget);
      expect(find.text('Trang 1 / 1'), findsOneWidget);
      expect(find.text('Dũng'), findsNothing);
      update(() => query = 'bi\u0300nh');
      await tester.pumpAndSettle();
      expect(find.text('Bình'), findsOneWidget);
      update(() => query = 'no results');
      await tester.pumpAndSettle();
      expect(find.text('Không có kết quả phù hợp'), findsOneWidget);
      expect(selected, {'outside', 'Bình', 'An'});
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'table page size, error retry and narrow high scale controls work',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      int pageSize = 5;
      String? error;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return UITable<int>(
                rows: List.generate(12, (i) => i),
                columns: [
                  UITableColumn(
                    label: 'Number',
                    value: (n) => '$n',
                    minWidth: 80,
                  ),
                ],
                pageSize: pageSize,
                onPageSizeChanged: (n) => setState(() => pageSize = n),
                rowKey: (n) => n,
                onSelectionChanged: (_) {},
                showSelectAll: true,
                error: error,
                onRetry: () => setState(() => error = null),
              );
            },
          ),
          scale: 2,
        ),
      );
      await tester.ensureVisible(find.byType(UISelect<int>));
      await tester.tap(find.byType(UISelect<int>));
      await tester.pumpAndSettle();
      // Keyboard test hosts use the anchored menu, touch devices use a sheet.
      await tester.tap(find.text('10').last);
      await tester.pumpAndSettle();
      expect(pageSize, 10);
      update(() => error = 'Connection failed');
      await tester.pumpAndSettle();
      expect(find.text('Connection failed'), findsOneWidget);
      await tester.ensureVisible(find.text('Thử lại'));
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(error, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('adaptive FAB clears footer and navigation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: YouthUI.init(primary: Colors.blue),
        home: UIAdaptiveScaffold(
          title: 'Home',
          destinations: const [
            UIDestination(label: 'Home', icon: Icons.home),
            UIDestination(label: 'Settings', icon: Icons.settings),
          ],
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          actions: UIButton(label: 'Save footer', onPressed: () {}),
          floatingActionButton: UIFloatingActionButton(
            icon: Icons.add,
            tooltip: 'Create',
            onPressed: () {},
          ),
          child: const SizedBox(height: 1000, child: Text('Content')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(FloatingActionButton)).bottom,
      lessThan(tester.getRect(find.text('Save footer')).top),
    );
    expect(
      tester.getRect(find.text('Save footer')).bottom,
      lessThan(tester.getRect(find.byType(NavigationBar)).top),
    );
    expect(tester.takeException(), isNull);
  });
}
