import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child, {double scale = 1, bool rtl = false}) => MaterialApp(
  theme: YouthUI.init(primary: Colors.indigo),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'first validation on blur; correction live; clear keeps form value in sync',
    (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(
        host(
          Form(
            key: key,
            child: Column(
              children: [
                UITextField(
                  label: 'Email',
                  clearable: true,
                  validator: UIValidators.email(),
                ),
                const UITextField(label: 'Other'),
              ],
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).first, 'bad');
      await tester.pump();
      expect(find.text('Nhập email hợp lệ.'), findsNothing);
      await tester.tap(find.byType(TextFormField).last);
      await tester.pumpAndSettle();
      expect(find.text('Nhập email hợp lệ.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'a@b.vn');
      await tester.pumpAndSettle();
      expect(find.text('Nhập email hợp lệ.'), findsNothing);
      await tester.tap(find.byTooltip('Xoá email'));
      await tester.pump();
      expect(key.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'submit validates, focuses first invalid and deduplicates async requests',
    (tester) async {
      final controller = UIFormController();
      final focus = FocusNode();
      final done = Completer<void>();
      var calls = 0, successes = 0;
      await tester.pumpWidget(
        host(
          UIForm(
            controller: controller,
            maxColumns: 1,
            onSubmit: () {
              calls++;
              return done.future;
            },
            onSuccess: () => successes++,
            children: [
              UITextField(
                label: 'Email',
                focusNode: focus,
                validator: UIValidators.email(),
              ),
            ],
          ),
        ),
      );
      expect(await controller.submit(), isFalse);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      expect(calls, 0);
      await tester.enterText(find.byType(TextFormField), 'a@b.vn');
      await tester.pumpAndSettle();
      final pending = controller.submit();
      expect(await controller.submit(), isFalse);
      await tester.pump();
      expect(calls, 1);
      expect(controller.isSubmitting, isTrue);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      done.complete();
      expect(await pending, isTrue);
      await tester.pumpAndSettle();
      expect(controller.isSubmitting, isFalse);
      expect(successes, 1);
      expect(find.text('a@b.vn'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      focus.dispose();
    },
  );

  testWidgets(
    'server field error retains uncontrolled values, clears only edited error and retries',
    (tester) async {
      final controller = UIFormController();
      var reject = true;
      await tester.pumpWidget(
        host(
          UIForm(
            controller: controller,
            maxColumns: 1,
            onSubmit: () async {
              if (reject) {
                throw const UIFormException(
                  fieldErrors: {'email': 'Already used'},
                );
              }
            },
            children: [
              UITextField(
                name: 'email',
                label: 'Email',
                validator: UIValidators.email(),
              ),
              const UITextField(label: 'Notes'),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).first, 'a@b.vn');
      await tester.enterText(find.byType(TextFormField).last, 'Keep notes');
      expect(await controller.submit(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Already used'), findsOneWidget);
      expect(find.text('Keep notes'), findsOneWidget);
      expect(find.text('a@b.vn'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).last,
        'Keep notes edited',
      );
      await tester.pump();
      expect(controller.fieldErrors['email'], 'Already used');
      await tester.enterText(find.byType(TextFormField).first, 'new@b.vn');
      await tester.pumpAndSettle();
      expect(find.text('Already used'), findsNothing);
      reject = false;
      expect(await controller.submit(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Keep notes edited'), findsOneWidget);
      expect(find.text('Chưa hoàn tất'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets(
    'unexpected failure uses safe message; unmount ignores late completion',
    (tester) async {
      final controller = UIFormController();
      final done = Completer<void>();
      Object? reported;
      var callbacks = 0;
      await tester.pumpWidget(
        host(
          UIForm(
            controller: controller,
            onSubmit: () => Future.error(StateError('private backend detail')),
            onError: (error, _) => reported = error,
            children: const [UITextField(label: 'Name')],
          ),
        ),
      );
      expect(await controller.submit(), isFalse);
      await tester.pumpAndSettle();
      expect(reported, isA<StateError>());
      expect(find.textContaining('private backend'), findsNothing);
      expect(
        find.text('Chưa thể gửi dữ liệu. Vui lòng thử lại.'),
        findsOneWidget,
      );
      await tester.pumpWidget(
        host(
          UIForm(
            controller: controller,
            onSubmit: () => done.future,
            onSuccess: () => callbacks++,
            children: const [UITextField(label: 'Name')],
          ),
        ),
      );
      final pending = controller.submit();
      await tester.pumpWidget(const SizedBox());
      done.completeError(StateError('late failure'));
      expect(await pending, isFalse);
      await tester.pumpAndSettle();
      expect(callbacks, 0);
      expect(controller.isSubmitting, isFalse);
      expect(tester.takeException(), isNull);
      controller.dispose();
    },
  );

  testWidgets('select binds backend field errors and clears on choosing', (
    tester,
  ) async {
    final controller = UIFormController();
    await tester.pumpWidget(
      host(
        UIForm(
          controller: controller,
          onSubmit: () async => throw const UIFormException(
            fieldErrors: {'team': 'Choose another'},
          ),
          children: [
            UISelect<String>(
              name: 'team',
              label: 'Team',
              initialValue: 'a',
              options: const [
                UIOption(value: 'a', label: 'Alpha'),
                UIOption(value: 'b', label: 'Beta'),
              ],
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    await controller.submit();
    await tester.pumpAndSettle();
    expect(find.text('Choose another'), findsOneWidget);
    await tester.tap(find.byType(UISelect<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(find.text('Choose another'), findsNothing);
    expect(controller.fieldErrors, isEmpty);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('notices deduplicate, bound queue and advance on dismissal', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            context = c;
            return const Text('Ready');
          },
        ),
      ),
    );
    expect(UINotice.show(context, message: 'First'), isTrue);
    expect(UINotice.show(context, message: 'First'), isFalse);
    for (var i = 2; i <= 5; i++) {
      expect(UINotice.show(context, message: 'Item $i'), isTrue);
    }
    expect(UINotice.show(context, message: 'Overflow'), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Item 2'), findsNothing);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(find.text('Item 2'), findsOneWidget);
    UINotice.clear(context);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    UINotice.show(context, message: 'After clear');
    await tester.pumpAndSettle();
    expect(find.text('After clear'), findsOneWidget);
    UINotice.clear(context);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'undo persists, invokes once and important errors do not expire',
    (tester) async {
      late BuildContext context;
      var undo = 0;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (c) {
              context = c;
              return const Text('Ready');
            },
          ),
        ),
      );
      UINotice.show(
        context,
        message: 'Archived',
        actionLabel: 'Undo',
        onAction: () => undo++,
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(undo, 1);
      UINotice.show(context, message: 'Important', tone: UITone.danger);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Important'), findsOneWidget);
      UINotice.clear(context);
      await tester.pumpAndSettle();
      UINotice.show(
        context,
        message: 'Short',
        duration: const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Short'), findsNothing);
    },
  );

  testWidgets('mobile large-text RTL form, banner actions and notice fit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            context = c;
            return Column(
              children: [
                UIForm(
                  onSubmit: () async {},
                  children: const [
                    UITextField(label: 'Email'),
                    UIPasswordField(),
                  ],
                ),
                UIAlert(
                  message: 'A message that can wrap over several lines.',
                  actionLabel: 'Retry connection',
                  onAction: () {},
                  onDismiss: () {},
                ),
              ],
            );
          },
        ),
        scale: 2,
        rtl: true,
      ),
    );
    UINotice.show(
      context,
      message: 'An action that can be undone.',
      actionLabel: 'Undo change',
      onAction: () {},
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    UINotice.clear(context);
    await tester.pumpAndSettle();
  });
}
