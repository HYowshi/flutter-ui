import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

const destinations = [
  UINavigationItem(id: 'home', label: 'Trang chủ', icon: Icons.home_outlined),
  UINavigationItem(id: 'search', label: 'Khám phá', icon: Icons.search_rounded),
  UINavigationItem(
    id: 'inbox',
    label: 'Tin nhắn',
    icon: Icons.chat_outlined,
    badge: '12',
  ),
  UINavigationItem(
    id: 'profile',
    label: 'Tài khoản',
    icon: Icons.person_outline,
  ),
];

Widget host(
  Widget bar, {
  double width = 390,
  double scale = 1,
  bool rtl = false,
  EdgeInsets padding = EdgeInsets.zero,
  double keyboard = 0,
  bool reducedMotion = true,
}) => UIApp(
  primary: Colors.indigo,
  reduceMotion: reducedMotion,
  initialThemeMode: ThemeMode.dark,
  home: MediaQuery(
    data: MediaQueryData(
      size: Size(width, 800),
      textScaler: TextScaler.linear(scale),
      padding: padding,
      viewPadding: padding,
      viewInsets: EdgeInsets.only(bottom: keyboard),
      disableAnimations: reducedMotion,
    ),
    child: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          height: 800,
          child: Scaffold(
            body: const Text('Content'),
            bottomNavigationBar: bar,
          ),
        ),
      ),
    ),
  ),
);

void main() {
  for (final variant in UIMobileNavbarVariant.values) {
    testWidgets(
      'mobile ${variant.name} supports tap, safe area, text scale and RTL',
      (tester) async {
        int? selected;
        var actions = 0;
        for (final config in [
          (390.0, 1.0, false),
          (320.0, 2.0, true),
          (240.0, 2.0, false),
        ]) {
          await tester.pumpWidget(
            host(
              UIMobileNavbar(
                items: destinations,
                selectedIndex: 0,
                onSelected: (i) => selected = i,
                onAction: () => actions++,
                variant: variant,
              ),
              width: config.$1,
              scale: config.$2,
              rtl: config.$3,
              padding: const EdgeInsets.only(bottom: 24),
            ),
          );
          await tester.pumpAndSettle();
          final home = find.byTooltip('Trang chủ');
          await tester.tap(home);
          await tester.pumpAndSettle();
          expect(selected, 0);
          expect(tester.getSize(home).width, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);
          expect(tester.binding.hasScheduledFrame, isFalse);
        }
        expect(actions, 0);
      },
    );
  }

  testWidgets(
    'raised center action has a fully hittable top and does not select a page',
    (tester) async {
      var actions = 0, selections = 0;
      await tester.pumpWidget(
        host(
          UIMobileNavbar(
            items: destinations,
            selectedIndex: 1,
            variant: UIMobileNavbarVariant.centerAction,
            onSelected: (_) => selections++,
            onAction: () => actions++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final button = find.byType(FloatingActionButton);
      final rect = tester.getRect(button);
      await tester.tapAt(Offset(rect.center.dx, rect.top + 5));
      await tester.pumpAndSettle();
      expect(actions, 1);
      expect(selections, 0);
      expect(rect.center.dx, closeTo(390 / 2, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'extra destinations open More and selected hidden route stays represented',
    (tester) async {
      final many = [
        ...destinations,
        for (var i = 4; i < 9; i++)
          UINavigationItem(
            id: 'extra$i',
            label: 'Trang $i',
            icon: Icons.folder_outlined,
          ),
      ];
      int? selected;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          UIMobileNavbar(
            items: many,
            selectedIndex: 7,
            onSelected: (i) => selected = i,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Thêm'))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      await tester.tap(find.byTooltip('Thêm'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Trang 6'));
      await tester.tap(find.byTooltip('Trang 6'));
      await tester.pumpAndSettle();
      expect(selected, 6);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets(
    'disabled destination and disabled center action do not dispatch',
    (tester) async {
      var count = 0;
      await tester.pumpWidget(
        host(
          UIMobileNavbar(
            items: const [
              UINavigationItem(label: 'Home', icon: Icons.home_outlined),
              UINavigationItem(
                label: 'Locked',
                icon: Icons.lock_outline,
                enabled: false,
              ),
            ],
            selectedIndex: 0,
            onSelected: (_) => count++,
            variant: UIMobileNavbarVariant.centerAction,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Locked'));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(count, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'horizontal notch padding and keyboard hide/reappear are respected',
    (tester) async {
      Widget content(double keyboard) => host(
        UINavbar.mobile(
          items: destinations,
          selectedIndex: 0,
          onSelected: (_) {},
          variant: UIMobileNavbarVariant.floating,
        ),
        padding: const EdgeInsets.fromLTRB(30, 0, 34, 24),
        keyboard: keyboard,
      );
      await tester.pumpWidget(content(0));
      await tester.pumpAndSettle();
      for (final tip in [
        'Trang chủ',
        'Khám phá',
        'Tin nhắn · 12',
        'Tài khoản',
      ]) {
        final target = find.byTooltip(tip);
        if (target.evaluate().isEmpty) continue;
        expect(tester.getTopLeft(target).dx, greaterThanOrEqualTo(30));
        expect(tester.getBottomRight(target).dx, lessThanOrEqualTo(390 - 34));
      }
      await tester.pumpWidget(content(240));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Trang chủ'), findsNothing);
      await tester.pumpWidget(content(0));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Trang chủ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('More ignores reordered stale choices and disposes safely', (
    tester,
  ) async {
    var items = [
      ...destinations,
      const UINavigationItem(
        id: 'last',
        label: 'Last',
        icon: Icons.folder_outlined,
      ),
      const UINavigationItem(
        id: 'other',
        label: 'Other',
        icon: Icons.folder_outlined,
      ),
    ];
    late StateSetter update;
    int? chosen;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, state) {
            update = state;
            return UIMobileNavbar(
              items: items,
              selectedIndex: 0,
              onSelected: (i) => chosen = i,
            );
          },
        ),
      ),
    );
    await tester.tap(find.byTooltip('Thêm'));
    await tester.pumpAndSettle();
    update(() => items = [...destinations, items[5], items[4]]);
    await tester.pump();
    await tester.tap(find.byTooltip('Last'));
    await tester.pumpAndSettle();
    expect(chosen, isNull);
    await tester.tap(find.byTooltip('Thêm'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reselect is separate and absent callback preserves existing behavior',
    (tester) async {
      final selected = <int>[], reselected = <int>[];
      Widget content(bool intercept) => host(
        UINavbar.mobile(
          items: destinations,
          selectedIndex: 0,
          onSelected: selected.add,
          onReselected: intercept ? reselected.add : null,
        ),
      );
      await tester.pumpWidget(content(true));
      await tester.tap(find.byTooltip('Trang chủ'));
      await tester.tap(find.byTooltip('Khám phá'));
      expect(reselected, [0]);
      expect(selected, [1]);
      await tester.pumpWidget(content(false));
      await tester.tap(find.byTooltip('Trang chủ'));
      expect(selected, [1, 0]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('More can reselect the current hidden destination', (
    tester,
  ) async {
    int? reselected;
    final items = [
      ...destinations,
      const UINavigationItem(
        id: 'extra',
        label: 'Extra',
        icon: Icons.folder_outlined,
      ),
    ];
    await tester.pumpWidget(
      host(
        UIMobileNavbar(
          items: items,
          selectedIndex: 4,
          onSelected: (_) => fail('Unexpected navigation'),
          onReselected: (i) => reselected = i,
        ),
        width: 240,
      ),
    );
    await tester.tap(find.byTooltip('Thêm'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Extra'));
    await tester.tap(find.byTooltip('Extra'));
    await tester.pumpAndSettle();
    expect(reselected, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('center action moves into More when the bar is too narrow', (
    tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      host(
        UIMobileNavbar(
          items: destinations,
          selectedIndex: 0,
          onSelected: (_) => fail('Unexpected navigation'),
          variant: UIMobileNavbarVariant.centerAction,
          onAction: () => actions++,
        ),
        width: 180,
      ),
    );
    expect(find.byType(FloatingActionButton), findsNothing);
    await tester.tap(find.byTooltip('Thêm'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Tạo mới'));
    await tester.tap(find.byTooltip('Tạo mới'));
    await tester.pumpAndSettle();
    expect(actions, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rapid animated selections and reflow settle without overflow or idle frames',
    (tester) async {
      late StateSetter update;
      var width = 390.0, scale = 1.0;
      var selected = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, state) {
            update = state;
            return host(
              UIMobileNavbar(
                items: destinations,
                selectedIndex: selected,
                onSelected: (_) {},
                variant: UIMobileNavbarVariant.pill,
              ),
              width: width,
              scale: scale,
              rtl: true,
              reducedMotion: false,
            );
          },
        ),
      );
      for (final config in [
        (390.0, 2, 1.0),
        (390.0, 1, 1.0),
        (280.0, 3, 2.0),
        (120.0, 0, 3.0),
        (390.0, 2, 1.0),
      ]) {
        update(() {
          width = config.$1;
          selected = config.$2;
          scale = config.$3;
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mobile bottom destinations support keyboard activation', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      host(
        UIMobileNavbar(
          items: destinations,
          selectedIndex: 1,
          onSelected: (i) => selected = i,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 0);
  });
}
