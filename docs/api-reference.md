# youth_ui API reference

Generated for **0.18.0** from the public export/part graph of lib/youth_ui.dart.
Source fingerprint: `fa8e014dc60ec92cae834c1be6a61343c367c42f14d5d9f56c04604422cee6e7`.

Do not edit manually. Run `python tool/generate_ai_docs.py`; CI checks drift.
These are source-derived declaration excerpts: explicit constructors/defaults,
public field types, and public methods/getters declared by this package. Constructor
initializer assertions, implementation bodies, inherited members, top-level helpers
and routine Flutter protocol overrides are omitted. This is not a Dart type resolver
or a replacement for source/dartdoc. If extraction cannot express a new syntax,
update the extractor or consult source; do not infer missing APIs.

`this.x` gets its type from the field declarations below. Imports are omitted for
compactness; consumer import is `package:youth_ui/youth_ui.dart` plus Flutter imports.
For integration constraints, limits and ownership see [AI guide](ai-guide.md) and
its linked detailed guides. Do not copy a declaration as an executable example.

- [UIAdaptiveConfig](#uiadaptiveconfig)
- [UIAdaptiveData](#uiadaptivedata)
- [UIAdaptiveBuilder](#uiadaptivebuilder)
- [UIPage](#uipage)
- [UIGrid](#uigrid)
- [UIActions](#uiactions)
- [UIPresentation](#uipresentation)
- [UIAdaptiveDialog](#uiadaptivedialog)
- [UIDestination](#uidestination)
- [UIAdaptiveScaffold](#uiadaptivescaffold)
- [UIThemeController](#uithemecontroller)
- [UIApp](#uiapp)
- [UIThemeToggle](#uithemetoggle)
- [UIThemeTransition](#uithemetransition)
- [UIAsyncController](#uiasynccontroller)
- [UIAsyncView](#uiasyncview)
- [UITone](#uitone)
- [UIButtonVariant](#uibuttonvariant)
- [UIProfile](#uiprofile)
- [UIAccentColors](#uiaccentcolors)
- [UIControlColors](#uicontrolcolors)
- [UIContrastCheck](#uicontrastcheck)
- [YouthColors](#youthcolors)
- [UISurfaceScope](#uisurfacescope)
- [UIButton](#uibutton)
- [UIInputVariant](#uiinputvariant)
- [UITextField](#uitextfield)
- [UIPasswordField](#uipasswordfield)
- [UICard](#uicard)
- [UIBadge](#uibadge)
- [UIAlert](#uialert)
- [UICheckbox](#uicheckbox)
- [UISwitch](#uiswitch)
- [UIToggleButton](#uitogglebutton)
- [UIOption](#uioption)
- [UISegmentedControl](#uisegmentedcontrol)
- [UIDatePicker](#uidatepicker)
- [UIDateField](#uidatefield)
- [UINotice](#uinotice)
- [UIFabSize](#uifabsize)
- [UIFloatingActionButton](#uifloatingactionbutton)
- [UIFormException](#uiformexception)
- [UIFormController](#uiformcontroller)
- [UIForm](#uiform)
- [UIValidators](#uivalidators)
- [UIImage](#uiimage)
- [UIMotion](#uimotion)
- [UIAnimatedSize](#uianimatedsize)
- [UIEntrance](#uientrance)
- [UIAnimatedContent](#uianimatedcontent)
- [UIReveal](#uireveal)
- [UISidebarVariant](#uisidebarvariant)
- [UINavbarVariant](#uinavbarvariant)
- [UINavigationLayout](#uinavigationlayout)
- [UINavigationItem](#uinavigationitem)
- [UISidebar](#uisidebar)
- [UINavbar](#uinavbar)
- [UINavigationScaffold](#uinavigationscaffold)
- [UIRadio](#uiradio)
- [UIRadioGroup](#uiradiogroup)
- [UISelect](#uiselect)
- [UIStateKind](#uistatekind)
- [UIStateView](#uistateview)
- [UITableColumn](#uitablecolumn)
- [UITable](#uitable)
- [YouthThemeSet](#youththemeset)
- [YouthUI](#youthui)
- [YouthPalette](#youthpalette)
- [UIToneColor](#uitonecolor)
- [UIWireframe](#uiwireframe)
- [UIWireframeLayout](#uiwireframelayout)
- [UIWireframeConfidence](#uiwireframeconfidence)
- [UIWireframeFieldType](#uiwireframefieldtype)
- [UIWireframeField](#uiwireframefield)
- [UIWireframePlan](#uiwireframeplan)
- [UIWireframeInference](#uiwireframeinference)

## UIAdaptiveConfig

[Source: lib/src/adaptive.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive.dart)

```dart
class UIAdaptiveConfig extends ThemeExtension<UIAdaptiveConfig> {
  const UIAdaptiveConfig({
    this.compactBreakpoint = 600,
    this.expandedBreakpoint = 1024,
    this.maxContentWidth = 1120,
    this.minColumnWidth = 280,
  });

  final double compactBreakpoint, expandedBreakpoint;

  final double maxContentWidth, minColumnWidth;

  static UIAdaptiveConfig of(BuildContext context);
}
```

## UIAdaptiveData

[Source: lib/src/adaptive.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive.dart)

```dart
class UIAdaptiveData {
  const UIAdaptiveData({
    required this.width,
    required this.boundedWidth,
    required this.pointer,
    required this.textScale,
    required this.config,
  });

  final double width, textScale;

  final bool boundedWidth, pointer;

  final UIAdaptiveConfig config;

  bool get compact;

  bool get expanded;

  double get gap;

  double get pagePadding;

  EdgeInsets get controlPadding;
}
```

## UIAdaptiveBuilder

[Source: lib/src/adaptive.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive.dart)

```dart
class UIAdaptiveBuilder extends StatelessWidget {
  const UIAdaptiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext, UIAdaptiveData) builder;
}
```

## UIPage

[Source: lib/src/adaptive.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive.dart)

```dart
class UIPage extends StatelessWidget {
  const UIPage({super.key, required this.children});

  final List<Widget> children;
}
```

## UIGrid

[Source: lib/src/adaptive.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive.dart)

```dart
class UIGrid extends StatelessWidget {
  const UIGrid({
    super.key,
    required this.children,
    this.maxColumns = 4,
    this.minItemWidth,
  });

  final List<Widget> children;

  final int maxColumns;

  final double? minItemWidth;
}
```

## UIActions

[Source: lib/src/adaptive.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive.dart)

```dart
class UIActions extends StatelessWidget {
  const UIActions({super.key, required this.children});

  final List<Widget> children;
}
```

## UIPresentation

[Source: lib/src/adaptive_dialog.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive_dialog.dart)

```dart
enum UIPresentation { auto, dialog, sheet }
```

## UIAdaptiveDialog

[Source: lib/src/adaptive_dialog.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive_dialog.dart)

```dart
abstract final class UIAdaptiveDialog {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
    List<Widget> Function(BuildContext context)? actionsBuilder,
    UIPresentation presentation = UIPresentation.auto,
    bool dismissible = true,
    bool showClose = true,
    bool useRootNavigator = true,
    double maxWidth = 560,
    RouteSettings? routeSettings,
  });

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Hủy',
    bool danger = false,
    bool dismissible = true,
    UIPresentation presentation = UIPresentation.auto,
    bool useRootNavigator = true,
  });
}
```

## UIDestination

[Source: lib/src/adaptive_scaffold.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive_scaffold.dart)

```dart
class UIDestination {
  const UIDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;

  final IconData icon;

  final IconData? selectedIcon;
}
```

## UIAdaptiveScaffold

[Source: lib/src/adaptive_scaffold.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/adaptive_scaffold.dart)

```dart
class UIAdaptiveScaffold extends StatefulWidget {
  const UIAdaptiveScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.subtitle,
    this.supporting,
    this.supportingTitle = 'Thông tin thêm',
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation = FloatingActionButtonLocation.endFloat,
    this.contentMaxWidth = 720,
    this.supportingWidth = 240,
  });

  final String title;

  final String supportingTitle;

  final String? subtitle;

  final List<UIDestination> destinations;

  final int selectedIndex;

  final ValueChanged<int> onDestinationSelected;

  final Widget child;

  final Widget? supporting, actions, leading;

  final Widget? floatingActionButton;

  final FloatingActionButtonLocation floatingActionButtonLocation;

  final double contentMaxWidth, supportingWidth;
}
```

## UIThemeController

[Source: lib/src/app.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/app.dart)

```dart
class UIThemeController extends ChangeNotifier {
  factory UIThemeController({ThemeMode mode = ThemeMode.system});

  ThemeMode get mode;

  set mode(ThemeMode value);

  void toggle({Brightness systemBrightness = Brightness.light});
}
```

## UIApp

[Source: lib/src/app.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/app.dart)

```dart
class UIApp extends StatefulWidget {
  const UIApp({
    super.key,
    required this.primary,
    required this.home,
    this.secondary,
    this.accent,
    this.profile = UIProfile.balanced,
    this.contrastLevel = 0,
    this.fontFamily,
    this.adaptive = const UIAdaptiveConfig(),
    this.controller,
    this.initialThemeMode = ThemeMode.system,
    this.reduceMotion = false,
    this.title = '',
    this.locale,
    this.supportedLocales = const [Locale('en'), Locale('vi')],
    this.localizationsDelegates = const [],
    this.debugShowCheckedModeBanner = false,
  });

  final Locale? locale;

  final Iterable<Locale> supportedLocales;

  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;

  final Color primary;

  final Color? secondary, accent;

  final Widget home;

  final UIProfile profile;

  final double contrastLevel;

  final String? fontFamily;

  final UIAdaptiveConfig adaptive;

  final UIThemeController? controller;

  final ThemeMode initialThemeMode;

  final bool reduceMotion, debugShowCheckedModeBanner;

  final String title;

  static UIThemeController controllerOf(BuildContext context);
}
```

## UIThemeToggle

[Source: lib/src/app.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/app.dart)

```dart
class UIThemeToggle extends StatelessWidget {
  const UIThemeToggle({super.key});
}
```

## UIThemeTransition

[Source: lib/src/app.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/app.dart)

```dart
class UIThemeTransition extends StatefulWidget {
  const UIThemeTransition({
    super.key,
    required this.theme,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  final ThemeData theme;

  final Widget child;

  final Duration duration;
}
```

## UIAsyncController

[Source: lib/src/async_view.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/async_view.dart)

```dart
class UIAsyncController extends ChangeNotifier {
  bool get isLoading;

  Future<bool> reload();
}
```

## UIAsyncView

[Source: lib/src/async_view.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/async_view.dart)

```dart
class UIAsyncView<T> extends StatefulWidget {
  const UIAsyncView({
    super.key,
    required this.load,
    required this.builder,
    this.requestKey,
    this.controller,
    this.isEmpty,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onError,
    this.failureMessage = 'Chưa thể tải dữ liệu. Vui lòng thử lại.',
  });

  final Future<T> Function() load;

  final Widget Function(BuildContext context, T data) builder;

  final Object? requestKey;

  final UIAsyncController? controller;

  final bool Function(T data)? isEmpty;

  final WidgetBuilder? loadingBuilder, emptyBuilder;

  final Widget Function(
    BuildContext context,
    Object error,
    Future<bool> Function() retry,
  )?
  errorBuilder;

  final void Function(Object error, StackTrace stack)? onError;

  final String failureMessage;
}
```

## UITone

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
enum UITone { primary, secondary, accent, success, warning, danger }
```

## UIButtonVariant

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
enum UIButtonVariant { solid, soft, outline, ghost }
```

## UIProfile

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
enum UIProfile { balanced, reading, expressive }
```

## UIAccentColors

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
class UIAccentColors {
  const UIAccentColors({
    required this.solid,
    required this.onSolid,
    required this.soft,
    required this.onSoft,
    required this.border,
  });

  final Color solid, onSolid, soft, onSoft, border;
}
```

## UIControlColors

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
class UIControlColors {
  const UIControlColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background, foreground, border;
}
```

## UIContrastCheck

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
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

  double get ratio;

  bool get passed;
}
```

## YouthColors

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
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
  });

  final ColorScheme scheme;

  final Color brandPrimary;

  final Color? brandSecondary, brandAccent;

  final Map<UITone, UIAccentColors> tones;

  final Color canvas, focus, fieldBorder;

  final UIProfile profile;

  final double textContrast;

  static YouthColors of(BuildContext context);

  List<Color> get surfaces;

  UIControlColors button(
    UITone tone,
    UIButtonVariant variant,
    Set<WidgetState> states, {
    Color? surface,
  });

  List<UIContrastCheck> audit();
}
```

## UISurfaceScope

[Source: lib/src/color_engine.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/color_engine.dart)

```dart
class UISurfaceScope extends InheritedWidget {
  const UISurfaceScope({super.key, required this.color, required super.child});

  final Color color;

  static Color of(BuildContext context);
}
```

## UIButton

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UIButton extends StatelessWidget {
  const UIButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = UIButtonVariant.solid,
    this.tone = UITone.primary,
    this.icon,
    this.loading = false,
    this.fullWidth,
    this.selected,
    this.style,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.onLongPress,
  });

  final String label;

  final VoidCallback? onPressed;

  final UIButtonVariant variant;

  final UITone tone;

  final IconData? icon;

  final bool loading;

  final bool? fullWidth;

  final bool? selected;

  final ButtonStyle? style;

  final String? tooltip;

  final FocusNode? focusNode;

  final bool autofocus;

  final VoidCallback? onLongPress;
}
```

## UIInputVariant

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
enum UIInputVariant { outlined, filled }
```

## UITextField

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UITextField extends StatelessWidget {
  const UITextField({
    super.key,
    required this.label,
    this.name,
    this.hint,
    this.helper,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.readOnly = false,
    this.obscureText = false,
    this.clearable = false,
    this.initialValue,
    this.minLines,
    this.autofocus = false,
    this.errorText,
    this.prefixText,
    this.suffixText,
    this.variant = UIInputVariant.outlined,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
  });

  factory UITextField.pin({
    Key? key,
    String label = 'Mã PIN',
    int length = 6,
    bool obscureText = true,
    String? name,
    String? hint,
    String? helper,
    String? errorText,
    String? invalidCodeMessage,
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
    FocusNode? focusNode,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    Iterable<String>? autofillHints,
    TextInputAction textInputAction = TextInputAction.done,
    UIInputVariant variant = UIInputVariant.outlined,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUnfocus,
  });

  factory UITextField.search({
    Key? key,
    String label = 'Tìm kiếm',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
  });

  factory UITextField.multiline({
    Key? key,
    required String label,
    TextEditingController? controller,
    String? helper,
    int? maxLength,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  });

  final String label;

  final String? name, hint, helper;

  final TextEditingController? controller;

  final FormFieldValidator<String>? validator;

  final ValueChanged<String>? onChanged, onFieldSubmitted;

  final TextInputType? keyboardType;

  final IconData? prefixIcon;

  final bool enabled, readOnly, clearable, obscureText;

  final int maxLines;

  final int? maxLength;

  final Iterable<String>? autofillHints;

  final TextInputAction? textInputAction;

  final FocusNode? focusNode;

  final List<TextInputFormatter>? inputFormatters;

  final AutovalidateMode autovalidateMode;

  final String? initialValue, errorText, prefixText, suffixText;

  final int? minLines;

  final bool autofocus;

  final UIInputVariant variant;

  final TextCapitalization textCapitalization;
}
```

## UIPasswordField

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UIPasswordField extends StatelessWidget {
  const UIPasswordField({
    super.key,
    this.label = 'Mật khẩu',
    this.name,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.autofillHints,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.helper,
    this.errorText,
    this.variant = UIInputVariant.outlined,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
  });

  final String label;

  final String? name, helper, errorText;

  final UIInputVariant variant;

  final TextEditingController? controller;

  final FormFieldValidator<String>? validator;

  final ValueChanged<String>? onChanged, onFieldSubmitted;

  final bool enabled;

  final Iterable<String>? autofillHints;

  final FocusNode? focusNode;

  final TextInputAction? textInputAction;

  final AutovalidateMode autovalidateMode;
}
```

## UICard

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UICard extends StatefulWidget {
  const UICard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;

  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;
}
```

## UIBadge

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UIBadge extends StatelessWidget {
  const UIBadge({
    super.key,
    required this.label,
    this.tone = UITone.primary,
    this.icon,
  });

  final String label;

  final UITone tone;

  final IconData? icon;
}
```

## UIAlert

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UIAlert extends StatelessWidget {
  const UIAlert({
    super.key,
    required this.message,
    this.tone = UITone.primary,
    this.title,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.liveRegion = true,
  });

  final String message;

  final String? title;

  final UITone tone;

  final String? actionLabel;

  final VoidCallback? onAction, onDismiss;

  final bool liveRegion;
}
```

## UICheckbox

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UICheckbox extends StatelessWidget {
  const UICheckbox({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  final String? label;

  final bool value;

  final ValueChanged<bool?>? onChanged;

  final FocusNode? focusNode;

  final bool autofocus;
}
```

## UISwitch

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UISwitch extends StatelessWidget {
  const UISwitch({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  final String? label;

  final bool value;

  final ValueChanged<bool>? onChanged;

  final FocusNode? focusNode;

  final bool autofocus;
}
```

## UIToggleButton

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UIToggleButton extends StatelessWidget {
  const UIToggleButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    this.selectedIcon,
    this.tone = UITone.primary,
  });

  final String label;

  final bool value;

  final ValueChanged<bool>? onChanged;

  final IconData? icon, selectedIcon;

  final UITone tone;
}
```

## UIOption

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UIOption<T> {
  const UIOption({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;

  final String label;

  final IconData? icon;

  final bool enabled;
}
```

## UISegmentedControl

[Source: lib/src/components.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/components.dart)

```dart
class UISegmentedControl<T> extends StatelessWidget {
  const UISegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<UIOption<T>> options;

  final T value;

  final ValueChanged<T>? onChanged;
}
```

## UIDatePicker

[Source: lib/src/date_field.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/date_field.dart)

```dart
abstract final class UIDatePicker {
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    SelectableDayPredicate? selectableDayPredicate,
    Locale? locale,
    String? title,
    String? confirmLabel,
    String? cancelLabel,
    DatePickerEntryMode entryMode = DatePickerEntryMode.calendar,
    bool useRootNavigator = true,
  });

  static Future<DateTimeRange?> range(
    BuildContext context, {
    DateTimeRange? initialRange,
    DateTime? firstDate,
    DateTime? lastDate,
    Locale? locale,
    String? title,
    String? confirmLabel,
    String? cancelLabel,
    DatePickerEntryMode? entryMode,
    bool useRootNavigator = true,
  });
}
```

## UIDateField

[Source: lib/src/date_field.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/date_field.dart)

```dart
class UIDateField extends StatefulWidget {
  const UIDateField({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.name,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.validator,
    this.errorText,
    this.hint = 'Chọn ngày',
    this.invalidDateMessage = 'Ngày không nằm trong lựa chọn hợp lệ',
    this.helper,
    this.clearable = true,
    this.enabled = true,
    this.format,
    this.locale,
    this.focusNode,
    this.autofocus = false,
    this.entryMode = DatePickerEntryMode.calendar,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String label;

  final DateTime? value, firstDate, lastDate;

  final ValueChanged<DateTime?>? onChanged;

  final String? name, helper, errorText;

  final String hint, invalidDateMessage;

  final SelectableDayPredicate? selectableDayPredicate;

  final FormFieldValidator<DateTime>? validator;

  final String Function(DateTime date)? format;

  final Locale? locale;

  final bool clearable, enabled, autofocus;

  final FocusNode? focusNode;

  final DatePickerEntryMode entryMode;

  final AutovalidateMode autovalidateMode;
}
```

## UINotice

[Source: lib/src/feedback.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/feedback.dart)

```dart
abstract final class UINotice {
  static bool show(
    BuildContext context, {
    required String message,
    String? title,
    String? id,
    UITone tone = UITone.primary,
    String? actionLabel,
    VoidCallback? onAction,
    bool? persistent,
    Duration duration = const Duration(seconds: 5),
  });

  static void clear(BuildContext context);

  static void clearAll(BuildContext context);
}
```

## UIFabSize

[Source: lib/src/floating_action_button.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/floating_action_button.dart)

```dart
enum UIFabSize { small, regular, large }
```

## UIFloatingActionButton

[Source: lib/src/floating_action_button.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/floating_action_button.dart)

```dart
class UIFloatingActionButton extends StatelessWidget {
  const UIFloatingActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.label,
    this.extended,
    this.size = UIFabSize.regular,
    this.tone = UITone.primary,
    this.loading = false,
    this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.shape,
    this.elevation,
    this.focusNode,
    this.autofocus = false,
  });

  final IconData icon;

  final String tooltip;

  final VoidCallback? onPressed;

  final String? label;

  final bool? extended;

  final UIFabSize size;

  final UITone tone;

  final bool loading;

  final Object? heroTag;

  final Color? backgroundColor, foregroundColor;

  final ShapeBorder? shape;

  final double? elevation;

  final FocusNode? focusNode;

  final bool autofocus;
}
```

## UIFormException

[Source: lib/src/form.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/form.dart)

```dart
class UIFormException implements Exception {
  const UIFormException({this.message, this.fieldErrors = const {}});

  final String? message;

  final Map<String, String> fieldErrors;
}
```

## UIFormController

[Source: lib/src/form.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/form.dart)

```dart
class UIFormController extends ChangeNotifier {
  bool get isSubmitting;

  String? get error;

  Map<String, String> get fieldErrors;

  Future<bool> submit();
}
```

## UIForm

[Source: lib/src/form.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/form.dart)

```dart
class UIForm extends StatefulWidget {
  const UIForm({
    super.key,
    required this.children,
    this.formKey,
    this.controller,
    this.onSubmit,
    this.onSuccess,
    this.onError,
    this.submitLabel = 'Lưu thay đổi',
    this.maxColumns = 2,
    this.failureMessage = 'Chưa thể gửi dữ liệu. Vui lòng thử lại.',
  });

  final List<Widget> children;

  final GlobalKey<FormState>? formKey;

  final UIFormController? controller;

  final Future<void> Function()? onSubmit;

  final VoidCallback? onSuccess;

  final void Function(Object, StackTrace)? onError;

  final String submitLabel, failureMessage;

  final int maxColumns;
}
```

## UIValidators

[Source: lib/src/form.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/form.dart)

```dart
abstract final class UIValidators {
  static FormFieldValidator<String> required({
    String message = 'Vui lòng nhập thông tin.',
  });

  static FormFieldValidator<String> email({
    String message = 'Nhập email hợp lệ.',
  });

  static FormFieldValidator<String> minLength(int length, {String? message});

  static FormFieldValidator<String> combine(
    List<FormFieldValidator<String>> validators,
  );
}
```

## UIImage

[Source: lib/src/image.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/image.dart)

```dart
class UIImage extends StatefulWidget {
  const UIImage(
    this.source, {
    super.key,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.variants = const {},
    this.optimizeDecode = true,
    this.allowRetry = true,
  });

  const UIImage.avatar(
    this.source, {
    super.key,
    double size = 48,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.variants = const {},
    this.optimizeDecode = true,
    this.allowRetry = false,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
  });

  const UIImage.thumbnail(
    this.source, {
    super.key,
    double size = 80,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.variants = const {},
    this.optimizeDecode = true,
    this.allowRetry = false,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
  });

  const UIImage.banner(
    this.source, {
    super.key,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
    this.variants = const {},
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = 16,
    this.optimizeDecode = true,
    this.allowRetry = true,
  });

  const UIImage.provider(
    this.provider, {
    super.key,
    this.semanticLabel,
    this.fallbackSource,
    this.fallback,
    this.placeholder,
    this.errorBuilder,
    this.aspectRatio = 16 / 9,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = 16,
    this.optimizeDecode = true,
    this.allowRetry = false,
  });

  final String? source;

  final String? fallbackSource;

  final Widget? fallback;

  final Widget? placeholder;

  final ImageErrorWidgetBuilder? errorBuilder;

  final ImageProvider? provider;

  final String? semanticLabel;

  final double aspectRatio, borderRadius;

  final double? width, height;

  final BoxFit fit;

  final AlignmentGeometry alignment;

  final Map<int, String> variants;

  final bool optimizeDecode, allowRetry;
}
```

## UIMotion

[Source: lib/src/motion.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/motion.dart)

```dart
abstract final class UIMotion {
  static const fast = Duration(milliseconds: 160);

  static const standard = Duration(milliseconds: 240);

  static const entrance = Duration(milliseconds: 320);

  static Duration resolve(BuildContext context, Duration duration);
}
```

## UIAnimatedSize

[Source: lib/src/motion.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/motion.dart)

```dart
class UIAnimatedSize extends StatefulWidget {
  const UIAnimatedSize({
    super.key,
    required this.child,
    this.duration = UIMotion.standard,
    this.curve = Curves.easeOutCubic,
    this.alignment = AlignmentDirectional.topStart,
  });

  final Widget child;

  final Duration duration;

  final Curve curve;

  final AlignmentGeometry alignment;
}
```

## UIEntrance

[Source: lib/src/motion.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/motion.dart)

```dart
class UIEntrance extends StatefulWidget {
  const UIEntrance({
    super.key,
    required this.child,
    this.duration = UIMotion.entrance,
    this.distance = 18,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;

  final Duration duration;

  final double distance;

  final Curve curve;
}
```

## UIAnimatedContent

[Source: lib/src/motion.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/motion.dart)

```dart
class UIAnimatedContent extends StatelessWidget {
  const UIAnimatedContent({
    super.key,
    required this.child,
    this.duration = UIMotion.standard,
  });

  final Widget child;

  final Duration duration;
}
```

## UIReveal

[Source: lib/src/motion.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/motion.dart)

```dart
class UIReveal extends StatelessWidget {
  const UIReveal({
    super.key,
    required this.visible,
    required this.child,
    this.duration = UIMotion.standard,
  });

  final bool visible;

  final Widget child;

  final Duration duration;
}
```

## UISidebarVariant

[Source: lib/src/navigation.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/navigation.dart)

```dart
enum UISidebarVariant { standard, tonal, floating, contrast, outline }
```

## UINavbarVariant

[Source: lib/src/navigation.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/navigation.dart)

```dart
enum UINavbarVariant { underline, pill, filled, floating }
```

## UINavigationLayout

[Source: lib/src/navigation.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/navigation.dart)

```dart
enum UINavigationLayout { adaptive, sidebar, navbar }
```

## UINavigationItem

[Source: lib/src/navigation.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/navigation.dart)

```dart
class UINavigationItem {
  const UINavigationItem({
    required this.label,
    required this.icon,
    this.id,
    this.selectedIcon,
    this.badge,
    this.group,
    this.enabled = true,
  });

  final String label;

  final IconData icon;

  final Object? id;

  final IconData? selectedIcon;

  final String? badge, group;

  final bool enabled;
}
```

## UISidebar

[Source: lib/src/navigation.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/navigation.dart)

```dart
class UISidebar extends StatefulWidget {
  const UISidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.variant = UISidebarVariant.standard,
    this.collapsed = false,
    this.width = 264,
    this.title,
    this.subtitle,
    this.leading,
    this.footer,
    this.semanticLabel = 'Điều hướng chính',
  });

  final List<UINavigationItem> items;

  final int selectedIndex;

  final ValueChanged<int> onSelected;

  final UISidebarVariant variant;

  final bool collapsed;

  final double width;

  final String? title, subtitle;

  final Widget? leading, footer;

  final String semanticLabel;
}
```

## UINavbar

[Source: lib/src/navigation.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/navigation.dart)

```dart
class UINavbar extends StatefulWidget {
  const UINavbar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.variant = UINavbarVariant.pill,
    this.title,
    this.leading,
    this.trailing,
    this.menuLabel = 'Mở menu điều hướng',
  });

  final List<UINavigationItem> items;

  final int selectedIndex;

  final ValueChanged<int> onSelected;

  final UINavbarVariant variant;

  final String? title;

  final Widget? leading, trailing;

  final String menuLabel;
}
```

## UINavigationScaffold

[Source: lib/src/navigation.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/navigation.dart)

```dart
class UINavigationScaffold extends StatefulWidget {
  const UINavigationScaffold({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.sidebarFooter,
    this.layout = UINavigationLayout.adaptive,
    this.sidebarVariant = UISidebarVariant.floating,
    this.navbarVariant = UINavbarVariant.pill,
    this.collapsed = false,
  });

  final List<UINavigationItem> items;

  final int selectedIndex;

  final ValueChanged<int> onSelected;

  final Widget child;

  final String? title, subtitle;

  final Widget? leading, trailing, sidebarFooter;

  final UINavigationLayout layout;

  final UISidebarVariant sidebarVariant;

  final UINavbarVariant navbarVariant;

  final bool collapsed;
}
```

## UIRadio

[Source: lib/src/radio.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/radio.dart)

```dart
class UIRadio<T> extends StatelessWidget {
  const UIRadio({
    super.key,
    required this.value,
    this.label,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  });

  final T value;

  final String? label;

  final bool enabled, autofocus;

  final FocusNode? focusNode;
}
```

## UIRadioGroup

[Source: lib/src/radio.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/radio.dart)

```dart
class UIRadioGroup<T> extends StatelessWidget {
  const UIRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.direction = Axis.vertical,
  });

  final List<UIOption<T>> options;

  final T? value;

  final ValueChanged<T?>? onChanged;

  final String? label;

  final Axis direction;
}
```

## UISelect

[Source: lib/src/select.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/select.dart)

```dart
class UISelect<T> extends StatefulWidget {
  const UISelect({
    super.key,
    required this.label,
    this.name,
    this.items = const [],
    this.options = const [],
    this.initialValue,
    this.onChanged,
    this.validator,
    this.hint = 'Chọn một mục',
    this.helper,
    this.searchable,
    this.optionLabel,
    this.searchHint = 'Tìm lựa chọn…',
    this.emptyLabel = 'Không tìm thấy lựa chọn',
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  final String label, hint, searchHint, emptyLabel;

  final String? helper, name;

  final List<DropdownMenuItem<T>> items;

  final List<UIOption<T>> options;

  final T? initialValue;

  final ValueChanged<T?>? onChanged;

  final FormFieldValidator<T>? validator;

  final bool enabled, autofocus;

  final bool? searchable;

  final String Function(T)? optionLabel;

  final FocusNode? focusNode;

  final AutovalidateMode autovalidateMode;
}
```

## UIStateKind

[Source: lib/src/state_view.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/state_view.dart)

```dart
enum UIStateKind { loading, empty, error, offline, forbidden, success }
```

## UIStateView

[Source: lib/src/state_view.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/state_view.dart)

```dart
class UIStateView extends StatelessWidget {
  const UIStateView({
    super.key,
    required this.kind,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.progress,
  });

  const UIStateView.loading({
    super.key,
    this.title,
    this.message,
    this.progress,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  const UIStateView.empty({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  const UIStateView.error({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  const UIStateView.offline({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  const UIStateView.forbidden({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  const UIStateView.success({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  final UIStateKind kind;

  final String? title, message, actionLabel, secondaryActionLabel;

  final Widget? illustration;

  final VoidCallback? onAction, onSecondaryAction;

  final double? progress;
}
```

## UITableColumn

[Source: lib/src/table.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/table.dart)

```dart
class UITableColumn<T> {
  const UITableColumn({
    required this.label,
    required this.value,
    this.cellBuilder,
    this.compare,
    this.numeric = false,
    this.minWidth = 180,
  });

  final String label;

  final String Function(T row) value;

  final Widget Function(BuildContext context, T row)? cellBuilder;

  final Comparator<T>? compare;

  final bool numeric;

  final double minWidth;
}
```

## UITable

[Source: lib/src/table.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/table.dart)

```dart
class UITable<T> extends StatefulWidget {
  const UITable({
    super.key,
    required this.columns,
    required this.rows,
    this.pageSize = 10,
    this.rowKey,
    this.selectedKeys = const {},
    this.onSelectionChanged,
    this.loading = false,
    this.empty,
    this.label = 'Bảng dữ liệu',
    this.searchQuery = '',
    this.searchText,
    this.showSelectAll = false,
    this.onPageSizeChanged,
    this.pageSizeOptions = const [5, 10, 20, 50],
    this.error,
    this.onRetry,
  });

  final List<UITableColumn<T>> columns;

  final List<T> rows;

  final int pageSize;

  final Object Function(T row)? rowKey;

  final Set<Object> selectedKeys;

  final ValueChanged<Set<Object>>? onSelectionChanged;

  final bool loading;

  final Widget? empty;

  final String label;

  final String searchQuery;

  final String Function(T row)? searchText;

  final bool showSelectAll;

  final ValueChanged<int>? onPageSizeChanged;

  final List<int> pageSizeOptions;

  final String? error;

  final VoidCallback? onRetry;
}
```

## YouthThemeSet

[Source: lib/src/theme.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/theme.dart)

```dart
class YouthThemeSet {
  YouthThemeSet({
    required Color primary,
    Color? secondary,
    Color? accent,
    UIProfile profile = UIProfile.balanced,
    double contrastLevel = 0,
    String? fontFamily,
    UIAdaptiveConfig adaptive = const UIAdaptiveConfig(),
  });

  late final ThemeData light, dark;
}
```

## YouthUI

[Source: lib/src/theme.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/theme.dart)

```dart
abstract final class YouthUI {
  static YouthThemeSet colors({
    required Color primary,
    Color? secondary,
    Color? accent,
    UIProfile profile = UIProfile.balanced,
    double contrastLevel = 0,
    String? fontFamily,
    UIAdaptiveConfig adaptive = const UIAdaptiveConfig(),
  });

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
  });
}
```

## YouthPalette

[Source: lib/src/theme.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/theme.dart)

```dart
class YouthPalette extends ThemeExtension<YouthPalette> {
  const YouthPalette({required this.success, required this.warning});

  final Color success, warning;

  static YouthPalette of(BuildContext context);
}
```

## UIToneColor

[Source: lib/src/theme.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/theme.dart)

```dart
extension UIToneColor on UITone {
  Color color(BuildContext context);

  UIAccentColors colors(BuildContext context);
}
```

## UIWireframe

[Source: lib/src/wireframe.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/wireframe.dart)

```dart
class UIWireframe extends StatelessWidget {
  const UIWireframe.line({super.key, this.widthFactor = 1, this.height = 12});

  const UIWireframe.image({super.key, this.height = 140});

  const UIWireframe.avatar({super.key, double size = 48});

  const UIWireframe.card({super.key});

  const UIWireframe.list({super.key, this.count = 3});

  const UIWireframe.page({super.key, this.layout = UIWireframeLayout.feed});

  factory UIWireframe.auto({
    Key? key,
    Object? data,
    UIWireframeLayout? layout,
    List<UIWireframeField> fields = const [],
    Map<String, UIWireframeFieldType> fieldTypes = const {},
    int itemCount = 3,
  });

  UIWireframe.fromPlan({super.key, required UIWireframePlan plan});

  static UIWireframePlan inspect(
    Object? data, {
    UIWireframeLayout? layout,
    List<UIWireframeField> fields = const [],
    Map<String, UIWireframeFieldType> fieldTypes = const {},
    int itemCount = 3,
  });

  final double widthFactor, height;

  final int count;

  final UIWireframeLayout layout;
}
```

## UIWireframeLayout

[Source: lib/src/wireframe_inference.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/wireframe_inference.dart)

```dart
enum UIWireframeLayout {
  feed,
  dashboard,
  form,
  profile,
  article,
  product,
  gallery,
  chat,
  table,
  settings,
  timeline,
  detail,
  list,
  empty,
  landing,
  event,
  pricing,
}
```

## UIWireframeConfidence

[Source: lib/src/wireframe_inference.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/wireframe_inference.dart)

```dart
enum UIWireframeConfidence { explicit, high, medium, low }
```

## UIWireframeFieldType

[Source: lib/src/wireframe_inference.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/wireframe_inference.dart)

```dart
enum UIWireframeFieldType {
  text,
  paragraph,
  number,
  date,
  email,
  phone,
  image,
  avatar,
  toggle,
  choice,
  password,
  section,
}
```

## UIWireframeField

[Source: lib/src/wireframe_inference.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/wireframe_inference.dart)

```dart
class UIWireframeField {
  const UIWireframeField(this.name, {this.type = UIWireframeFieldType.text});

  final String name;

  final UIWireframeFieldType type;
}
```

## UIWireframePlan

[Source: lib/src/wireframe_inference.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/wireframe_inference.dart)

```dart
class UIWireframePlan {
  UIWireframePlan({
    required this.layout,
    required this.confidence,
    required List<String> reasons,
    required List<UIWireframeField> fields,
    required this.itemCount,
    this.isCollection = false,
  });

  final UIWireframeLayout layout;

  final UIWireframeConfidence confidence;

  final List<String> reasons;

  final List<UIWireframeField> fields;

  final int itemCount;

  final bool isCollection;
}
```

## UIWireframeInference

[Source: lib/src/wireframe_inference.dart](https://github.com/HYowshi/flutter-ui/blob/main/lib/src/wireframe_inference.dart)

```dart
class UIWireframeInference {
  static UIWireframePlan inspect(
    Object? data, {
    UIWireframeLayout? layout,
    List<UIWireframeField> fields = const [],
    Map<String, UIWireframeFieldType> fieldTypes = const {},
    int itemCount = 3,
  });
}
```
