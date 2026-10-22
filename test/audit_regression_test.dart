import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child) => MaterialApp(
  theme: YouthUI.init(primary: Colors.indigo),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets(
    'clearAll resets mixed native queue without stranding helper notices',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (c) {
              context = c;
              return const Text('Ready');
            },
          ),
        ),
      );
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('External'), persist: true),
      );
      await tester.pumpAndSettle();
      UINotice.show(context, message: 'Discard this helper', persistent: true);
      UINotice.clearAll(context);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      UINotice.show(
        context,
        message: 'Fresh after clearing all',
        persistent: true,
      );
      await tester.pumpAndSettle();
      expect(find.text('Fresh after clearing all'), findsOneWidget);
      UINotice.clearAll(context);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'clearing helper notices never closes an unrelated current snackbar',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (c) {
              context = c;
              return const Text('Ready');
            },
          ),
        ),
      );
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('External'), persist: true),
      );
      await tester.pumpAndSettle();
      UINotice.show(context, message: 'Cancelled helper', persistent: true);
      UINotice.clear(context);
      await tester.pumpAndSettle();
      expect(find.text('External'), findsOneWidget);
      expect(tester.takeException(), isNull);
      UINotice.show(context, message: 'Fresh helper', persistent: true);
      messenger.hideCurrentSnackBar();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.text('Cancelled helper'), findsNothing);
      expect(find.text('Fresh helper'), findsOneWidget);
      UINotice.clear(context);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('new form identity ignores old backend failure', (tester) async {
    final controller = UIFormController();
    final firstKey = GlobalKey<FormState>();
    final secondKey = GlobalKey<FormState>();
    final request = Completer<void>();
    Widget form(GlobalKey<FormState> key) => host(
      UIForm(
        controller: controller,
        formKey: key,
        onSubmit: () => request.future,
        children: const [UITextField(name: 'name', label: 'Name')],
      ),
    );
    await tester.pumpWidget(form(firstKey));
    final pending = controller.submit();
    await tester.pump();
    await tester.pumpWidget(form(secondKey));
    request.completeError(
      const UIFormException(fieldErrors: {'name': 'Old record error'}),
    );
    expect(await pending, isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Old record error'), findsNothing);
    expect(controller.isSubmitting, isFalse);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('table paging reuses row-key validation for unchanged dataset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var keyCalls = 0;
    final rows = List.generate(10000, (i) => i);
    await tester.pumpWidget(
      host(
        UITable<int>(
          rows: rows,
          rowKey: (row) {
            keyCalls++;
            return row;
          },
          columns: [UITableColumn<int>(label: 'Number', value: (v) => '$v')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = keyCalls;
    await tester.tap(find.byTooltip('Trang sau'));
    await tester.pumpAndSettle();
    expect(keyCalls - before, lessThan(100));
    expect(find.text('Trang 2 / 1000'), findsOneWidget);
    await tester.pumpWidget(
      host(
        UITable<int>(
          rows: const [1, 1],
          rowKey: (row) => row,
          columns: [UITableColumn<int>(label: 'Number', value: (v) => '$v')],
        ),
      ),
    );
    expect(tester.takeException(), isA<ArgumentError>());
  });

  testWidgets('notice survives desktop to narrow viewport and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            context = c;
            return const Text('Ready');
          },
        ),
      ),
    );
    UINotice.show(
      context,
      message: 'A persistent notification with an action that wraps.',
      actionLabel: 'Restore this item',
      onAction: () {},
    );
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(280, 900);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(SnackBar)).right, lessThanOrEqualTo(280));
    UINotice.clear(context);
    await tester.pumpAndSettle();
  });
}
