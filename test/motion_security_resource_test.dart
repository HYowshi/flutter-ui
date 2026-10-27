import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child, {bool reduced = false, bool contrast = false}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: reduced,
          highContrast: contrast,
          size: const Size(800, 600),
        ),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('entrance preserves edits when motion preference changes', (
    tester,
  ) async {
    Widget content(bool reduced) => host(
      const UIEntrance(child: UITextField(label: 'Keep edit')),
      reduced: reduced,
    );
    await tester.pumpWidget(content(false));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Retained');
    final state = tester.state(find.byType(TextFormField));
    for (final reduced in [true, false, true]) {
      await tester.pumpWidget(content(reduced));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(TextFormField)), same(state));
      expect(find.text('Retained'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    }
  });

  testWidgets('hidden entrance completes without replay on returning', (
    tester,
  ) async {
    Widget content(bool enabled) => host(
      TickerMode(
        enabled: enabled,
        child: const UIEntrance(child: Text('Hidden route')),
      ),
    );
    await tester.pumpWidget(content(false));
    await tester.pumpWidget(content(true));
    await tester.pumpAndSettle();
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(UIEntrance),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('outgoing content mutes tickers while fade can finish', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const UIAnimatedContent(
          child: CircularProgressIndicator(key: ValueKey('busy')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(
      host(
        const UIAnimatedContent(child: Text('Ready', key: ValueKey('ready'))),
      ),
    );
    final old = find.byType(CircularProgressIndicator);
    expect(old, findsOneWidget);
    expect(TickerMode.valuesOf(tester.element(old)).enabled, isFalse);
    await tester.pumpAndSettle();
    expect(old, findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('password does not opt into IME learning when revealed', (
    tester,
  ) async {
    await tester.pumpWidget(host(const UIPasswordField()));
    var field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enableIMEPersonalizedLearning, isFalse);
    expect(field.enableSuggestions, isFalse);
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isFalse);
    expect(field.enableIMEPersonalizedLearning, isFalse);
    expect(field.autocorrect, isFalse);
  });

  testWidgets('unsafe image URLs go directly to custom fallback', (
    tester,
  ) async {
    for (final source in [
      'https://user:secret@example.com/private.png',
      'https://example.com/a\n.png',
      'data:image/png;base64,AAAA',
      'javascript:alert(1)',
    ]) {
      await tester.pumpWidget(
        host(UIImage(source, fallback: const Text('Unavailable'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'theme overlay is abandoned on background and latest theme wins',
    (tester) async {
      final controller = UIThemeController(mode: ThemeMode.light);
      addTearDown(controller.dispose);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(
        UIApp(
          primary: Colors.blue,
          controller: controller,
          home: const Scaffold(body: Text('Content')),
        ),
      );
      await tester.pumpAndSettle();
      controller.mode = ThemeMode.dark;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(RawImage), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(RawImage), findsNothing);
      controller.mode = ThemeMode.light;
      await tester.pump();
      expect(find.byType(RawImage), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Content'))).brightness,
        Brightness.light,
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('standalone theme transition honors system high contrast', (
    tester,
  ) async {
    Widget content(Brightness brightness) => host(
      UIThemeTransition(
        theme: ThemeData(brightness: brightness),
        child: const Text('High contrast'),
      ),
      contrast: true,
    );
    await tester.pumpWidget(content(Brightness.light));
    await tester.pumpWidget(content(Brightness.dark));
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(
      Theme.of(tester.element(find.text('High contrast'))).brightness,
      Brightness.dark,
    );
  });
}
