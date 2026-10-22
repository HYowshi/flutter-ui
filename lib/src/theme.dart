import 'package:flutter/material.dart';

/// Initialize once in MaterialApp. Widgets inherit colors automatically.
abstract final class YouthUI {
  static ThemeData init({
    required Color primary,
    Color secondary = const Color(0xFFDA251D),
    Color accent = const Color(0xFFF9C846),
    Color? surface,
    Color? background,
    Brightness brightness = Brightness.light,
    String? fontFamily,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: uiForeground(primary),
          secondary: secondary,
          onSecondary: uiForeground(secondary),
          tertiary: accent,
          onTertiary: uiForeground(accent),
          surface: surface,
        );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: background ?? scheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .6)),
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
        YouthPalette(
          success: brightness == Brightness.light
              ? const Color(0xFF146C43)
              : const Color(0xFF81D8A4),
          warning: brightness == Brightness.light
              ? const Color(0xFF805600)
              : const Color(0xFFFFD878),
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

enum UITone { primary, secondary, accent, success, warning, danger }

extension UIToneColor on UITone {
  Color color(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return switch (this) {
      UITone.primary => s.primary,
      UITone.secondary => s.secondary,
      UITone.accent => s.tertiary,
      UITone.success => YouthPalette.of(context).success,
      UITone.warning => YouthPalette.of(context).warning,
      UITone.danger => s.error,
    };
  }
}

/// Chooses the stronger black/white contrast, rather than brightness heuristics.
Color uiForeground(Color color) {
  final l = color.computeLuminance();
  return (l + .05) / .05 >= 1.05 / (l + .05) ? Colors.black : Colors.white;
}

Color uiReadable(Color color, Color background) {
  double contrast(Color a, Color b) {
    final x = a.computeLuminance(), y = b.computeLuminance();
    return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
  }

  if (contrast(color, background) >= 4.5) return color;
  for (var i = 1; i <= 20; i++) {
    final adjusted = Color.lerp(color, uiForeground(background), i / 20)!;
    if (contrast(adjusted, background) >= 4.5) return adjusted;
  }
  return uiForeground(background);
}
