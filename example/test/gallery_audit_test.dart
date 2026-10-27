import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_showcase/main.dart';

void main() {
  for (final configuration in [(320.0, 2.0), (1440.0, 1.0)]) {
    testWidgets(
      'all galleries fit width ${configuration.$1} text ${configuration.$2}',
      (tester) async {
        tester.view.physicalSize = Size(configuration.$1, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = configuration.$2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(const ShowcaseApp());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Overview');
        for (final label in [
          'Bảng màu',
          'Buttons',
          'Form & Inputs',
          'Cards & Badges',
          'Thông báo',
          'Animation',
          'Bắt đầu sử dụng',
          'Selection controls',
          'Adaptive UI',
          'Dropdown menu',
          'Images',
          'Wireframe',
          'Table',
          'Radio',
          'Trạng thái màn hình',
          'Dialog & Sheet',
          'Date Picker',
          'Kết nối API',
        ]) {
          final mobile = configuration.$1 < 1000;
          if (mobile) {
            await tester.tap(find.byTooltip('Open navigation menu'));
            await tester.pumpAndSettle();
          }
          final target = find.widgetWithText(ListTile, label);
          await tester.scrollUntilVisible(
            target,
            200,
            scrollable: find
                .descendant(
                  of: mobile
                      ? find.byType(Drawer)
                      : find.byType(Scaffold).first,
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await Scrollable.ensureVisible(tester.element(target), alignment: .5);
          await tester.pumpAndSettle();
          await tester.tap(target);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: label);
          // Lay out lower content too; floating controls must not obscure scrolling.
          final bodyScroll = tester.widget<SingleChildScrollView>(
            find.byKey(const ValueKey('studio-content-scroll')),
          );
          final controller = bodyScroll.controller!;
          controller.jumpTo(
            450.0.clamp(0, controller.position.maxScrollExtent),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$label scrolled');
        }
      },
    );
  }
}
