import 'package:flutter/material.dart';

import 'dart:ui' show Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

const items = [
  UINavigationItem(
    id: 'home',
    label: 'Tổng quan',
    icon: Icons.home_outlined,
    group: 'Workspace',
  ),
  UINavigationItem(
    id: 'projects',
    label: 'Dự án',
    icon: Icons.folder_outlined,
    badge: '8',
    group: 'Workspace',
  ),
  UINavigationItem(
    id: 'messages',
    label: 'Tin nhắn',
    icon: Icons.chat_outlined,
    badge: '12',
    group: 'Workspace',
  ),
  UINavigationItem(
    id: 'settings',
    label: 'Cài đặt',
    icon: Icons.settings_outlined,
    group: 'Quản lý',
    enabled: false,
  ),
];

Widget host(
  Widget child, {
  double width = 1200,
  double scale = 1,
  bool dark = false,
  bool rtl = false,
}) => UIApp(
  primary: Colors.indigo,
  reduceMotion: true,
  initialThemeMode: dark ? ThemeMode.dark : ThemeMode.light,
  home: MediaQuery(
    data: MediaQueryData(
      size: Size(width, 640),
      textScaler: TextScaler.linear(scale),
      disableAnimations: true,
    ),
    child: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(width: width, height: 640, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'sidebar supports subtitle-only header and long scrollable content',
    (tester) async {
      final many = List.generate(
        50,
        (i) => UINavigationItem(label: 'Mục $i', icon: Icons.folder_outlined),
      );
      int? selected;
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 240,
            child: UISidebar(
              items: many,
              selectedIndex: -1,
              onSelected: (i) => selected = i,
              subtitle: 'Workspace',
              footer: const Text('Footer'),
            ),
          ),
          width: 264,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byTooltip('Mục 49'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(UISidebar),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byTooltip('Mục 49'));
      await tester.pumpAndSettle();
      expect(selected, 49);
      expect(tester.takeException(), isNull);
    },
  );
  for (final variant in UISidebarVariant.values) {
    testWidgets(
      'sidebar ${variant.name} supports rail, large text, RTL and disabled items',
      (tester) async {
        final semantics = tester.ensureSemantics();
        int? selected;
        for (final collapsed in [false, true]) {
          await tester.pumpWidget(
            host(
              UISidebar(
                items: items,
                selectedIndex: 0,
                onSelected: (index) => selected = index,
                title: 'Không gian sáng tạo',
                subtitle: 'Đội thiết kế',
                variant: variant,
                collapsed: collapsed,
                footer: collapsed
                    ? const Icon(Icons.person_outline)
                    : const Text('Tài khoản'),
              ),
              width: 320,
              scale: 2,
              dark: true,
              rtl: true,
            ),
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byTooltip('Dự án · 8'));
          await tester.tap(find.byTooltip('Dự án · 8'));
          await tester.pumpAndSettle();
          expect(selected, 1);
          selected = null;
          await tester.ensureVisible(find.byTooltip('Cài đặt'));
          await tester.tap(find.byTooltip('Cài đặt'));
          await tester.pumpAndSettle();
          expect(selected, isNull);
          final node = tester.getSemantics(find.bySemanticsLabel('Tổng quan'));
          expect(node.flagsCollection.isSelected, Tristate.isTrue);
          expect(tester.takeException(), isNull);
          expect(tester.binding.hasScheduledFrame, isFalse);
        }
        semantics.dispose();
      },
    );
  }

  for (final variant in UINavbarVariant.values) {
    testWidgets(
      'navbar ${variant.name} selects on desktop and opens bounded mobile menu',
      (tester) async {
        int? selected;
        Widget content(double width, double scale) => host(
          UINavbar(
            items: items,
            selectedIndex: 0,
            onSelected: (index) => selected = index,
            title: 'Forma Studio',
            variant: variant,
            leading: const Icon(Icons.layers_outlined),
            trailing: const Icon(Icons.person_outline),
          ),
          width: width,
          scale: scale,
          rtl: true,
          dark: true,
        );
        await tester.pumpWidget(content(1100, 1));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Dự án · 8'));
        expect(selected, 1);
        selected = null;
        await tester.pumpWidget(content(320, 2));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Mở menu điều hướng'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Tin nhắn · 12'));
        await tester.tap(find.byTooltip('Tin nhắn · 12'));
        await tester.pumpAndSettle();
        expect(selected, 2);
        expect(find.byType(UISidebar), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'shell keeps edits and focus across navigation layouts and resizing',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      Widget content(double width, UINavigationLayout layout) => host(
        UINavigationScaffold(
          items: items,
          selectedIndex: 0,
          onSelected: (_) {},
          title: 'Forma',
          layout: layout,
          child: UIPage(
            children: [UITextField(label: 'Bản nháp', focusNode: focus)],
          ),
        ),
        width: width,
      );
      await tester.pumpWidget(content(1200, UINavigationLayout.adaptive));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Keep draft');
      final state = tester.state(find.byType(TextFormField));
      for (final entry in [
        (390.0, UINavigationLayout.adaptive),
        (900.0, UINavigationLayout.sidebar),
        (1200.0, UINavigationLayout.navbar),
        (1200.0, UINavigationLayout.adaptive),
      ]) {
        await tester.pumpWidget(content(entry.$1, entry.$2));
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(TextFormField)), same(state));
        expect(find.text('Keep draft'), findsOneWidget);
        expect(focus.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'menu rejects a stale destination after reordering and handles disposal',
    (tester) async {
      var current = items;
      int? selected;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, setState) {
              update = setState;
              return UINavbar(
                items: current,
                selectedIndex: 0,
                onSelected: (i) => selected = i,
              );
            },
          ),
          width: 320,
        ),
      );
      await tester.tap(find.byTooltip('Mở menu điều hướng'));
      await tester.pumpAndSettle();
      update(() => current = [items[0], items[2], items[1], items[3]]);
      await tester.pump();
      await tester.tap(find.byTooltip('Dự án · 8'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
      await tester.tap(find.byTooltip('Mở menu điều hướng'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('navigation supports keyboard focus and activation', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      host(
        UISidebar(
          items: items,
          selectedIndex: -1,
          onSelected: (i) => selected = i,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 0);
    expect(tester.takeException(), isNull);
  });
}
