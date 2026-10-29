# Runnable youth_ui cookbook

These are complete Dart entry points in the repository's existing example Flutter project, not pseudocode. They are analyzed with the project and tested for the interactions below. Add your own services/business logic where the comments indicate.

## Start an example

From the repository root:

```sh
cd example
flutter pub get
flutter run -t lib/recipes/auth_recipe.dart
```

Choose a device as usual. For web you can add `-d chrome` or `-d web-server`. Do not run all entry points as one application. A consumer already using MaterialApp/router should integrate the page class into its existing shell.

## Login form

[Source](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/recipes/auth_recipe.dart) · [Readable source on website](auth_recipe.dart)

Run `flutter run -t lib/recipes/auth_recipe.dart` from example/.

Use this pattern for string validators, named API field errors, password input, controller ownership and managed UIForm submission. The delayed callback is a mock; no session is created. Replace it with the application's authentication service, map expected failures into UIFormException, and implement navigation/session storage in the app. Never hardcode credentials into a recipe.

## Form with date and confirmation

[Source](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/recipes/editor_recipe.dart) · [Readable source on website](editor_recipe.dart)

Run `flutter run -t lib/recipes/editor_recipe.dart` from example/.

The State owns title/date/saved. UIDateField takes the controlled value and callback, with a typed date validator. UIAdaptiveDialog.confirm returns a boolean; only an explicit confirmation changes saved. Cancellation runs no save operation. The callback guards mounted after await. This example intentionally has no UIForm.onSuccess handler: returning from onSubmit after cancel is a completed callback, not a dedicated “cancelled” submission result. If your app needs that distinction, keep it in application state or confirm before starting submission.

## Search, table and floating action

[Source](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/customization_example.dart) · [Readable source on website](customization_example.dart)

Run `flutter run -t lib/customization_example.dart` from example/.

This example adds rows in memory, filters them by search, manages selectedKeys/pageSize and places UIFloatingActionButton into the correct Scaffold slot. Row keys are unique names only because the sample dataset is constructed that way; real data should use persistent unique IDs. Use server paging for large remote datasets; UITable does not fetch API pages.

## Match other needs to real examples

- Component-specific customization: example/lib/usage_samples.dart and the corresponding demo in example/lib/main.dart. Snippets there name application-owned callbacks; they are not all standalone entry points.
- Image sources/fallback/variants: docs/images.vi.md and ImageDemo.
- Typed radio/dropdown/table values: docs/table-radio.vi.md and RadioDemo/TableDemo/DropdownDemo.
- Adaptive app frame: docs/adaptive-design.vi.md and AdaptiveDemo.
- Motion/reveal: docs/motion-input-notice.vi.md and MotionDemo.
- Screen states/overlays/date range: docs/states-dialog-date.vi.md and StateViewDemo/AdaptiveDialogDemo/DatePickerDemo.
- Wireframes and inference overrides: docs/wireframe.vi.md and WireframeDemo.

For exact constructor parameters/defaults, use [API reference](api-reference.md) for the resolved version. Do not extrapolate properties from similarly named Flutter widgets.

## HTTP API, typed Table and managed Form

[Source](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/recipes/api_recipe.dart) · [Readable source](api_recipe.dart) · [Contract and setup](api-integration.vi.md)

Run `flutter run -t lib/recipes/api_recipe.dart --dart-define=API_BASE_URL=https://your-server.example/api/` from example/. No endpoint is contacted when no base URL is supplied. This is actual injectable http.Client transport, not a deployed backend: adapt the explicitly documented member endpoints/schema. Tests mock GET/POST/422, validate model decoding and exercise form failure/correction/save/list reload. The website's API gallery intentionally uses a local Future simulation instead.

## Sidebar, navbar and adaptive shell

[Source](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/recipes/navigation_recipe.dart) · [Readable source](navigation_recipe.dart) · [Guide](navigation.vi.md)

Run `flutter run -t lib/recipes/navigation_recipe.dart` from example/. The page controls selection and collapsed state; UINavigationScaffold changes navigation layout while keeping the draft. Its app-owned callback can be replaced with the consumer router. There is no automatic route registration or API service. NavigationDemo in the studio offers five sidebar and four navbar variants.
