import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child, {bool reduced = false, double scale = 1}) =>
    MaterialApp(
      theme: YouthUI.init(primary: Colors.indigo),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduced,
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );

void main() {
  testWidgets(
    'changing reduced motion preserves field state across size paths',
    (tester) async {
      Widget content(bool reduced, String? error) => host(
        UITextField(label: 'Retain on preference change', errorText: error),
        reduced: reduced,
      );
      await tester.pumpWidget(content(false, null));
      await tester.enterText(
        find.byType(TextFormField),
        'Keep across preference',
      );
      for (final reduced in [true, false, true]) {
        await tester.pumpWidget(
          content(reduced, reduced ? 'Error changes height' : null),
        );
        await tester.pumpAndSettle();
        expect(find.text('Keep across preference'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'outgoing content cannot receive taps or semantics; shrinking does not overflow',
    (tester) async {
      var oldTaps = 0;
      Widget content(bool next) => host(
        UIAnimatedContent(
          child: next
              ? const SizedBox(
                  key: ValueKey('new'),
                  width: 200,
                  height: 20,
                  child: Text('New'),
                )
              : Column(
                  key: const ValueKey('old'),
                  children: [
                    TextButton(
                      onPressed: () => oldTaps++,
                      child: const Text('Old action'),
                    ),
                    const SizedBox(height: 160),
                    const Text('Old details'),
                  ],
                ),
        ),
      );
      await tester.pumpWidget(content(false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(content(true));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      final old = find.text('Old action');
      expect(old, findsOneWidget);
      final ignored = find.ancestor(
        of: old,
        matching: find.byWidgetPredicate(
          (w) => w is IgnorePointer && w.ignoring,
        ),
      );
      expect(ignored, findsWidgets);
      expect(
        find.ancestor(of: old, matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
      await tester.pumpAndSettle();
      expect(find.text('Old action'), findsNothing);
      expect(oldTaps, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets(
    'reveal retains text state, excludes hidden focus and reaches zero height',
    (tester) async {
      final focus = FocusNode();
      Widget content(bool visible, {bool reduced = false}) => host(
        UIReveal(
          visible: visible,
          child: UITextField(label: 'Retained', focusNode: focus),
        ),
        reduced: reduced,
      );
      await tester.pumpWidget(content(true));
      await tester.enterText(find.byType(TextFormField), 'Keep edit');
      expect(focus.hasFocus, isTrue);
      await tester.pumpWidget(content(false));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isFalse);
      expect(focus.canRequestFocus, isFalse);
      expect(tester.getSize(find.byType(UIReveal)).height, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(content(true, reduced: true));
      await tester.pump();
      expect(find.text('Keep edit'), findsOneWidget);
      expect(tester.getSize(find.byType(UIReveal)).height, greaterThan(0));
      await tester.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );

  testWidgets(
    'entrance reuses its child per tick and reduced motion completes immediately',
    (tester) async {
      var builds = 0;
      final child = Builder(
        builder: (_) {
          builds++;
          return const Text('Reusable');
        },
      );
      await tester.pumpWidget(host(UIEntrance(child: child)));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(builds, 1);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(
        host(
          const UIEntrance(key: ValueKey('reduced'), child: Text('Immediate')),
          reduced: true,
        ),
      );
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    },
  );

  testWidgets(
    'textbox presets retain data, clear/search callbacks and external errors work',
    (tester) async {
      String? query, changed;
      await tester.pumpWidget(
        host(
          Column(
            children: [
              UITextField.search(
                onFieldSubmitted: (v) => query = v,
                onChanged: (v) => changed = v,
              ),
              const UITextField(
                label: 'Budget',
                initialValue: '100',
                prefixText: '+',
                suffixText: 'VND',
                readOnly: true,
              ),
              UITextField.multiline(label: 'Notes', maxLength: 100),
              const UIPasswordField(errorText: 'Backend error'),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).first, 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(query, 'hello');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Xoá tìm kiếm'));
      await tester.pumpAndSettle();
      expect(changed, '');
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).readOnly,
        isTrue,
      );
      expect(find.text('100'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).minLines,
        3,
      );
      expect(find.text('Backend error'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long titled notice stays bounded at large text with keyboard inset and close stays reachable',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      late BuildContext context;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (c) {
              context = c;
              return const Text('Ready');
            },
          ),
          scale: 2,
        ),
      );
      UINotice.show(
        context,
        title: 'Important update',
        message: List.filled(30, 'Long readable content.').join(' '),
        persistent: true,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final close = find.byTooltip('Close');
      expect(tester.getBottomLeft(close).dy, lessThan(460));
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    },
  );
}
