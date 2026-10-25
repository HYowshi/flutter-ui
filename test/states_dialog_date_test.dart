import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

void viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets(
    'all state views fit a small high-text viewport and expose actions',
    (tester) async {
      viewport(tester, const Size(320, 240));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      var taps = 0;
      for (final kind in UIStateKind.values) {
        await tester.pumpWidget(
          UIApp(
            primary: Colors.blue,
            reduceMotion: true,
            home: Scaffold(
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: UIStateView(
                  kind: kind,
                  message: 'Long explanatory message that needs several lines.',
                  progress: kind == UIStateKind.loading ? .65 : null,
                  actionLabel: 'Retry action',
                  onAction: () => taps++,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: kind.name);
        await tester.ensureVisible(find.text('Retry action'));
        await tester.tap(find.text('Retry action'));
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
      }
      expect(taps, UIStateKind.values.length);
    },
  );

  testWidgets('state illustration and secondary action are replaceable', (
    tester,
  ) async {
    var secondary = 0;
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        home: Scaffold(
          body: UIStateView(
            kind: UIStateKind.empty,
            title: 'My empty page',
            illustration: const Text('Custom illustration'),
            secondaryActionLabel: 'Open archive',
            onSecondaryAction: () => secondary++,
          ),
        ),
      ),
    );
    expect(find.text('Custom illustration'), findsOneWidget);
    await tester.tap(find.text('Open archive'));
    expect(secondary, 1);
  });

  for (final width in [390.0, 1000.0]) {
    testWidgets(
      'adaptive popup chooses presentation at width $width and returns result',
      (tester) async {
        viewport(tester, Size(width, 850));
        String? result;
        await tester.pumpWidget(
          UIApp(
            primary: Colors.blue,
            reduceMotion: true,
            home: Scaffold(
              body: Builder(
                builder: (context) => UIButton(
                  label: 'Open',
                  onPressed: () async {
                    result = await UIAdaptiveDialog.show<String>(
                      context,
                      title: 'Edit details',
                      builder: (_) => const UITextField(label: 'Note'),
                      actionsBuilder: (routeContext) => [
                        UIButton(
                          label: 'Apply',
                          onPressed: () => Navigator.pop(routeContext, 'saved'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          find.byType(BottomSheet),
          width < 600 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(Dialog),
          width >= 600 ? findsOneWidget : findsNothing,
        );
        await tester.enterText(find.byType(TextFormField), 'Keep my note');
        tester.view.physicalSize = Size(width < 600 ? 1000 : 390, 850);
        await tester.pumpAndSettle();
        expect(find.text('Keep my note'), findsOneWidget);
        // It remains the same route after crossing the breakpoint.
        expect(
          find.byType(BottomSheet),
          width < 600 ? findsOneWidget : findsNothing,
        );
        await tester.ensureVisible(find.text('Apply'));
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(result, 'saved');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'non-dismissible popup blocks back, confirmation returns explicit choice',
    (tester) async {
      viewport(tester, const Size(900, 700));
      bool? result;
      await tester.pumpWidget(
        UIApp(
          primary: Colors.blue,
          reduceMotion: true,
          home: Scaffold(
            body: Builder(
              builder: (context) => UIButton(
                label: 'Open',
                onPressed: () async {
                  result = await UIAdaptiveDialog.confirm(
                    context,
                    title: 'Confirm choice',
                    message: 'Example only',
                    confirmLabel: 'Accept choice',
                    dismissible: false,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Confirm choice'), findsOneWidget);
      await tester.tap(find.text('Accept choice'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  for (final presentation in [UIPresentation.dialog, UIPresentation.sheet]) {
    testWidgets('long $presentation scrolls above keyboard at 200% text', (
      tester,
    ) async {
      viewport(tester, const Size(320, 640));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        UIApp(
          primary: Colors.blue,
          reduceMotion: true,
          home: Scaffold(
            body: Builder(
              builder: (context) => UIButton(
                label: 'Open',
                onPressed: () {
                  UIAdaptiveDialog.show<void>(
                    context,
                    title: 'A long title that needs to wrap',
                    presentation: presentation,
                    builder: (_) => Column(
                      children: [
                        const UITextField(label: 'Details'),
                        for (var i = 0; i < 20; i++) Text('Long content $i'),
                      ],
                    ),
                    actionsBuilder: (routeContext) => [
                      UIButton(
                        label: 'Finish',
                        onPressed: () => Navigator.pop(routeContext),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.text('Finish')).bottom,
        lessThanOrEqualTo(360),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(BottomSheet), findsNothing);
    });
  }

  testWidgets('date picker validates bounds in release paths before opening', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold();
          },
        ),
      ),
    );
    expect(
      () => UIDatePicker.show(
        context,
        firstDate: DateTime(2027),
        lastDate: DateTime(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => UIDatePicker.show(context, initialDate: DateTime(1800)),
      throwsArgumentError,
    );
    expect(
      () => UIDatePicker.show(
        context,
        initialDate: DateTime(2026, 11, 28),
        selectableDayPredicate: (d) => d.weekday <= DateTime.friday,
      ),
      throwsArgumentError,
    );
    expect(
      () => UIDatePicker.range(
        context,
        initialRange: DateTimeRange(start: DateTime(1800), end: DateTime(1801)),
      ),
      throwsArgumentError,
    );
  });

  testWidgets(
    'date field picks, cancels, clears, validates and follows external value',
    (tester) async {
      viewport(tester, const Size(900, 850));
      DateTime? value = DateTime(2026, 11, 25);
      late StateSetter update;
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        UIApp(
          primary: Colors.blue,
          reduceMotion: true,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return Form(
                  key: form,
                  child: UIDateField(
                    label: 'Start',
                    value: value,
                    entryMode: DatePickerEntryMode.inputOnly,
                    firstDate: DateTime(2026),
                    lastDate: DateTime(2027),
                    selectableDayPredicate: (day) =>
                        day.weekday <= DateTime.friday,
                    format: (d) => '${d.year}-${d.month}-${d.day}',
                    validator: (d) => d == null ? 'Required date' : null,
                    onChanged: (d) => setState(() => value = d),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(UIDateField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '11/28/2026');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(value, DateTime(2026, 11, 25));
      await tester.enterText(find.byType(TextField), '11/27/2026');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(value, DateTime(2026, 11, 27));
      expect(find.text('2026-11-27'), findsOneWidget);
      await tester.tap(find.byType(UIDateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(value, DateTime(2026, 11, 27));
      await tester.tap(find.byTooltip('Xóa start'));
      await tester.pumpAndSettle();
      expect(value, isNull);
      expect(form.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Required date'), findsOneWidget);
      update(() => value = DateTime(2026, 12, 1));
      await tester.pumpAndSettle();
      expect(find.text('2026-12-1'), findsOneWidget);
      expect(form.currentState!.validate(), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('date fields support Vietnamese calendar and keyboard opening', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        locale: const Locale('vi'),
        home: Scaffold(
          body: UIDateField(
            label: 'Ngày hẹn',
            value: DateTime(2026, 11, 25),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.text('Huỷ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('date field ignores late selection after owner is removed', (
    tester,
  ) async {
    viewport(tester, const Size(900, 850));
    var calls = 0;
    var visible = true;
    late StateSetter update;
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return visible
                  ? UIDateField(
                      label: 'Date',
                      value: DateTime(2026, 11, 25),
                      onChanged: (_) => calls++,
                    )
                  : const Text('Removed');
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(UIDateField));
    await tester.pumpAndSettle();
    update(() => visible = false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('date field receives named form errors and locks during submit', (
    tester,
  ) async {
    viewport(tester, const Size(900, 850));
    final controller = UIFormController();
    final gate = Completer<void>();
    DateTime? value = DateTime(2026, 11, 25);
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        reduceMotion: true,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => UIForm(
              controller: controller,
              onSubmit: () async {
                await gate.future;
                throw const UIFormException(
                  fieldErrors: {'appointment': 'This date is booked'},
                );
              },
              children: [
                UIDateField(
                  name: 'appointment',
                  label: 'Appointment',
                  value: value,
                  onChanged: (d) => setState(() => value = d),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final pending = controller.submit();
    await tester.pump();
    final decorator = tester.widget<InputDecorator>(
      find.descendant(
        of: find.byType(UIDateField),
        matching: find.byType(InputDecorator),
      ),
    );
    expect(decorator.decoration.enabled, isFalse);
    gate.complete();
    expect(await pending, isFalse);
    await tester.pumpAndSettle();
    expect(find.text('This date is booked'), findsOneWidget);
    await tester.tap(find.byTooltip('Xóa appointment'));
    await tester.pumpAndSettle();
    expect(value, isNull);
    expect(controller.fieldErrors, isEmpty);
    expect(find.text('This date is booked'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('range picker supports input, bounds and date-only result', (
    tester,
  ) async {
    viewport(tester, const Size(900, 850));
    DateTimeRange? result;
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        reduceMotion: true,
        home: Scaffold(
          body: Builder(
            builder: (context) => UIButton(
              label: 'Open range',
              onPressed: () async {
                result = await UIDatePicker.range(
                  context,
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2027),
                  entryMode: DatePickerEntryMode.inputOnly,
                  confirmLabel: 'Apply range',
                  initialRange: DateTimeRange(
                    start: DateTime(2026, 11, 25),
                    end: DateTime(2026, 11, 27),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open range'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '11/26/2026');
    await tester.enterText(find.byType(TextField).at(1), '11/30/2026');
    await tester.tap(find.text('Apply range'));
    await tester.pumpAndSettle();
    expect(result?.start, DateTime(2026, 11, 26));
    expect(result?.end, DateTime(2026, 11, 30));
    expect(tester.takeException(), isNull);
  });
  testWidgets('native calendar and range fit narrow high-text screens', (
    tester,
  ) async {
    viewport(tester, const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    late BuildContext context;
    await tester.pumpWidget(
      UIApp(
        primary: Colors.blue,
        reduceMotion: true,
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold();
          },
        ),
      ),
    );
    final dateResult = UIDatePicker.show(
      context,
      initialDate: DateTime(2026, 11, 25),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();
    expect(await dateResult, isNull);
    final rangeResult = UIDatePicker.range(context);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<DateRangePickerDialog>(find.byType(DateRangePickerDialog))
          .initialEntryMode,
      DatePickerEntryMode.inputOnly,
    );
    Navigator.of(tester.element(find.byType(DateRangePickerDialog))).pop();
    await tester.pumpAndSettle();
    expect(await rangeResult, isNull);
  });
}
