import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

const destinations = [
  UIDestination(label: 'Hồ sơ', icon: Icons.person_outline),
  UIDestination(label: 'Thông báo', icon: Icons.notifications_none),
  UIDestination(label: 'Bảo mật', icon: Icons.shield_outlined),
];

Widget screen({
  double scale = 1,
  EdgeInsets insets = EdgeInsets.zero,
  TextDirection direction = TextDirection.ltr,
}) => MaterialApp(
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
  home: MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(scale),
      viewInsets: insets,
    ),
    child: Directionality(
      textDirection: direction,
      child: UIAdaptiveScaffold(
        title: 'Hồ sơ cá nhân',
        subtitle: 'Thông tin liên hệ và lựa chọn của bạn.',
        destinations: destinations,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        supporting: const Text('Supporting content'),
        actions: TextButton(onPressed: () {}, child: const Text('Save')),
        child: const TextField(key: ValueKey('profile-name')),
      ),
    ),
  ),
);

void main() {
  testWidgets('navigation changes with local width and keeps edited content', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(360, 720);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Keep my edit');
    for (final width in [768.0, 1080.0, 360.0]) {
      tester.view.physicalSize = Size(width, 720);
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      expect(find.text('Keep my edit'), findsOneWidget);
      if (width >= 600) {
        expect(
          tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
          width >= 1024,
        );
      } else {
        expect(find.byType(NavigationBar), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('supporting pane moves beside content only when both panes fit', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [360.0, 768.0, 1080.0]) {
      tester.view.physicalSize = Size(width, 720);
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      if (width < 600) {
        await tester.tap(find.text('Thông tin thêm'));
        await tester.pumpAndSettle();
      }
      final main = tester.getTopLeft(find.byType(TextField));
      final support = tester.getTopLeft(find.text('Supporting content'));
      if (width == 1080) {
        expect(support.dx, greaterThan(main.dx));
      } else {
        expect(support.dy, greaterThan(main.dy));
      }
      expect(
        tester.getSize(find.byType(TextField)).width,
        lessThanOrEqualTo(720),
      );
      expect(tester.takeException(), isNull);
    }
  });
  for (final width in [280.0, 768.0, 1280.0]) {
    testWidgets('large text and RTL remain scrollable at $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 560);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(screen(scale: 2, direction: TextDirection.rtl));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('soft keyboard inset leaves action visible', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(screen(insets: const EdgeInsets.only(bottom: 280)));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('Save')).dy, lessThan(440));
    expect(tester.takeException(), isNull);
  });
}
