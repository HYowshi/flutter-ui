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
      find.widgetWithText(SwitchListTile, 'Dùng thêm màu thứ hai'),
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
      find.widgetWithText(SwitchListTile, 'Tăng tương phản chữ lên 7:1'),
    );
    await tester.pumpAndSettle();
    expect(
      YouthColors.of(tester.element(find.byType(ThemeEditor))).textContrast,
      7,
    );
    expect(tester.takeException(), isNull);
  });
}
