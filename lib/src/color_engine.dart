import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart' as mcu;

enum UITone { primary, secondary, accent, success, warning, danger }

enum UIButtonVariant { solid, soft, outline, ghost }

/// Content emphasis, not a guess about a user's emotion or physical display.
enum UIProfile { balanced, reading, expressive }

/// WCAG relative luminance contrast. Alpha must first be composited.
double uiContrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (math.max(x, y) + .05) / (math.min(x, y) + .05);
}

Color uiForeground(Color color) =>
    uiContrast(color, Colors.black) >= uiContrast(color, Colors.white)
    ? Colors.black
    : Colors.white;

/// Find a nearby HCT tone satisfying ALL backgrounds, preserving hue/chroma
/// where the sRGB gamut permits. Throws rather than claiming an impossible pass.
Color uiReadableOn(
  Color preferred,
  List<Color> backgrounds, {
  double minimum = 4.5,
}) {
  if (backgrounds.isEmpty) {
    throw ArgumentError('At least one background is required.');
  }
  bool fits(Color c) => backgrounds.every((b) => uiContrast(c, b) >= minimum);
  if (fits(preferred)) return preferred;
  final hct = mcu.Hct.fromInt(preferred.toARGB32());
  final palette = mcu.TonalPalette.of(hct.hue, hct.chroma);
  Color? best;
  var distance = double.infinity;
  for (var t = 0; t <= 100; t++) {
    final candidate = Color(palette.get(t));
    if ((t - hct.tone).abs() < distance && fits(candidate)) {
      best = candidate;
      distance = (t - hct.tone).abs();
    }
  }
  if (best == null) {
    throw StateError(
      'No foreground meets $minimum:1 across these surfaces. Split the surface contexts.',
    );
  }
  return best;
}

Color uiReadable(Color color, Color background) =>
    uiReadableOn(color, [background]);

@immutable
class UIAccentColors {
  const UIAccentColors({
    required this.solid,
    required this.onSolid,
    required this.soft,
    required this.onSoft,
    required this.border,
  });
  final Color solid, onSolid, soft, onSoft, border;
  UIAccentColors lerp(UIAccentColors other, double t) => UIAccentColors(
    solid: Color.lerp(solid, other.solid, t)!,
    onSolid: Color.lerp(onSolid, other.onSolid, t)!,
    soft: Color.lerp(soft, other.soft, t)!,
    onSoft: Color.lerp(onSoft, other.onSoft, t)!,
    border: Color.lerp(border, other.border, t)!,
  );
}

@immutable
class UIControlColors {
  const UIControlColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
  final Color background, foreground, border;
}

@immutable
class UIContrastCheck {
  const UIContrastCheck(
    this.label,
    this.foreground,
    this.background,
    this.minimum,
  );
  final String label;
  final Color foreground, background;
  final double minimum;
  double get ratio => uiContrast(foreground, background);
  bool get passed => ratio >= minimum;
}

@immutable
class YouthColors extends ThemeExtension<YouthColors> {
  YouthColors({
    required this.scheme,
    required this.brandPrimary,
    this.brandSecondary,
    this.brandAccent,
    required Map<UITone, UIAccentColors> tones,
    required this.canvas,
    required this.focus,
    required this.fieldBorder,
    required this.profile,
    required this.textContrast,
  }) : tones = Map.unmodifiable(tones);
  final ColorScheme scheme;

  /// Original opaque input colors, for brand assets, not automatic text colors.
  final Color brandPrimary;
  final Color? brandSecondary, brandAccent;
  final Map<UITone, UIAccentColors> tones;
  final Color canvas, focus, fieldBorder;
  final UIProfile profile;
  final double textContrast;
  static YouthColors of(BuildContext context) {
    final colors = Theme.of(context).extension<YouthColors>();
    if (colors == null) {
      throw FlutterError(
        'Use YouthUI.init() or YouthUI.colors() in MaterialApp.',
      );
    }
    return colors;
  }

  List<Color> get surfaces => [
    canvas,
    scheme.surface,
    scheme.surfaceContainerLowest,
    scheme.surfaceContainerLow,
    scheme.surfaceContainer,
    scheme.surfaceContainerHigh,
    scheme.surfaceContainerHighest,
  ];

  UIControlColors button(
    UITone tone,
    UIButtonVariant variant,
    Set<WidgetState> states, {
    Color? surface,
  }) {
    final base = surface ?? scheme.surfaceContainerLowest;
    final colors = tones[tone]!;
    if (states.contains(WidgetState.disabled)) {
      return UIControlColors(
        background: Color.alphaBlend(
          scheme.onSurface.withValues(alpha: .10),
          base,
        ),
        foreground: Color.alphaBlend(
          scheme.onSurface.withValues(alpha: .38),
          base,
        ),
        border: scheme.outlineVariant,
      );
    }
    final selected = states.contains(WidgetState.selected);
    final background = switch (variant) {
      UIButtonVariant.solid => colors.solid,
      UIButtonVariant.soft => colors.soft,
      _ => selected ? colors.soft : base,
    };
    final foreground = variant == UIButtonVariant.solid
        ? colors.onSolid
        : variant == UIButtonVariant.soft || selected
        ? colors.onSoft
        : uiReadableOn(colors.solid, [background], minimum: textContrast);
    // Hover, pressed and focus are explicit. Focus also receives a 2px boundary.
    final opacity = states.contains(WidgetState.pressed)
        ? .12
        : states.contains(WidgetState.hovered)
        ? .08
        : states.contains(WidgetState.focused)
        ? .10
        : 0.0;
    var displayed = Color.alphaBlend(
      foreground.withValues(alpha: opacity),
      background,
    );
    if (uiContrast(foreground, displayed) < textContrast) {
      displayed = uiReadableOn(displayed, [foreground], minimum: textContrast);
    }
    return UIControlColors(
      background: displayed,
      foreground: uiReadableOn(foreground, [displayed], minimum: textContrast),
      border: states.contains(WidgetState.focused)
          ? uiReadableOn(foreground, [displayed], minimum: 3)
          : uiReadableOn(colors.border, [base], minimum: 3),
    );
  }

  List<UIContrastCheck> audit() => [
    for (final entry in tones.entries) ...[
      UIContrastCheck(
        '${entry.key.name}/solid',
        entry.value.onSolid,
        entry.value.solid,
        textContrast,
      ),
      UIContrastCheck(
        '${entry.key.name}/soft',
        entry.value.onSoft,
        entry.value.soft,
        textContrast,
      ),
    ],
    for (var i = 0; i < surfaces.length; i++) ...[
      UIContrastCheck(
        'body/surface-$i',
        scheme.onSurface,
        surfaces[i],
        textContrast,
      ),
      UIContrastCheck(
        'muted/surface-$i',
        scheme.onSurfaceVariant,
        surfaces[i],
        textContrast,
      ),
      UIContrastCheck('focus/surface-$i', focus, surfaces[i], 3),
      UIContrastCheck('field-border/surface-$i', fieldBorder, surfaces[i], 3),
    ],
  ];
  @override
  YouthColors copyWith({
    ColorScheme? scheme,
    Map<UITone, UIAccentColors>? tones,
    Color? canvas,
    Color? focus,
    Color? fieldBorder,
  }) => YouthColors(
    scheme: scheme ?? this.scheme,
    brandPrimary: brandPrimary,
    brandSecondary: brandSecondary,
    brandAccent: brandAccent,
    tones: tones ?? this.tones,
    canvas: canvas ?? this.canvas,
    focus: focus ?? this.focus,
    fieldBorder: fieldBorder ?? this.fieldBorder,
    profile: profile,
    textContrast: textContrast,
  );
  @override
  YouthColors lerp(covariant YouthColors? other, double t) => other == null
      ? this
      : YouthColors(
          scheme: ColorScheme.lerp(scheme, other.scheme, t),
          brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
          brandSecondary: other.brandSecondary,
          brandAccent: other.brandAccent,
          tones: {
            for (final tone in UITone.values)
              tone: tones[tone]!.lerp(other.tones[tone]!, t),
          },
          canvas: Color.lerp(canvas, other.canvas, t)!,
          focus: Color.lerp(focus, other.focus, t)!,
          fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
          profile: other.profile,
          textContrast: other.textContrast,
        );
}

/// Design-policy constants are documented and tested, not psychological laws.
YouthColors buildYouthColors({
  required Color primary,
  Color? secondary,
  Color? accent,
  Color? surface,
  Color? background,
  Brightness brightness = Brightness.light,
  UIProfile profile = UIProfile.balanced,
  double contrastLevel = 0,
}) {
  for (final color in [
    primary,
    secondary,
    accent,
    surface,
    background,
  ].whereType<Color>()) {
    if ((color.toARGB32() >>> 24) != 255) {
      throw ArgumentError(
        'Theme seeds must be opaque. Composite alpha colors before initialization.',
      );
    }
  }
  if (!contrastLevel.isFinite || contrastLevel < 0 || contrastLevel > 1) {
    throw ArgumentError.value(contrastLevel, 'contrastLevel', 'Use 0..1.');
  }
  final dark = brightness == Brightness.dark;
  final source = mcu.Hct.fromInt(primary.toARGB32());
  final second = secondary == null
      ? null
      : mcu.Hct.fromInt(secondary.toARGB32());
  final third = accent == null ? null : mcu.Hct.fromInt(accent.toARGB32());
  final limit = profile == UIProfile.expressive
      ? 64.0
      : profile == UIProfile.reading
      ? 36.0
      : 48.0;
  final neutralChroma = profile == UIProfile.reading ? 1.5 : 4.0;
  // A near-neutral input stays neutral; we do not invent a loud brand hue.
  final primaryChroma = source.chroma.clamp(0.0, limit);
  final secondaryChroma = second == null
      ? math.min(source.chroma, 16.0)
      : second.chroma.clamp(0.0, limit * .75);
  // Automatic tertiary is related but displaced. Explicit inputs are respected.
  var tertiaryHue = third?.hue ?? (source.hue + 60) % 360;
  if (third == null && second != null) {
    final delta = ((second.hue - source.hue + 540) % 360) - 180;
    tertiaryHue = (source.hue + delta / 2 + 60) % 360;
  }
  final dynamic = mcu.DynamicScheme(
    sourceColorHct: source,
    variant: mcu.Variant.tonalSpot,
    isDark: dark,
    contrastLevel: contrastLevel,
    primaryPalette: mcu.TonalPalette.of(source.hue, primaryChroma),
    secondaryPalette: mcu.TonalPalette.of(
      second?.hue ?? source.hue,
      secondaryChroma,
    ),
    tertiaryPalette: mcu.TonalPalette.of(
      tertiaryHue,
      third?.chroma.clamp(0.0, limit) ??
          math.min(24.0, math.max(source.chroma, secondaryChroma)),
    ),
    neutralPalette: mcu.TonalPalette.of(
      source.hue,
      math.min(source.chroma, neutralChroma),
    ),
    neutralVariantPalette: mcu.TonalPalette.of(
      source.hue,
      math.min(source.chroma, neutralChroma + 2),
    ),
  );
  Color c(int value) => Color(value);
  var scheme = ColorScheme(
    brightness: brightness,
    primary: c(dynamic.primary),
    onPrimary: c(dynamic.onPrimary),
    primaryContainer: c(dynamic.primaryContainer),
    onPrimaryContainer: c(dynamic.onPrimaryContainer),
    primaryFixed: c(dynamic.primaryFixed),
    primaryFixedDim: c(dynamic.primaryFixedDim),
    onPrimaryFixed: c(dynamic.onPrimaryFixed),
    onPrimaryFixedVariant: c(dynamic.onPrimaryFixedVariant),
    secondary: c(dynamic.secondary),
    onSecondary: c(dynamic.onSecondary),
    secondaryContainer: c(dynamic.secondaryContainer),
    onSecondaryContainer: c(dynamic.onSecondaryContainer),
    secondaryFixed: c(dynamic.secondaryFixed),
    secondaryFixedDim: c(dynamic.secondaryFixedDim),
    onSecondaryFixed: c(dynamic.onSecondaryFixed),
    onSecondaryFixedVariant: c(dynamic.onSecondaryFixedVariant),
    tertiary: c(dynamic.tertiary),
    onTertiary: c(dynamic.onTertiary),
    tertiaryContainer: c(dynamic.tertiaryContainer),
    onTertiaryContainer: c(dynamic.onTertiaryContainer),
    tertiaryFixed: c(dynamic.tertiaryFixed),
    tertiaryFixedDim: c(dynamic.tertiaryFixedDim),
    onTertiaryFixed: c(dynamic.onTertiaryFixed),
    onTertiaryFixedVariant: c(dynamic.onTertiaryFixedVariant),
    error: c(dynamic.error),
    onError: c(dynamic.onError),
    errorContainer: c(dynamic.errorContainer),
    onErrorContainer: c(dynamic.onErrorContainer),
    surface: c(dynamic.surface),
    onSurface: c(dynamic.onSurface),
    onSurfaceVariant: c(dynamic.onSurfaceVariant),
    surfaceDim: c(dynamic.surfaceDim),
    surfaceBright: c(dynamic.surfaceBright),
    surfaceContainerLowest: c(dynamic.surfaceContainerLowest),
    surfaceContainerLow: c(dynamic.surfaceContainerLow),
    surfaceContainer: c(dynamic.surfaceContainer),
    surfaceContainerHigh: c(dynamic.surfaceContainerHigh),
    surfaceContainerHighest: c(dynamic.surfaceContainerHighest),
    outline: c(dynamic.outline),
    outlineVariant: c(dynamic.outlineVariant),
    inverseSurface: c(dynamic.inverseSurface),
    onInverseSurface: c(dynamic.inverseOnSurface),
    inversePrimary: c(dynamic.inversePrimary),
    surfaceTint: c(dynamic.surfaceTint),
    scrim: c(dynamic.scrim),
    shadow: c(dynamic.shadow),
  );
  // Exact surface overrides are accepted only inside a coherent light/dark band.
  for (final value in [surface, background].whereType<Color>()) {
    final tone = mcu.Hct.fromInt(value.toARGB32()).tone;
    if (dark ? tone > 30 : tone < 85) {
      throw ArgumentError(
        'Custom surface/background conflicts with brightness. Light: tone >=85; dark: tone <=30.',
      );
    }
  }
  scheme = scheme.copyWith(surface: surface);
  final canvas = background ?? scheme.surface;
  final surfaces = [
    canvas,
    scheme.surface,
    scheme.surfaceContainerLowest,
    scheme.surfaceContainerLow,
    scheme.surfaceContainer,
    scheme.surfaceContainerHigh,
    scheme.surfaceContainerHighest,
  ];
  final target = contrastLevel >= .5 ? 7.0 : 4.5;
  UIAccentColors family(Color solid, Color onSolid, Color soft, Color onSoft) {
    var fill = uiReadableOn(solid, surfaces, minimum: 4.5);
    // At high contrast, ensure a foreground can actually achieve 7:1 on fill.
    if (uiContrast(uiForeground(fill), fill) < target) {
      fill = uiReadableOn(fill, [uiForeground(fill)], minimum: target);
    }
    return UIAccentColors(
      solid: fill,
      onSolid: uiReadableOn(onSolid, [fill], minimum: target),
      soft: soft,
      onSoft: uiReadableOn(onSoft, [soft], minimum: target),
      border: uiReadableOn(fill, surfaces, minimum: 3),
    );
  }

  final primaryColors = family(
    scheme.primary,
    scheme.onPrimary,
    scheme.primaryContainer,
    scheme.onPrimaryContainer,
  );
  final secondaryColors = family(
    scheme.secondary,
    scheme.onSecondary,
    scheme.secondaryContainer,
    scheme.onSecondaryContainer,
  );
  final tertiaryColors = family(
    scheme.tertiary,
    scheme.onTertiary,
    scheme.tertiaryContainer,
    scheme.onTertiaryContainer,
  );
  final errorColors = family(
    scheme.error,
    scheme.onError,
    scheme.errorContainer,
    scheme.onErrorContainer,
  );
  UIAccentColors status(double hue) {
    final palette = mcu.TonalPalette.of(hue, 34);
    Color tone(int t) => Color(palette.get(t));
    return family(
      tone(dark ? 80 : 40),
      tone(dark ? 20 : 100),
      tone(dark ? 25 : 95),
      tone(dark ? 90 : 20),
    );
  }

  scheme = scheme.copyWith(
    primary: primaryColors.solid,
    onPrimary: primaryColors.onSolid,
    primaryContainer: primaryColors.soft,
    onPrimaryContainer: primaryColors.onSoft,
    secondary: secondaryColors.solid,
    onSecondary: secondaryColors.onSolid,
    secondaryContainer: secondaryColors.soft,
    onSecondaryContainer: secondaryColors.onSoft,
    tertiary: tertiaryColors.solid,
    onTertiary: tertiaryColors.onSolid,
    tertiaryContainer: tertiaryColors.soft,
    onTertiaryContainer: tertiaryColors.onSoft,
    error: errorColors.solid,
    onError: errorColors.onSolid,
    errorContainer: errorColors.soft,
    onErrorContainer: errorColors.onSoft,
    onSurface: uiReadableOn(scheme.onSurface, surfaces, minimum: target),
    onSurfaceVariant: uiReadableOn(
      scheme.onSurfaceVariant,
      surfaces,
      minimum: target,
    ),
    outline: uiReadableOn(scheme.outline, surfaces, minimum: 3),
  );
  return YouthColors(
    scheme: scheme,
    brandPrimary: primary,
    brandSecondary: secondary,
    brandAccent: accent,
    canvas: canvas,
    focus: uiReadableOn(primaryColors.solid, surfaces, minimum: 3),
    fieldBorder: uiReadableOn(scheme.outline, surfaces, minimum: 3),
    profile: profile,
    textContrast: target,
    tones: {
      UITone.primary: primaryColors,
      UITone.secondary: secondaryColors,
      UITone.accent: tertiaryColors,
      UITone.danger: errorColors,
      UITone.success: status(145),
      UITone.warning: status(85),
    },
  );
}

/// Surface context for custom containers. UICard supplies it automatically.
class UISurfaceScope extends InheritedWidget {
  const UISurfaceScope({super.key, required this.color, required super.child});
  final Color color;
  static Color of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UISurfaceScope>()?.color ??
      Theme.of(context).scaffoldBackgroundColor;
  @override
  bool updateShouldNotify(UISurfaceScope oldWidget) => oldWidget.color != color;
}
