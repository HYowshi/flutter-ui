# Template for a project using youth_ui

Copy/adapt the block below into your application's existing AGENTS.md or the equivalent context file your coding assistant reads. Merge it with existing instructions; do not replace them. If your assistant does not read such files automatically, paste the starter prompt and link explicitly.

```markdown
## Flutter UI library

This app uses `youth_ui` from https://github.com/HYowshi/flutter-ui.
Start with https://hyowshi.github.io/flutter-ui/llms.txt and
https://hyowshi.github.io/flutter-ui/ai/ai-guide.md.

- Verify the version/commit resolved in pubspec.lock and inspect the installed
  source via .dart_tool/package_config.json. That version's source wins over
  newer online docs. Do not silently upgrade dependencies or invent parameters.
- Import package:youth_ui/youth_ui.dart and prefer its existing components.
- Keep this app's router/providers/state architecture. UIApp creates a
  MaterialApp; use cached YouthUI.colors themes for an existing MaterialApp.
- Initialize theme once; prefer tone/variant and theme roles. Follow local
  constraints, large text, keyboard/focus and reduced-motion conventions.
- The app owns controllers it creates, async work, networking, permissions,
  storage and business logic. Dispose owned controllers; guard UI after await.
- Use runnable examples and the API reference for unfamiliar widgets.
- Run flutter analyze and tests appropriate to the change, then report what
  was verified and any concrete limitations.
```

## Prompt to paste into another AI

> Dự án này dùng youth_ui từ HYowshi/flutter-ui. Đọc https://hyowshi.github.io/flutter-ui/llms.txt rồi ai-guide trước khi viết UI. Kiểm tra phiên bản thực tế trong pubspec.lock; dùng API đúng phiên bản đó. Ưu tiên component có sẵn, giữ router/state/theme hiện tại và chạy flutter analyze sau khi sửa.

For offline work, download llms-full.txt, or point the agent at a local checkout and its docs/ai-guide.md. A guide cannot make an AI remember the library permanently; include the reference again when starting a new session without that context.
