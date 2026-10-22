## 0.5.0

- Replace the default dropdown route with a themed MenuAnchor popup and compact-touch bottom sheet.
- Shared state colors, rounded rows, selection marks, variable-height labels, bounded scrolling and keyboard focus.
- UIOption-based select declarations; preserve DropdownMenuItem compatibility, callbacks and form validation/reset.
- Automatic search for 8+ labeled options, Vietnamese accent-insensitive matching, clear action and empty state.
- Lazy menu rows, measured initial selection scroll, keyboard navigation through offscreen options and disabled-item skipping.
- Dropdown gallery and regression coverage for desktop/mobile, large text, keyboard insets, RTL/edges and owner disposal.

## 0.4.0

- Automatic local-width adaptation, mouse-aware spacing and system text scaling.
- UIPage / UIForm / UIGrid / UIActions remove repeated page and form breakpoint code.
- Buttons auto-fill narrow bounded regions; long button/badge text wraps instead of truncating.
- Segmented controls measure label width and switch to stacked choices when needed.
- Adaptive field/card padding, content-height dropdown items and bounded dropdown menus.
- UIAdaptiveConfig is optional in the existing one-time initializer, with defaults for all widgets.
- Interactive mobile/tablet/desktop preview, resize/state-preservation and large-text regression tests.
- Migration: UIButton.fullWidth defaults to auto (nullable); UICard.padding defaults to adaptive (nullable). Explicit existing overrides remain supported.

## 0.3.0

- Add UIToggleButton and typed UISegmentedControl / UIOption.
- Redesign checkbox and switch with compact local hover/focus, optional labels and 48px-high touch targets.
- Preserve native keyboard interaction and named control semantics; labels and unused row space no longer toggle controls.
- Generic reusable showcase examples and a dedicated selection-controls gallery.
- Regression coverage for control-only hit regions, keyboard activation, disabled options and selected state.

## 0.2.0

- One/two seed theme-pair initialization with YouthUI.colors.
- HCT role families, semantic color resolver, layer-aware state contrast.
- Reading/balanced/expressive profiles, high-contrast controls and public audit.
- Independent brand seeds, mode-aware action colors; no fixed red/yellow defaults.
- Matrix tests and research-to-implementation documentation.
- Breaking behavior: generated primary can differ from seed; original remains brandPrimary.

## 0.1.0

- Flutter theme factory YouthUI.init.
- Reusable components and reduced-motion-aware transitions.
- Interactive web showcase, tests and GitHub Pages workflow.
