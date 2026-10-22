import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';

void main() {
  test('one/two seeds generate complete families without fixed red/yellow defaults', () {
    final one = YouthUI.colors(primary: const Color(0xFF1565C0));
    final two = YouthUI.colors(
      primary: const Color(0xFF1565C0),
      secondary: const Color(0xFFDA251D),
    );
    final a = one.light.colorScheme, b = two.light.colorScheme;
    expect(a.secondary, isNot(b.secondary));
    expect(a.secondaryContainer, isNot(b.secondaryContainer));
    expect(a.onSecondaryContainer, isNot(b.onSecondaryContainer));
    expect(a.secondaryFixed, isNot(b.secondaryFixed));
    expect(a.tertiary, isNot(b.tertiary));
    expect(two.dark.colorScheme.secondary, isNot(b.secondary));
    expect(
      two.dark.extension<YouthColors>()!.brandSecondary,
      const Color(0xFFDA251D),
    );
    expect(one.light.colorScheme.primary, isNot(one.dark.colorScheme.primary));
  });
  test(
    'deterministic, validates seeds and keeps theme instances independent',
    () {
      final a = YouthUI.init(primary: Colors.blue);
      final b = YouthUI.init(primary: Colors.purple);
      expect(a.colorScheme, YouthUI.init(primary: Colors.blue).colorScheme);
      expect(a.colorScheme, isNot(b.colorScheme));
      expect(
        () => YouthUI.init(primary: const Color(0x801565C0)),
        throwsArgumentError,
      );
      expect(
        () => YouthUI.init(primary: Colors.blue, contrastLevel: double.nan),
        throwsArgumentError,
      );
      expect(
        () => YouthUI.init(primary: Colors.blue, contrastLevel: -1),
        throwsArgumentError,
      );
      expect(
        () => YouthUI.init(primary: Colors.blue, surface: Colors.black),
        throwsArgumentError,
      );
      expect(
        () =>
            uiReadableOn(Colors.blue, [Colors.black, Colors.white], minimum: 7),
        throwsStateError,
      );
    },
  );
  test('perceptual profile reduces background chroma rather than inventing emotion', () {
    final reading = YouthUI.init(
      primary: Colors.red,
      profile: UIProfile.reading,
    );
    final expressive = YouthUI.init(
      primary: Colors.red,
      profile: UIProfile.expressive,
    );
    expect(reading.colorScheme.primary, isNot(expressive.colorScheme.primary));
    expect(reading.extension<YouthColors>()!.profile, UIProfile.reading);
  });
  test('contrast matrix: seeds x modes x profiles x layers x states', () {
    final random = Random(20261022);
    final seeds = [
      Colors.black,
      Colors.white,
      const Color(0xFF808080),
      Colors.yellow,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.cyan,
      Colors.purple,
      const Color(0xFF010101),
      const Color(0xFFFEFEFE),
      for (var i = 0; i < 9; i++) Color(0xFF000000 | random.nextInt(0xFFFFFF)),
    ];
    var comparisons = 0;
    final states = <Set<WidgetState>>[
      {},
      {WidgetState.hovered},
      {WidgetState.pressed},
      {WidgetState.focused},
      {WidgetState.selected},
      {WidgetState.selected, WidgetState.hovered},
      {WidgetState.selected, WidgetState.pressed},
    ];
    for (var index = 0; index < seeds.length; index++) {
      for (final mode in Brightness.values) {
        for (final profile in UIProfile.values) {
          final theme = YouthUI.init(
            primary: seeds[index],
            secondary: index.isEven ? seeds[(index + 4) % seeds.length] : null,
            brightness: mode,
            profile: profile,
          );
          final tokens = theme.extension<YouthColors>()!;
          for (final pair in tokens.audit()) {
            expect(
              pair.passed,
              isTrue,
              reason:
                  '${seeds[index]} $mode $profile ${pair.label}: ${pair.ratio}',
            );
            comparisons++;
          }
          for (final tone in UITone.values) {
            for (final variant in UIButtonVariant.values) {
              for (final base in tokens.surfaces) {
                for (final state in states) {
                  final colors = tokens.button(
                    tone,
                    variant,
                    state,
                    surface: base,
                  );
                  expect(
                    uiContrast(colors.foreground, colors.background),
                    greaterThanOrEqualTo(4.5),
                    reason: '${seeds[index]} $mode $tone $variant $state',
                  );
                  comparisons++;
                  if (state.contains(WidgetState.focused)) {
                    expect(
                      uiContrast(colors.border, colors.background),
                      greaterThanOrEqualTo(3),
                    );
                    comparisons++;
                  }
                }
              }
            }
          }
        }
      }
    }
    debugPrint('Checked $comparisons generated role/state pairs.');
  });
  test('high contrast, custom layers and fixed-role foreground pairs', () {
    for (final mode in Brightness.values) {
      for (final seed in [
        Colors.blue,
        Colors.yellow,
        Colors.black,
        Colors.pink,
        Colors.cyan,
        const Color(0xFF808080),
        const Color(0xFF087B59),
        const Color(0xFFE4B53B),
      ]) {
        final theme = YouthUI.init(
          primary: seed,
          secondary: Colors.orange,
          brightness: mode,
          contrastLevel: 1,
          surface: mode == Brightness.light
              ? const Color(0xFFF8F8F8)
              : const Color(0xFF181818),
        );
        final t = theme.extension<YouthColors>()!;
        for (final check in t.audit()) {
          expect(
            check.passed,
            isTrue,
            reason: '${check.label}: ${check.ratio}',
          );
        }
        for (final tone in UITone.values) {
          for (final variant in UIButtonVariant.values) {
            for (final state in <Set<WidgetState>>[
              {},
              {WidgetState.hovered},
              {WidgetState.pressed},
              {WidgetState.focused},
            ]) {
              final result = t.button(tone, variant, state);
              expect(
                uiContrast(result.foreground, result.background),
                greaterThanOrEqualTo(7),
              );
            }
          }
        }
        final s = theme.colorScheme;
        for (final pair in [
          (s.onPrimaryFixed, s.primaryFixed),
          (s.onPrimaryFixedVariant, s.primaryFixedDim),
          (s.onSecondaryFixed, s.secondaryFixed),
          (s.onTertiaryFixed, s.tertiaryFixed),
        ]) {
          expect(uiContrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
        }
      }
    }
  });
}
