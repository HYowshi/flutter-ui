import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

Widget host(Widget child) => UIApp(
  primary: Colors.blue,
  reduceMotion: true,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('load once across rebuilds; explicit reload deduplicates', (
    tester,
  ) async {
    final controller = UIAsyncController();
    addTearDown(controller.dispose);
    var calls = 0;
    var pending = Completer<String>();
    Widget content() => host(
      UIAsyncView<String>(
        controller: controller,
        load: () {
          calls++;
          return pending.future;
        },
        builder: (_, data) => Text(data),
      ),
    );
    await tester.pumpWidget(content());
    expect(calls, 1);
    final first = controller.reload();
    expect(identical(first, controller.reload()), isTrue);
    await tester.pumpWidget(content());
    expect(calls, 1);
    pending.complete('First');
    await tester.pumpAndSettle();
    expect(await first, isTrue);
    expect(find.text('First'), findsOneWidget);
    pending = Completer<String>();
    final next = controller.reload();
    expect(identical(next, controller.reload()), isTrue);
    expect(calls, 2);
    pending.complete('Second');
    await tester.pumpAndSettle();
    expect(await next, isTrue);
    expect(find.text('Second'), findsOneWidget);
    expect(controller.isLoading, isFalse);
  });

  testWidgets(
    'changed request identity hides old data and ignores old response',
    (tester) async {
      final controller = UIAsyncController();
      addTearDown(controller.dispose);
      final old = Completer<String>();
      final current = Completer<String>();
      Widget content(int key, Completer<String> request) => host(
        UIAsyncView<String>(
          requestKey: key,
          controller: controller,
          load: () => request.future,
          builder: (_, data) => Text(data),
        ),
      );
      await tester.pumpWidget(content(1, old));
      final oldResult = controller.reload();
      await tester.pumpWidget(content(2, current));
      expect(await oldResult, isFalse);
      old.complete('Wrong account');
      await tester.pump();
      expect(find.text('Wrong account'), findsNothing);
      current.complete('Current account');
      await tester.pumpAndSettle();
      expect(find.text('Current account'), findsOneWidget);
      final replacement = Completer<String>();
      await tester.pumpWidget(content(3, replacement));
      expect(find.text('Current account'), findsNothing);
      replacement.complete('Replacement');
      await tester.pumpAndSettle();
    },
  );

  testWidgets('safe error, diagnostic callback and retry recover', (
    tester,
  ) async {
    var calls = 0, failures = 0;
    await tester.pumpWidget(
      host(
        UIAsyncView<String>(
          load: () {
            calls++;
            if (calls == 1) throw StateError('secret server diagnostic');
            return Future.value('Recovered');
          },
          onError: (error, stack) => failures++,
          builder: (_, data) => Text(data),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('secret server'), findsNothing);
    expect(failures, 1);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Recovered'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('empty result and nullable result are explicit', (tester) async {
    await tester.pumpWidget(
      host(
        UIAsyncView<List<int>>(
          load: () async => [],
          isEmpty: (data) => data.isEmpty,
          builder: (_, data) => const Text('Data'),
          emptyBuilder: (_) => const Text('Custom empty'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Custom empty'), findsOneWidget);
    await tester.pumpWidget(
      host(
        UIAsyncView<String?>(
          key: const ValueKey('nullable'),
          load: () async => null,
          builder: (_, data) => Text(data ?? 'Null is valid data'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Null is valid data'), findsOneWidget);
  });

  testWidgets('dispose settles reload and late failure is handled', (
    tester,
  ) async {
    final controller = UIAsyncController();
    final pending = Completer<int>();
    await tester.pumpWidget(
      host(
        UIAsyncView<int>(
          controller: controller,
          load: () => pending.future,
          builder: (_, data) => Text('$data'),
        ),
      ),
    );
    final result = controller.reload();
    await tester.pumpWidget(const SizedBox());
    expect(await result, isFalse);
    expect(await controller.reload(), isFalse);
    controller.dispose();
    pending.completeError(StateError('obsolete failure'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('controller can move after detach; swapping does not reload', (
    tester,
  ) async {
    final a = UIAsyncController(), b = UIAsyncController();
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    var calls = 0;
    Widget content(UIAsyncController controller) => host(
      UIAsyncView<int>(
        controller: controller,
        load: () async => ++calls,
        builder: (_, data) => Text('$data'),
      ),
    );
    await tester.pumpWidget(content(a));
    await tester.pumpAndSettle();
    await tester.pumpWidget(content(b));
    expect(await a.reload(), isFalse);
    expect(calls, 1);
    final future = b.reload();
    await tester.pumpAndSettle();
    expect(await future, isTrue);
    expect(calls, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(content(a));
    await tester.pumpAndSettle();
    expect(calls, 3);
  });

  testWidgets('custom error and loading builders receive the retry', (
    tester,
  ) async {
    final request = Completer<int>();
    Object? received;
    await tester.pumpWidget(
      host(
        UIAsyncView<int>(
          load: () => request.future,
          loadingBuilder: (_) => const Text('Custom loading'),
          errorBuilder: (_, error, retry) {
            received = error;
            return TextButton(
              onPressed: () => unawaited(retry()),
              child: const Text('Custom retry'),
            );
          },
          builder: (_, data) => Text('$data'),
        ),
      ),
    );
    expect(find.text('Custom loading'), findsOneWidget);
    request.completeError(const FormatException('bad schema'));
    await tester.pumpAndSettle();
    expect(received, isA<FormatException>());
    expect(find.text('Custom retry'), findsOneWidget);
  });

  testWidgets(
    'default states fit large text narrow RTL and do not tick when reduced',
    (tester) async {
      tester.view.physicalSize = const Size(320, 300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final pending = Completer<int>();
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 300),
              textScaler: TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: UIAsyncView<int>(
                load: () => pending.future,
                builder: (_, data) => Text('$data'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      pending.completeError(StateError('failure'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
