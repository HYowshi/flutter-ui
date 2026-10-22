import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(
  Widget child, {
  double width = 360,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
}) => MaterialApp(
  theme: YouthUI.init(primary: Colors.indigo),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(1600, 1000),
      textScaler: TextScaler.linear(scale),
    ),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, height: 580, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  test('one initializer configures adaptive defaults in both theme modes', () {
    const adaptive = UIAdaptiveConfig(
      compactBreakpoint: 640,
      expandedBreakpoint: 1100,
      maxContentWidth: 1000,
      minColumnWidth: 320,
    );
    final ui = YouthUI.colors(primary: Colors.green, adaptive: adaptive);
    expect(ui.light.extension<UIAdaptiveConfig>(), same(adaptive));
    expect(ui.dark.extension<UIAdaptiveConfig>(), same(adaptive));
  });

  testWidgets('grid changes column count around its content threshold', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const grid = UIGrid(children: [Text('A'), Text('B'), Text('C'), Text('D')]);
    await tester.pumpWidget(host(grid, width: 1200));
    expect(
      tester.getTopLeft(find.text('A')).dy,
      tester.getTopLeft(find.text('D')).dy,
    );
    await tester.pumpWidget(host(grid, width: 580));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('A')).dy,
      tester.getTopLeft(find.text('B')).dy,
    );
    expect(
      tester.getTopLeft(find.text('C')).dy,
      greaterThan(tester.getTopLeft(find.text('A')).dy),
    );
    await tester.pumpWidget(host(grid, width: 579));
    await tester.pumpAndSettle();
    // The compact gap is 12: two 280px columns need 572px, not 580px.
    expect(
      tester.getTopLeft(find.text('A')).dy,
      tester.getTopLeft(find.text('B')).dy,
    );
    await tester.pumpWidget(host(grid, width: 571));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('B')).dy,
      greaterThan(tester.getTopLeft(find.text('A')).dy),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'form uses local width, scales columns and preserves edits on resize',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const form = UIForm(
        children: [
          UITextField(label: 'Name'),
          UITextField(label: 'Email'),
        ],
      );
      await tester.pumpWidget(host(form));
      final fields = find.byType(TextFormField);
      expect(
        tester.getTopLeft(fields.at(1)).dy,
        greaterThan(tester.getTopLeft(fields.first).dy),
      );
      await tester.enterText(fields.first, 'Keep this edit');
      await tester.pumpWidget(host(form, width: 900));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(fields.at(1)).dy,
        tester.getTopLeft(fields.first).dy,
      );
      expect(find.text('Keep this edit'), findsOneWidget);
      await tester.pumpWidget(host(form, width: 900, scale: 2));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(fields.at(1)).dy,
        greaterThan(tester.getTopLeft(fields.first).dy),
      );
      expect(find.text('Keep this edit'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('actions stack locally and wrap on desktop', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final actions = UIActions(
      children: [
        UIButton(label: 'Save', onPressed: () {}),
        UIButton(label: 'Cancel', onPressed: () {}),
      ],
    );
    await tester.pumpWidget(host(actions));
    var buttons = find.byType(FilledButton);
    expect(tester.getRect(buttons.first).width, 360);
    expect(
      tester.getRect(buttons.last).top,
      greaterThan(tester.getRect(buttons.first).bottom),
    );
    await tester.pumpWidget(host(actions, width: 900));
    await tester.pumpAndSettle();
    buttons = find.byType(FilledButton);
    expect(tester.getRect(buttons.first).width, lessThan(360));
    expect(tester.getRect(buttons.last).top, tester.getRect(buttons.first).top);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'segmented selection falls back by measured labels and text scaling',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var selection = 'week';
      Widget group() => StatefulBuilder(
        builder: (context, setState) => UISegmentedControl<String>(
          options: const [
            UIOption(value: 'day', label: 'Daily updates'),
            UIOption(value: 'week', label: 'Weekly updates'),
            UIOption(value: 'month', label: 'Monthly updates', enabled: false),
          ],
          value: selection,
          onChanged: (v) => setState(() => selection = v),
        ),
      );
      final child = group();
      await tester.pumpWidget(host(child));
      expect(find.byType(SegmentedButton<String>), findsNothing);
      expect(find.byType(UIButton), findsNWidgets(3));
      await tester.tap(find.text('Daily updates'));
      await tester.pumpAndSettle();
      expect(selection, 'day');
      await tester.tap(find.text('Monthly updates'));
      expect(selection, 'day');
      await tester.pumpWidget(host(child, width: 900));
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
      expect(
        tester
            .widget<SegmentedButton<String>>(
              find.byType(SegmentedButton<String>),
            )
            .selected,
        {'day'},
      );
      await tester.pumpWidget(host(child, width: 600, scale: 2));
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<String>), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('button wraps full labels and accepts unbounded row width', (
    tester,
  ) async {
    const label = 'Save all the changes in your workspace';
    await tester.pumpWidget(
      host(
        const Align(
          alignment: Alignment.topLeft,
          child: UIButton(label: label),
        ),
        width: 180,
        scale: 2,
      ),
    );
    expect(
      tester.getSize(find.byType(FilledButton)).width,
      lessThanOrEqualTo(180),
    );
    expect(tester.getSize(find.byType(FilledButton)).height, greaterThan(48));
    expect(
      tester.widget<Text>(find.text(label)).overflow,
      isNot(TextOverflow.ellipsis),
    );
    await tester.pumpWidget(
      host(
        Row(
          children: [UIButton(label: 'Save', onPressed: () {})],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'mouse changes spacing while preserving touch target and semantics',
    (tester) async {
      await tester.pumpWidget(host(UIButton(label: 'Save', onPressed: () {})));
      final before = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style!
          .padding!
          .resolve({})!;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(20, 20));
      await tester.pumpAndSettle();
      final after = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style!
          .padding!
          .resolve({})!;
      expect(after.vertical, lessThan(before.vertical));
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      await mouse.removePointer();
      await tester.pumpAndSettle();
    },
  );

  for (final width in [280.0, 360.0, 768.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'page composition fits width $width and text scale $scale including RTL',
        (tester) async {
          tester.view.physicalSize = const Size(1600, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            host(
              UIPage(
                children: [
                  const UICard(
                    child: UIForm(
                      children: [
                        UITextField(label: 'Display name'),
                        UIPasswordField(),
                      ],
                    ),
                  ),
                  UICard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UIBadge(
                          label: 'A longer status label that should wrap instead of losing its meaning',
                          icon: Icons.check,
                        ),
                        const UIAlert(
                          message: 'The changes in your workspace have been saved successfully.',
                          title: 'Saved',
                        ),
                        UICheckbox(
                          label: 'Receive new updates from your personal workspace',
                          value: true,
                          onChanged: (_) {},
                        ),
                        UISwitch(
                          label: 'Enable automatic notifications in this workspace',
                          value: false,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                  UIActions(
                    children: [
                      UIButton(label: 'Save all changes', onPressed: () {}),
                      UIButton(label: 'Cancel', onPressed: () {}),
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
          final pageContent = tester.getRect(find.byType(UIActions));
          expect(pageContent.width, lessThanOrEqualTo(1120));
          expect(pageContent.right, lessThanOrEqualTo(width));
        },
      );
    }
  }
}
