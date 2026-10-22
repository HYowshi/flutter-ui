import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child) => MaterialApp(
  theme: YouthUI.init(primary: Colors.indigo),
  home: Scaffold(
    body: Center(child: SizedBox(width: 500, child: child)),
  ),
);

void main() {
  for (final switchControl in [false, true]) {
    testWidgets(
      '${switchControl ? 'switch' : 'checkbox'} confines hit target and hover to control',
      (tester) async {
        var calls = 0;
        final focus = FocusNode();
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          host(
            switchControl
                ? UISwitch(
                    label: 'Receive updates',
                    value: false,
                    focusNode: focus,
                    onChanged: (_) => calls++,
                  )
                : UICheckbox(
                    label: 'Receive updates',
                    value: false,
                    focusNode: focus,
                    onChanged: (_) => calls++,
                  ),
          ),
        );
        final control = find.byType(switchControl ? Switch : Checkbox);
        final rect = tester.getRect(control);
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.width, lessThanOrEqualTo(60));
        expect(find.byType(CheckboxListTile), findsNothing);
        expect(find.byType(SwitchListTile), findsNothing);
        await tester.tap(find.text('Receive updates'));
        await tester.tapAt(Offset(rect.right + 300, rect.center.dy));
        expect(calls, 0);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: rect.center);
        await tester.pumpAndSettle();
        await mouse.moveTo(Offset(rect.right + 300, rect.center.dy));
        await tester.pumpAndSettle();
        expect(calls, 0);
        await mouse.removePointer();
        await tester.tap(control);
        expect(calls, 1);
        focus.requestFocus();
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(calls, 2);
        expect(tester.getSemantics(control).label, contains('Receive updates'));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'control semantics stay separate from neighboring content in cards',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          UICard(
            child: Column(
              children: [
                const Text('Notification preferences'),
                UIToggleButton(label: 'Daily', value: true, onChanged: (_) {}),
                UICheckbox(
                  label: 'Email updates',
                  value: true,
                  onChanged: (_) {},
                ),
                UISwitch(
                  label: 'Push updates',
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.getSemantics(find.byType(Checkbox)).label, 'Email updates');
      expect(tester.getSemantics(find.byType(Switch)).label, 'Push updates');
      expect(tester.getSemantics(find.byType(Checkbox)).childrenCount, 0);
      semantics.dispose();
    },
  );

  testWidgets('toggle persists selected state and disabled blocks callbacks', (
    tester,
  ) async {
    var selected = false;
    var calls = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => UIToggleButton(
            label: 'Save',
            value: selected,
            onChanged: (v) => setState(() {
              selected = v;
              calls++;
            }),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
    expect(tester.widget<UIButton>(find.byType(UIButton)).selected, isTrue);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(selected, isFalse);
    expect(calls, 2);
    await tester.pumpWidget(
      host(const UIToggleButton(label: 'Save', value: true, onChanged: null)),
    );
    await tester.tap(find.text('Save'));
    expect(calls, 2);
  });

  testWidgets(
    'segmented control chooses one option and honors disabled options',
    (tester) async {
      var value = 'list';
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => UISegmentedControl<String>(
              options: const [
                UIOption(value: 'list', label: 'List'),
                UIOption(value: 'grid', label: 'Grid'),
                UIOption(value: 'locked', label: 'Locked', enabled: false),
              ],
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(value, 'grid');
      expect(
        tester
            .widget<SegmentedButton<String>>(
              find.byType(SegmentedButton<String>),
            )
            .selected,
        {'grid'},
      );
      await tester.tap(find.text('Locked'));
      await tester.pumpAndSettle();
      expect(value, 'grid');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unlabelled and disabled controls fit a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            UICheckbox(value: true, onChanged: null),
            UISwitch(value: true, onChanged: null),
            UICheckbox(
              label: 'A long label that wraps within the available space on mobile',
              value: false,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
