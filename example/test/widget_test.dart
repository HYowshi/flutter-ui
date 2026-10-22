import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';
import 'package:flutter_ui_showcase/main.dart';

void main() {
  testWidgets('showcase navigates to motion and disables animations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    expect(find.text('Flutter UI'), findsOneWidget);
    await tester.tap(find.text('Animation'));
    await tester.pumpAndSettle();
    expect(find.text('Motion & Animation'), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('small viewport opens menu without layout overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Form & Inputs'));
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra biểu mẫu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('two seed and high contrast controls update the actual theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Bảng màu'));
    await tester.pumpAndSettle();
    final before = YouthColors.of(tester.element(find.byType(ThemeEditor)));
    expect(before.brandSecondary, isNull);
    await tester.ensureVisible(find.text('Dùng thêm màu thứ hai'));
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(UISwitch, 'Dùng thêm màu thứ hai'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
    final after = YouthColors.of(tester.element(find.byType(ThemeEditor)));
    expect(after.brandSecondary, isNotNull);
    expect(
      after.scheme.secondaryContainer,
      isNot(before.scheme.secondaryContainer),
    );
    await tester.ensureVisible(find.text('Tăng tương phản chữ lên 7:1'));
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(UISwitch, 'Tăng tương phản chữ lên 7:1'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      YouthColors.of(tester.element(find.byType(ThemeEditor))).textContrast,
      7,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'mobile selection gallery changes toggle and view without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ShowcaseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(ListTile, 'Selection controls'),
        180,
        scrollable: find
            .descendant(
              of: find.byType(Drawer),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.widgetWithText(ListTile, 'Selection controls'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Lưu mục này'));
      await tester.tap(find.text('Lưu mục này'));
      await tester.pumpAndSettle();
      expect(find.text('Đã lưu'), findsOneWidget);
      await tester.ensureVisible(find.text('Lưới'));
      await tester.tap(find.text('Lưới'));
      await tester.pumpAndSettle();
      expect(find.text('Chế độ: Lưới'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'adaptive preview preserves form edits across presets and large text',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ShowcaseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Adaptive UI'));
      await tester.pumpAndSettle();
      final name = find.descendant(
        of: find.byKey(const ValueKey('adaptive-name')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(name);
      await tester.enterText(name, 'Carry across resize');
      await tester.ensureVisible(find.text('Desktop · 1080'));
      await tester.tap(find.text('Desktop · 1080'));
      await tester.pumpAndSettle();
      expect(find.text('Carry across resize'), findsOneWidget);
      final fields = find.descendant(
        of: find.byType(AdaptiveSample),
        matching: find.byType(TextFormField),
      );
      expect(
        tester.getTopLeft(fields.first).dy,
        tester.getTopLeft(fields.last).dy,
      );
      await tester.tap(find.text('Mobile · 360'));
      await tester.pumpAndSettle();
      final largeText = find.descendant(
        of: find.widgetWithText(UISwitch, 'Chữ lớn 200%'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(largeText);
      await tester.tap(largeText);
      await tester.pumpAndSettle();
      expect(find.text('Carry across resize'), findsOneWidget);
      expect(
        tester.getTopLeft(fields.last).dy,
        greaterThan(tester.getTopLeft(fields.first).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('dropdown gallery searches and applies an actual selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Dropdown menu'));
    await tester.pumpAndSettle();
    final select = find
        .widgetWithText(UISelect<String>, 'Không gian làm việc')
        .first;
    await tester.ensureVisible(select);
    await tester.tap(select);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'thiet ke');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Thiết kế hệ thống'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn đã chọn: Thiết kế hệ thống'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
