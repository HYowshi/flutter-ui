# youth_ui: guide for coding agents

Scope: the reusable Flutter/Dart package `youth_ui` in HYowshi/flutter-ui. This guide targets **0.15.0**, not a package named `flutter_ui` on pub.dev. The repository/folder name is Flutter UI; the Dart package/import is youth_ui.

## Reading order and version matching

1. Read the consumer's existing instructions, `pubspec.yaml`, `pubspec.lock`, routing/state architecture and UI entry point.
2. Resolve youth_ui's installed source path from `.dart_tool/package_config.json`. For a Git dependency, use the lockfile's resolved commit. Do not change it merely because main has newer docs.
3. Read this guide, then the relevant section of [API reference](api-reference.md) and [cookbook](ai-cookbook.md).
4. Open that version's source for unfamiliar behavior. Main's docs can describe APIs absent from an older checkout. Use that older API or propose a deliberate upgrade; do not guess parameters.

`llms.txt` and the full-text bundle are ordinary readable files. Agents may require an explicit prompt or URL; they are not guaranteed to auto-discover them. `AGENTS.md` at the library root guides contributors to the library; it does not automatically govern a separate consumer project.

## Install and import

```yaml
dependencies:
  youth_ui:
    git:
      url: https://github.com/HYowshi/flutter-ui.git
      ref: d3989fed91c4ae7021f1a2ef6e33cc349ec9cdb3
```

That commit is an immutable 0.15.0 baseline containing the three newest UI groups. `main` follows ongoing work; pin a reviewed commit for reproducibility. Run `flutter pub get` after changing dependencies. Requirements for this version: Dart ^3.13.0; Flutter >=3.47.0. Repository CI uses Flutter 3.47.5. Do not upgrade an application's SDK or dependencies without a reason required by the task.

```dart
import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

void main() => runApp(const UIApp(
  primary: Colors.indigo,
  home: Scaffold(body: UIPage(children: [Text('Hello')])),
));
```

All consumer APIs are exported by `lib/youth_ui.dart`. Do not import `lib/src/` implementation files. The signatures in the generated reference are declarations, not complete runnable applications; field declarations supply the types behind constructor parameters such as `this.controller`.

## Existing applications

Do not wrap an existing router/MaterialApp in another UIApp. UIApp creates a MaterialApp; preserve the application's navigation, providers and state management.

For MaterialApp or MaterialApp.router, compute and retain a `YouthUI.colors(primary: ..., secondary: ...)` theme pair, then assign its `.light`/`.dark` to the existing app. Recompute when seed/theme configuration changes, not per animation frame. See README for optional UIThemeTransition integration; do not animate the theme twice.

UIThemeToggle depends on the controller scope installed by UIApp. In an existing MaterialApp integration, keep the app's own theme switch/controller instead of assuming that scope exists.

## Choose an existing component

| Need | Public API |
|---|---|
| Theme/bootstrap | UIApp; YouthUI.colors; YouthUI.init; UIThemeController |
| Scrolling page / grid / actions | UIPage; UIGrid; UIActions |
| App frame with responsive navigation | UIAdaptiveScaffold + UIDestination |
| Main/secondary action | UIButton with UIButtonVariant and UITone |
| Floating primary action | UIFloatingActionButton in Scaffold's FAB slot |
| Text/password/search/notes | UITextField; UIPasswordField; UITextField.search; UITextField.multiline |
| Form submission and validation | UIForm; UIFormController; UIFormException; UIValidators |
| Boolean / multiple choice | UICheckbox; UISwitch; UIToggleButton; UISegmentedControl |
| Single choice / dropdown | UIRadioGroup + UIOption; UISelect + UIOption |
| Cards / status / feedback | UICard; UIBadge; UIAlert; UINotice |
| Image loading and fallback | UIImage; .avatar; .thumbnail; .banner; .provider |
| Tabular in-memory data | UITable + UITableColumn |
| Loading/empty/error/offline/access/success view | UIStateView (caller supplies state) |
| Modal editing / confirmation | UIAdaptiveDialog.show<T>; .confirm |
| Single date / range | UIDateField; UIDatePicker.show; .range |
| Entrance / content change / reveal | UIEntrance; UIAnimatedContent; UIAnimatedSize; UIReveal |
| Static layout placeholder | UIWireframe.auto; .page; .fromPlan; inspect |

Use ordinary Flutter widgets for features the library does not provide. Do not invent APIs such as UIUpload, UIAutocomplete, UITable.server or UIApp.router. A new missing feature should be explicit application code or a separately authorized library addition.

## Theme and layout

- Seed colors belong at app initialization. Prefer `tone`, `variant`, `Theme.of(context).colorScheme` and textTheme over hardcoded per-widget colors. Keep business-status colors consistent.
- UIButton.style merges only supplied properties over defaults. If overriding background/foreground, check the pair in light/dark, disabled and focused states. Other widgets do not automatically accept ButtonStyle or arbitrary decoration parameters.
- Reuse local-constraint-based layout. UIPage owns vertical scrolling and limits readable width; do not casually nest it inside another vertical scroll view. UIGrid wraps columns and preserves keyed children.
- UITable and wireframe page content expect the parent to own vertical scrolling. Use UIPage or an existing scroll view. Bound grids/navigation frames where required; do not place Expanded in an unbounded vertical scrollable.
- UIAdaptiveScaffold requires 2–5 destinations and a valid selectedIndex. It owns a Scaffold/scrolling body; avoid nesting another Scaffold unless intentional.
- Put UIFloatingActionButton in `Scaffold.floatingActionButton` or the matching UIAdaptiveScaffold slot. In a plain Scaffold, reserve final scroll space when content can sit underneath it. Default Hero tag is null; opt-in tags must be unique per route except the corresponding transition pair.

## State and lifecycle ownership

- Create TextEditingController, FocusNode, UIThemeController and UIFormController outside build (usually State.initState). Dispose those the application creates. A supplied UIFormController has only one mounted owner.
- Keep controlled values in application state: checkbox/switch/radio/segmented values, date value, table selectedKeys/pageSize/query. Update them in callbacks.
- `initialValue` initializes text/select fields. It is not a general controlled-value API. Do not pass a nonexistent `UISelect.value`. Reset intentionally with an appropriate key/state reset when the record changes.
- UITextField accepts either controller or initialValue, not both. Changing initialValue does not overwrite an ongoing edit. Search/multiline convenience factories expose fewer options than the main constructor; use the main constructor when a preset lacks an option.
- Check mounted/context.mounted after await before touching UI. Ignore stale responses when the edited record changes. Widgets guard their own lifecycles, not all caller-owned futures.

## Forms and notices

UIForm can be layout-only. Supplying onSubmit enables validation, loading/duplicate-submit protection, field locking and error feedback. UIFormController.submit() returns whether a managed submit succeeded. Keep network/authentication/storage in the application's callback.

Match field `name` to `UIFormException(fieldErrors: {...})` keys on UITextField, UIPasswordField, UISelect or UIDateField. Treat unexpected exceptions as user-safe failures; log/report diagnostic details through application code. Do not show raw server stack traces.

UIValidators.required/email/minLength/combine validate **strings**. For dates or typed choices, provide validators of the appropriate type. Do not apply UIValidators.required() to UIDateField.

UINotice.show returns a bool indicating whether the notice was accepted, not an awaitable user decision. Its queue is bounded at five and deduplicates active/queued notices. Action/danger notices persist by default. UIAlert is appropriate for durable in-page errors; UIAdaptiveDialog.confirm is for an explicit decision.

Use UINotice.clear for helper notices. When mixing native SnackBars and helper notices, use UINotice.clearAll for an intentional full reset; calling native clearSnackBars directly can discard helper queue futures. Neither helper sends messages or performs undo/business operations on its own.

## Images, tables and wireframes

UIImage source is String?; null/blank means unavailable. Error handling order: errorBuilder override, otherwise try fallbackSource once, then fallback widget, then default error UI. Assets need pubspec entries. Web HTTP images need valid server CORS; the widget cannot bypass it. Variant URLs reduce downloaded bytes; native decode hints are not a web bandwidth optimizer. No disk/offline cache is supplied.

UITable uses in-memory filtering/sorting/paging, not server pagination. Provide stable unique rowKey for selection; maintain selectedKeys in the app. showSelectAll affects the displayed page and preserves other selected keys. Replace rows/columns collections when data changes; do not mutate a cached collection and expect detection. Keep definitions stable where practical to reuse caches. Supply plain column.value/searchText even when cellBuilder draws richer content.

UIWireframe.auto inspects bounded JSON-like data heuristically. It renders placeholders, not data values, real forms, validators, network content or functional screens. Confidence is heuristic evidence, not an accuracy probability. Supply layout/schema overrides for known screens; inspect/fromPlan can reuse an immutable plan. Do not present this as an AI model or recursive arbitrary-data parser.

## States, overlays and dates

UIStateView doesn't detect connectivity, permissions or cache availability. The caller supplies kind and meaningful user-facing text/actions. A visual offline state is not offline storage.

UIAdaptiveDialog chooses sheet/dialog at opening time and retains the route on resize. Use builder/actionsBuilder routeContext to pop the correct route, especially with nested navigators. Content needing local edits should be a separate StatefulWidget/StatefulBuilder. Keep children bounded/scroll-compatible. dismissible:false blocks outside/Back/drag, while explicit close/pop remains possible. The wrapper doesn't restore route state or transport every provider from below the navigator.

UIDateField is controlled: update value in onChanged; cancel retains it, clear sends null. Dates/ranges are date-only, not timezone-aware timestamps. Bounds/predicate validation and UIForm name errors are supported; business rules and server validation still belong to the app. Range default input mode may adapt on narrow/large-text screens. UIApp supplies localization delegates with en/vi defaults; configure locale/supportedLocales or existing MaterialApp localization deliberately. Business strings are not automatically translated.

## Motion, performance and accessibility

- Respect platform reduced motion and high contrast. No new perpetual shimmer/blur effect is needed for a routine state.
- UIReveal retains the mounted child, form validation and service work; it blocks hidden focus/pointers/semantics/tickers. It does not virtualize lists or cancel network requests.
- Use stable keys for stateful/reordered items and changing keys to replay an entrance or distinguish AnimatedContent children.
- Preserve native keyboard navigation, meaningful tooltips, readable labels and touch targets. Avoid overflow with narrow widths/large text/RTL. A passing test suite is not an FPS or zero-bug guarantee.
- Use lazy lists and server-side work for genuinely large data; don't build every row in a giant Column.

## Verify an integration

Run `flutter analyze` and the app's appropriate tests. For repository examples, run tests from example/. Exercise changed behavior, not only compilation: submit/failure/retry, keyboard, cancellation, light/dark, constrained width and large text. Do not claim platform performance measurements that were not actually made.

If editing the library, follow repository AGENTS.md, regenerate AI docs and run the documentation check. These files guide implementation; they are not permission to deploy, delete repositories or message people.
