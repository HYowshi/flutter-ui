import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_showcase/navigation_demo.dart';
import 'package:flutter_ui_showcase/recipes/navigation_recipe.dart';
import 'package:youth_ui/youth_ui.dart';

void main() {
  testWidgets(
    'gallery switches all sidebar/navbar styles and keeps independent mobile selection',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const UIApp(
          primary: Colors.indigo,
          reduceMotion: true,
          home: Scaffold(body: UIPage(children: [NavigationDemo()])),
        ),
      );
      await tester.pumpAndSettle();
      for (final variant in UISidebarVariant.values) {
        final tile = find
            .widgetWithText(InkWell, sidebarNames[variant.index])
            .first;
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(
          tester.widget<UISidebar>(find.byType(UISidebar)).variant,
          variant,
        );
        expect(tester.takeException(), isNull);
      }
      await tester.ensureVisible(find.byType(UISwitch));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(
        tester.widget<UISidebar>(find.byType(UISidebar)).collapsed,
        isTrue,
      );
      for (final variant in UIMobileNavbarVariant.values) {
        final tile = find
            .widgetWithText(InkWell, navbarNames[variant.index])
            .last;
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(
          tester.widget<UIMobileNavbar>(find.byType(UIMobileNavbar)).variant,
          variant,
        );
      }
      final sidebarHome = find.descendant(
        of: find.byType(UISidebar),
        matching: find.byTooltip('Tổng quan'),
      );
      await tester.ensureVisible(sidebarHome);
      await tester.tap(sidebarHome);
      await tester.pumpAndSettle();
      expect(tester.widget<UISidebar>(find.byType(UISidebar)).selectedIndex, 0);
      expect(
        tester
            .widget<UIMobileNavbar>(find.byType(UIMobileNavbar))
            .selectedIndex,
        0,
      );
      final mobileHome = find.descendant(
        of: find.byType(UIMobileNavbar),
        matching: find.byTooltip('Trang chủ'),
      );
      await tester.ensureVisible(mobileHome);
      for (var i = 0; i < 3; i++) {
        await tester.tap(mobileHome);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      expect(
        find.text('Tab đang mở · app có thể cuộn về đầu trang'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'executable recipe selects via bottom navigation and switches theme',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const UIApp(
          primary: Colors.indigo,
          reduceMotion: true,
          home: NavigationRecipe(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Dự án · 8'));
      await tester.pumpAndSettle();
      expect(find.text('WORKSPACE / DỰ ÁN'), findsOneWidget);
      await tester.tap(find.byTooltip('Đổi sáng / tối'));
      await tester.pumpAndSettle();
      expect(find.text('WORKSPACE / DỰ ÁN'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
