import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child) => UIApp(
  primary: Colors.blue,
  reduceMotion: true,
  home: Scaffold(body: UIPage(children: [child])),
);

void main() {
  testWidgets(
    'PIN requests numeric keyboard and filters paste with leading zeros',
    (tester) async {
      String? changed;
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          UITextField.pin(
            length: 4,
            controller: controller,
            onChanged: (v) => changed = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'a0-0 1.2xyz345');
      expect(controller.text, '0012');
      expect(changed, '0012');
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.number);
      expect(field.obscureText, isTrue);
      expect(field.enableIMEPersonalizedLearning, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(
        tester.testTextInput.setClientArgs!['inputType'],
        TextInputType.number.toJson(),
      );
      await tester.enterText(find.byType(TextFormField), '１２٣٤AB-+ .');
      expect(controller.text, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('PIN enforces max length even for composing numeric input', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(UITextField.pin(controller: controller, length: 4)),
    );
    await tester.showKeyboard(find.byType(TextFormField));
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '123456',
        selection: TextSelection.collapsed(offset: 6),
        composing: TextRange(start: 0, end: 6),
      ),
    );
    await tester.pump();
    expect(controller.text, '1234');
    expect(controller.selection.extentOffset, lessThanOrEqualTo(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'OTP opts into visible digits and autofill without automatic submit',
    (tester) async {
      var submitted = 0;
      String? value;
      await tester.pumpWidget(
        host(
          UITextField.pin(
            obscureText: false,
            autofillHints: const [AutofillHints.oneTimeCode],
            onFieldSubmitted: (v) {
              submitted++;
              value = v;
            },
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '012345');
      await tester.pump();
      expect(submitted, 0);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isFalse);
      expect(field.autofillHints, [AutofillHints.oneTimeCode]);
      expect(field.autocorrect, isFalse);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 1);
      expect(value, '012345');
    },
  );

  testWidgets(
    'PIN validates controller writes and combines required validation',
    (tester) async {
      final controller = TextEditingController();
      final form = GlobalKey<FormState>();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          Form(
            key: form,
            child: UITextField.pin(
              length: 4,
              controller: controller,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              invalidCodeMessage: 'Four digits',
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      for (final invalid in ['123', '12345', 'abcd', '１２３４']) {
        controller.text = invalid;
        expect(form.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('Four digits'), findsOneWidget);
      }
      controller.text = '0012';
      expect(form.currentState!.validate(), isTrue);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('blank PIN is optional unless validator makes it required', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(host(Form(key: form, child: UITextField.pin())));
    expect(form.currentState!.validate(), isTrue);
  });

  test('invalid PIN lengths are rejected before building', () {
    for (final length in [0, -1, 33]) {
      expect(() => UITextField.pin(length: length), throwsRangeError);
    }
  });
}
