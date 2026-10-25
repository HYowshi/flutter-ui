# Working on youth_ui

This repository is the Flutter/Dart library `youth_ui` and its showcase, not a consumer application's backend. Start with `llms.txt`, `docs/ai-guide.md`, and the installed version in `pubspec.yaml`.

- Public imports go through `package:youth_ui/youth_ui.dart`. Treat source and the resolved package version as authoritative; never invent constructor parameters.
- Keep existing APIs compatible unless the user requests a breaking change. Use theme roles and local constraints; preserve keyboard/focus, large text, RTL and reduced-motion behavior.
- Application networking, permissions, storage, routing and business rules remain with the caller. Do not describe demos as real services.
- Follow controller ownership and lifecycle rules in the AI guide. Make examples executable under `example/lib/`, not just plausible snippets.
- After changing public APIs or AI guides, run `python tool/generate_ai_docs.py` and `python tool/generate_ai_docs.py --check`. Generated API documentation and the full-text bundle must stay synchronized.
- Format Dart changes, run `flutter analyze`, and run tests appropriate to the change. Run showcase tests from `example/` when changing recipes or demos. CI also verifies documentation and compiles the web showcase.
- Do not edit `docs/api-reference.md` or `llms-full.txt` manually. Edit source/curated guides and regenerate them.
- `docs/consumer-agents.md` is a template for another project's instructions; it is not a request to modify unrelated projects.

For consumer integration guidance, use `docs/ai-guide.md`. For public API constructors/defaults and parameter field types, use `docs/api-reference.md`. For runnable examples, use `examples/README.md`.
