# Executable examples

All recipes use the existing Flutter project in `example/`; no second pubspec is needed.

```sh
cd example
flutter pub get
flutter run -t lib/recipes/auth_recipe.dart
flutter run -t lib/recipes/editor_recipe.dart
flutter run -t lib/customization_example.dart
```

Run one command/entry point at a time, choosing the device normally used by your Flutter project.

| Example | Source | Demonstrates |
|---|---|---|
| Login form | [auth_recipe.dart](../example/lib/recipes/auth_recipe.dart) | Controllers/dispose, named fields, validation, managed submission and notices |
| Date editor | [editor_recipe.dart](../example/lib/recipes/editor_recipe.dart) | Controlled date, async confirmation, mounted guards and explicit in-memory state |
| Searchable list | [customization_example.dart](../example/lib/customization_example.dart) | Theme, search, table selection/paging and FAB |
| Component studio | [main.dart](../example/lib/main.dart) | All galleries and component-specific customization examples |

Each recipe is a complete entry point. Consumer projects already using a router should reuse the page/widget portion and their existing app shell, rather than nesting UIApp. Mock callbacks are marked explicitly and do not provide real authentication, networking or persistence.

The recipes are included in `flutter analyze` and exercised in `example/test/recipes_test.dart`. More focused behavior/limits are covered by the library's tests and detailed guides. See [AI cookbook](../docs/ai-cookbook.md).
