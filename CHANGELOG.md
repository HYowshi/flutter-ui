## 0.8.0

- UIImage accepts absent/blank sources without asset requests; adds fallbackSource, fallback, placeholder and errorBuilder to all constructors.
- Bounded fallback chain, shared geometry/fit/clip, final UI if backup also fails; no recursive retries.
- Configurable fit/alignment/decode/variants on avatar and thumbnail; banner height/radius options.
- Respect bounded parent heights and shrink small square media uniformly; skip blank source variants.
- Retry evicts the resized cache key and ignores stale completions after source replacement/disposal, with tap deduplication and compact accessible actions.
- Expanded image gallery, custom fallback asset, regression tests and documented source nullability.

## 0.7.0

- Add UIWireframe.auto / inspect / fromPlan with bounded structural inference, evidence levels and reasons; neutral fallback for ambiguous data.
- Expand from 3 to 14 layouts, including profile, article, product, gallery, chat, table, settings, timeline, detail, list and empty.
- Infer field roles from English/Vietnamese keys and conservative value checks; explicit layout, schema and field type overrides take precedence.
- Adapt tables to cards on narrow regions/large text; retain static, theme-aware, non-interactive placeholders without displaying sample values.
- Add interactive JSON playground, malformed input feedback and regression tests for inference, bounds, semantics and responsive layouts.

## 0.6.0

- UIApp caches a light/dark theme pair and provides controller/system mode and UIThemeToggle.
- UIThemeTransition uses one bounded old-theme raster, retains live widget state, coalesces rapid requests and respects reduced motion/high contrast.
- UIImage auto-selects asset/HTTP source, stable geometry, native bucketed decode hints, source variants, static loading and safe error fallback.
- Add static theme-aware wireframe blocks and responsive feed/dashboard/form presets.
- Bound button-state cache to 128 entries per theme; reuse select search normalization, filters and measured row heights.
- Fix mobile motion-gallery overflow and keep fixed-size media inside stretched layouts.
- Add lifecycle/media/state/performance smoke regressions, local image gallery and simplified starter code.

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
