import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Future<void> host(
  WidgetTester tester,
  Widget child, {
  double width = 1000,
  double height = 800,
  double scale = 1,
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: YouthUI.init(
        primary: Colors.indigo,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, height),
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width < 600 ? width - 32 : 320,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<UIOption<int>> options([int count = 3]) => List.generate(
  count,
  (i) => UIOption(value: i, label: 'Option $i', enabled: i != 1),
);
Finder item(String label) => find.widgetWithText(MenuItemButton, label);

void main() {
  testWidgets('desktop uses anchored themed menu and commits once', (
    tester,
  ) async {
    var calls = 0;
    int? value;
    await host(
      tester,
      UISelect<int>(
        label: 'Workspace',
        options: options(),
        initialValue: 0,
        onChanged: (v) {
          value = v;
          calls++;
        },
      ),
    );
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(item('Option 2'), findsOneWidget);
    expect(tester.getRect(item('Option 2')).width, lessThanOrEqualTo(320));
    await tester.tap(item('Option 1'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    await tester.tap(item('Option 2'));
    await tester.pumpAndSettle();
    expect(value, 2);
    expect(calls, 1);
    expect(find.byType(MenuItemButton), findsNothing);
    expect(find.text('Option 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile opens a sheet, cancels without change and selects', (
    tester,
  ) async {
    int? value;
    await host(
      tester,
      UISelect<int>(
        label: 'Workspace',
        options: options(),
        onChanged: (v) => value = v,
      ),
      width: 390,
    );
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();
    expect(value, isNull);
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    await tester.tap(item('Option 2'));
    await tester.pumpAndSettle();
    expect(value, 2);
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search supports unaccented Vietnamese and empty results', (
    tester,
  ) async {
    String? value;
    await host(
      tester,
      UISelect<String>(
        label: 'Location',
        searchable: true,
        options: const [
          UIOption(value: 'dn', label: 'Đồng Nai'),
          UIOption(value: 'hcm', label: 'Hồ Chí Minh'),
        ],
        onChanged: (v) => value = v,
      ),
    );
    await tester.tap(find.byType(UISelect<String>));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'dong nai');
    await tester.pumpAndSettle();
    expect(item('Đồng Nai'), findsOneWidget);
    expect(item('Hồ Chí Minh'), findsNothing);
    await tester.enterText(find.byType(TextField), 'no matching city');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy lựa chọn'), findsOneWidget);
    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pumpAndSettle();
    expect(item('Hồ Chí Minh'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'dong');
    await tester.pumpAndSettle();
    await tester.tap(item('Đồng Nai'));
    await tester.pumpAndSettle();
    expect(value, 'dn');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'keyboard opens, skips disabled, jumps to end of lazy list and restores focus',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      int? value;
      await host(
        tester,
        UISelect<int>(
          label: 'Workspace',
          options: options(100),
          initialValue: 0,
          focusNode: focus,
          onChanged: (v) => value = v,
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, 2);
      expect(focus.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(item('Option 99'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, 99);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNothing);
      expect(value, 99);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('legacy items preserve callbacks, validation and form reset', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    var itemCalls = 0;
    await host(
      tester,
      Form(
        key: form,
        child: UISelect<String>(
          label: 'Workspace',
          items: [
            const DropdownMenuItem(value: 'a', child: Text('Personal')),
            DropdownMenuItem(
              value: 'b',
              onTap: () => itemCalls++,
              child: const Text('Team'),
            ),
          ],
          onChanged: (_) {},
          validator: (v) => v == null ? 'Choose a workspace' : null,
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Choose a workspace'), findsOneWidget);
    await tester.tap(find.byType(UISelect<String>));
    await tester.pumpAndSettle();
    await tester.tap(item('Team'));
    await tester.pumpAndSettle();
    expect(form.currentState!.validate(), isTrue);
    expect(itemCalls, 1);
    form.currentState!.reset();
    await tester.pumpAndSettle();
    expect(find.text('Chọn một mục'), findsOneWidget);
    expect(itemCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled and empty selects do not open', (tester) async {
    await host(
      tester,
      Column(
        children: [
          UISelect<int>(
            label: 'Disabled',
            options: options(),
            enabled: false,
            onChanged: (_) {},
          ),
          UISelect<int>(label: 'Empty', onChanged: (_) {}),
        ],
      ),
    );
    for (final select in find.byType(UISelect<int>).evaluate()) {
      await tester.tap(find.byWidget(select.widget));
      await tester.pumpAndSettle();
    }
    expect(find.byType(MenuItemButton), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('1000 options are lazy and selected item is visible initially', (
    tester,
  ) async {
    await host(
      tester,
      UISelect<int>(
        label: 'Many',
        options: options(1000),
        initialValue: 900,
        onChanged: (_) {},
      ),
    );
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton).evaluate().length, lessThan(40));
    expect(item('Option 900'), findsOneWidget);
    expect(tester.getRect(item('Option 900')).top, greaterThanOrEqualTo(0));
    expect(tester.takeException(), isNull);
  });

  for (final mobile in [true, false]) {
    testWidgets(
      'long labels and text scale 200% fit ${mobile ? 'mobile' : 'desktop'}',
      (tester) async {
        await host(
          tester,
          UISelect<String>(
            label: 'Workspace',
            searchable: true,
            options: const [
              UIOption(
                value: 'a',
                label:
                    'A workspace with a longer name that needs multiple lines',
                icon: Icons.work_outline,
              ),
              UIOption(
                value: 'b',
                label: 'Another long workspace name to check wrapping and readable spacing',
              ),
            ],
            onChanged: (_) {},
          ),
          width: mobile ? 320 : 1000,
          scale: 2,
          dark: !mobile,
        );
        await tester.tap(find.byType(UISelect<String>));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final row = tester.getRect(find.byType(MenuItemButton).first);
        expect(row.left, greaterThanOrEqualTo(0));
        expect(row.right, lessThanOrEqualTo(mobile ? 320 : 1000));
      },
    );
  }

  testWidgets(
    'outside tap dismisses without selecting or activating underlying control',
    (tester) async {
      var taps = 0;
      await host(
        tester,
        Column(
          children: [
            UISelect<int>(
              label: 'Workspace',
              options: options(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 450),
            TextButton(
              onPressed: () => taps++,
              child: const Text('Outside action'),
            ),
          ],
        ),
      );
      await tester.tap(find.byType(UISelect<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Outside action'));
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNothing);
      expect(taps, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('mobile search stays usable above the keyboard with large text', (
    tester,
  ) async {
    await host(
      tester,
      UISelect<int>(
        label: 'Workspace',
        options: options(30),
        onChanged: (_) {},
      ),
      width: 390,
      height: 640,
      scale: 2,
    );
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Option 2');
    await tester.pumpAndSettle();
    expect(item('Option 2'), findsOneWidget);
    expect(
      tester.getRect(find.byType(TextField)).bottom,
      lessThanOrEqualTo(340),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('menu flips near the bottom edge and supports RTL', (
    tester,
  ) async {
    await host(
      tester,
      Directionality(
        textDirection: TextDirection.rtl,
        child: Align(
          alignment: Alignment.bottomRight,
          child: UISelect<int>(
            label: 'Workspace',
            options: options(10),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    final menu = tester.getRect(find.byType(MenuItemButton).first);
    expect(menu.top, greaterThanOrEqualTo(0));
    expect(menu.bottom, lessThanOrEqualTo(800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmounting a sheet owner does not dispatch a stale selection', (
    tester,
  ) async {
    var visible = true;
    var calls = 0;
    late StateSetter update;
    await host(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return visible
              ? UISelect<int>(
                  label: 'Workspace',
                  options: options(),
                  onChanged: (_) => calls++,
                )
              : const Text('Removed');
        },
      ),
      width: 390,
    );
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    update(() => visible = false);
    await tester.pumpAndSettle();
    await tester.tap(item('Option 2'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('popup uses room below the anchor without covering the field', (
    tester,
  ) async {
    await host(
      tester,
      Center(
        child: UISelect<int>(
          label: 'Workspace',
          initialValue: 0,
          options: options(12),
          onChanged: (_) {},
        ),
      ),
    );
    final trigger = tester.getRect(find.byType(UISelect<int>));
    await tester.tap(find.byType(UISelect<int>));
    await tester.pumpAndSettle();
    final first = tester.getRect(find.byType(MenuItemButton).first);
    expect(first.top, greaterThanOrEqualTo(trigger.bottom));
    expect(first.bottom, lessThanOrEqualTo(800));
    expect(tester.takeException(), isNull);
  });
}
