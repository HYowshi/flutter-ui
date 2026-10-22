import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(
  Widget child, {
  Color color = const Color(0xFF1565C0),
  bool reduced = false,
}) => MaterialApp(
  theme: YouthUI.init(primary: color),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Scaffold(
      body: Center(child: SizedBox(width: 400, child: child)),
    ),
  ),
);
void main() {
  test(
    'theme preserves brand seeds separately and generates readable roles',
    () {
      for (final color in [
        Colors.white,
        Colors.black,
        Colors.yellow,
        Colors.blue,
      ]) {
        final theme = YouthUI.init(primary: color);
        expect(theme.extension<YouthColors>()!.brandPrimary, color);
        final a = theme.colorScheme.primary.computeLuminance(),
            b = theme.colorScheme.onPrimary.computeLuminance();
        expect(
          ((a > b ? a : b) + .05) / ((a < b ? a : b) + .05),
          greaterThan(4.5),
        );
        expect(theme.extension<YouthPalette>(), isNotNull);
      }
    },
  );
  testWidgets('button dispatches once; loading and disabled block callbacks', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      host(UIButton(label: 'Save', onPressed: () => count++)),
    );
    await tester.tap(find.text('Save'));
    expect(count, 1);
    await tester.pumpWidget(
      host(UIButton(label: 'Save', loading: true, onPressed: () => count++)),
    );
    await tester.tap(find.text('Save'));
    expect(count, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(host(const UIButton(label: 'Save')));
    await tester.tap(find.text('Save'));
    expect(count, 1);
  });
  testWidgets('password visibility toggles without losing input', (
    tester,
  ) async {
    await tester.pumpWidget(host(const UIPasswordField()));
    await tester.enterText(find.byType(TextFormField), 'demo-only');
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Hiện mật khẩu'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
    expect(find.text('demo-only'), findsOneWidget);
  });
  testWidgets('form validation is delegated to consumer', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(
      host(
        Form(
          key: key,
          child: UITextField(
            label: 'Email',
            validator: (v) => (v ?? '').contains('@') ? null : 'Invalid email',
          ),
        ),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Invalid email'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'demo@example.com');
    expect(key.currentState!.validate(), isTrue);
  });
  testWidgets(
    'new theme propagates and reduced motion shows content immediately',
    (tester) async {
      await tester.pumpWidget(
        host(const UIEntrance(child: Text('Ready')), reduced: true),
      );
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      await tester.pumpWidget(
        host(const UIButton(label: 'Next'), color: Colors.purple),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(UIButton));
      expect(YouthColors.of(context).brandPrimary, Colors.purple);
    },
  );
}
