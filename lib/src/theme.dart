import 'package:flutter/material.dart';

import 'color_engine.dart';
import 'adaptive.dart';

/// Theme pair for MaterialApp(theme: ui.light, darkTheme: ui.dark).
class YouthThemeSet {
  YouthThemeSet({
    required Color primary,
    Color? secondary,
    Color? accent,
    UIProfile profile = UIProfile.balanced,
    double contrastLevel = 0,
    String? fontFamily,
    UIAdaptiveConfig adaptive = const UIAdaptiveConfig(),
  }) {
    light = YouthUI.init(
      primary: primary,
      secondary: secondary,
      accent: accent,
      profile: profile,
      contrastLevel: contrastLevel,
      fontFamily: fontFamily,
      adaptive: adaptive,
    );
    dark = YouthUI.init(
      primary: primary,
      secondary: secondary,
      accent: accent,
      profile: profile,
      contrastLevel: contrastLevel,
      fontFamily: fontFamily,
      adaptive: adaptive,
      brightness: Brightness.dark,
    );
  }
  late final ThemeData light, dark;
}

abstract final class YouthUI {
  /// One or two seeds are enough; optional accent is a third explicit seed.
  static YouthThemeSet colors({
    required Color primary,
    Color? secondary,
    Color? accent,
    UIProfile profile = UIProfile.balanced,
    double contrastLevel = 0,
    String? fontFamily,
    UIAdaptiveConfig adaptive = const UIAdaptiveConfig(),
  }) => YouthThemeSet(
    primary: primary,
    secondary: secondary,
    accent: accent,
    profile: profile,
    contrastLevel: contrastLevel,
    fontFamily: fontFamily,
    adaptive: adaptive,
  );

  static ThemeData init({
    required Color primary,
    Color? secondary,
    Color? accent,
    Color? surface,
    Color? background,
    Brightness brightness = Brightness.light,
    String? fontFamily,
    UIProfile profile = UIProfile.balanced,
    double contrastLevel = 0,
    UIAdaptiveConfig adaptive = const UIAdaptiveConfig(),
  }) {
    final colors = buildYouthColors(
      primary: primary,
      secondary: secondary,
      accent: accent,
      surface: surface,
      background: background,
      brightness: brightness,
      profile: profile,
      contrastLevel: contrastLevel,
    );
    final s = colors.scheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.fieldBorder),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.canvas,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        modalElevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.surfaceContainerLowest,
        labelStyle: TextStyle(color: s.onSurfaceVariant),
        helperStyle: TextStyle(color: s.onSurfaceVariant),
        hintStyle: TextStyle(color: s.onSurfaceVariant),
        prefixIconColor: s.onSurfaceVariant,
        suffixIconColor: s.onSurfaceVariant,
        errorStyle: TextStyle(color: s.error),
        errorMaxLines: 6,
        helperMaxLines: 6,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.focus, width: 2),
        ),
        errorBorder: border.copyWith(borderSide: BorderSide(color: s.error)),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: s.error, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: s.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: s.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: shape,
        ),
      ),
      extensions: [
        adaptive,
        colors,
        YouthPalette(
          success: colors.tones[UITone.success]!.solid,
          warning: colors.tones[UITone.warning]!.solid,
        ),
      ],
    );
  }
}

@immutable
class YouthPalette extends ThemeExtension<YouthPalette> {
  const YouthPalette({required this.success, required this.warning});
  final Color success, warning;
  static YouthPalette of(BuildContext context) =>
      Theme.of(context).extension<YouthPalette>() ??
      const YouthPalette(
        success: Color(0xFF146C43),
        warning: Color(0xFF805600),
      );
  @override
  YouthPalette copyWith({Color? success, Color? warning}) => YouthPalette(
    success: success ?? this.success,
    warning: warning ?? this.warning,
  );
  @override
  YouthPalette lerp(covariant YouthPalette? other, double t) => other == null
      ? this
      : YouthPalette(
          success: Color.lerp(success, other.success, t)!,
          warning: Color.lerp(warning, other.warning, t)!,
        );
}

extension UIToneColor on UITone {
  Color color(BuildContext context) =>
      YouthColors.of(context).tones[this]!.solid;
  UIAccentColors colors(BuildContext context) =>
      YouthColors.of(context).tones[this]!;
}
