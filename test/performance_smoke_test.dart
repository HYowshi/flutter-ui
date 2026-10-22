import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

void main() {
  test('bounded state cache reuses warm resolutions without cross-theme pollution', () {
    final watch = Stopwatch()..start();
    final pair = YouthUI.colors(primary: Colors.indigo);
    final themeMicros = watch.elapsedMicroseconds;
    final light = pair.light.extension<YouthColors>()!;
    final dark = pair.dark.extension<YouthColors>()!;
    const states = {WidgetState.hovered};
    final first = light.button(UITone.primary, UIButtonVariant.outline, states);
    watch
      ..reset()
      ..start();
    for (var i = 0; i < 10000; i++) {
      expect(
        identical(
          light.button(UITone.primary, UIButtonVariant.outline, states),
          first,
        ),
        isTrue,
      );
    }
    final warmMicros = watch.elapsedMicroseconds;
    expect(
      dark.button(UITone.primary, UIButtonVariant.outline, states).background,
      isNot(first.background),
    );
    for (var i = 0; i < 140; i++) {
      light.button(
        UITone.primary,
        UIButtonVariant.outline,
        states,
        surface: Color(0xFFF00000 + i * 200),
      );
    }
    expect(
      identical(
        light.button(UITone.primary, UIButtonVariant.outline, states),
        first,
      ),
      isFalse,
    );
    // Diagnostics only: includes test matcher/JIT overhead, not frame timing or an FPS claim.
    debugPrint(
      'PERF_SMOKE theme_pair_us=$themeMicros warm_10000_with_assertions_us=$warmMicros cache_limit=128',
    );
  });

  testWidgets(
    'theme transition does not rebuild live consumers on every animation frame',
    (tester) async {
      var builds = 0;
      final mode = UIThemeController(mode: ThemeMode.light);
      addTearDown(mode.dispose);
      await tester.pumpWidget(
        UIApp(
          primary: Colors.indigo,
          controller: mode,
          home: Builder(
            builder: (context) {
              builds++;
              final s = Theme.of(context).colorScheme;
              return Scaffold(
                body: ColoredBox(
                  color: s.surface,
                  child: const Text('Live content'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initial = builds;
      mode.mode = ThemeMode.dark;
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      expect(builds - initial, lessThanOrEqualTo(3));
      expect(find.byType(RawImage), findsNothing);
      expect(tester.takeException(), isNull);
      debugPrint(
        'PERF_SMOKE live_theme_consumer_rebuilds=${builds - initial} sampled_animation_frames=20',
      );
    },
  );
}
