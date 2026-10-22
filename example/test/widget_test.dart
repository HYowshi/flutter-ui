import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';
import 'package:flutter_ui_showcase/main.dart';

void main() {
  testWidgets('input gallery simulates failure and retains values for retry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: YouthUI.init(primary: Colors.blue),
        home: const Scaffold(body: SingleChildScrollView(child: InputDemo())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(UISelect<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Lỗi kết nối'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'demo-password');
    await tester.ensureVisible(find.text('Kiểm tra biểu mẫu'));
    await tester.tap(find.text('Kiểm tra biểu mẫu'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(
      find.text('Không thể kết nối. Dữ liệu vẫn được giữ để bạn thử lại.'),
      findsOneWidget,
    );
    expect(find.text('Số lần gửi mô phỏng: 1'), findsOneWidget);
    expect(find.text('demo@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback gallery undo restores the actual demo item', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: YouthUI.init(primary: Colors.blue),
        home: const Scaffold(
          body: SingleChildScrollView(child: FeedbackDemo()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lưu trữ và Hoàn tác'));
    await tester.tap(find.text('Lưu trữ và Hoàn tác'));
    await tester.pumpAndSettle();
    expect(find.text('Mục demo đã được lưu trữ'), findsOneWidget);
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    expect(find.text('Tài liệu demo đang hiển thị'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('table and radio galleries work on desktop and mobile', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [1440.0, 390.0]) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const ShowcaseApp());
      await tester.pumpAndSettle();
      for (final label in ['Table', 'Radio']) {
        if (width < 1000) {
          await tester.tap(find.byTooltip('Open navigation menu'));
          await tester.pumpAndSettle();
        }
        await tester.scrollUntilVisible(
          find.widgetWithText(ListTile, label),
          200,
          scrollable: find
              .descendant(
                of: width < 1000
                    ? find.byType(Drawer)
                    : find.byType(Scaffold).first,
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.widgetWithText(ListTile, label));
        await tester.pumpAndSettle();
        if (label == 'Table') {
          final sort = find.text(width < 1000 ? 'Sắp xếp Điểm' : 'Điểm');
          await tester.ensureVisible(sort);
          await tester.tap(sort);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byType(Checkbox).first);
          await tester.tap(find.byType(Checkbox).first);
          await tester.pumpAndSettle();
          expect(find.text('Đã chọn: 1 dòng'), findsOneWidget);
        } else {
          await tester.ensureVisible(find.byType(Radio<String>).first);
          await tester.tap(find.byType(Radio<String>).first);
          await tester.pumpAndSettle();
          expect(find.text('Lựa chọn hiện tại: daily'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      }
    }
  });
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
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
      // A readable form stays in one column; supporting content uses the space beside it.
      expect(
        tester.getTopLeft(fields.last).dy,
        greaterThan(tester.getTopLeft(fields.first).dy),
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
  testWidgets(
    'image and wireframe galleries load locally and adapt on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ShowcaseApp());
      await tester.pumpAndSettle();
      for (final label in ['Images', 'Wireframe']) {
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.widgetWithText(ListTile, label),
          180,
          scrollable: find
              .descendant(
                of: find.byType(Drawer),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.widgetWithText(ListTile, label));
        await tester.pumpAndSettle();
        if (label == 'Images') {
          expect(find.byType(UIImage), findsNWidgets(9));
          expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
          final sourceSwitch = find.descendant(
            of: find.widgetWithText(UISwitch, 'Nguồn chính không có sẵn'),
            matching: find.byType(Switch),
          );
          await tester.ensureVisible(sourceSwitch);
          await tester.tap(sourceSwitch);
          await tester.pumpAndSettle();
          expect(tester.widget<Switch>(sourceSwitch).value, isFalse);
        } else {
          expect(find.byType(UIWireframe), findsWidgets);
          await tester.ensureVisible(find.text('Phân tích dữ liệu'));
          await tester.tap(find.text('Phân tích dữ liệu'));
          await tester.pumpAndSettle();
          expect(find.textContaining('article · high'), findsOneWidget);
          await tester.enterText(find.byType(TextFormField).last, '{broken');
          await tester.tap(find.text('Phân tích dữ liệu'));
          await tester.pumpAndSettle();
          expect(find.textContaining('JSON chưa hợp lệ.'), findsOneWidget);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'theme switching keeps selected gallery and repeated requests settle',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ShowcaseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Form & Inputs'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'stable@example.com',
      );
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byTooltip('Đổi sáng / tối'));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();
      expect(find.text('stable@example.com'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(InputDemo))).brightness,
        Brightness.dark,
      );
      expect(find.byType(RawImage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
