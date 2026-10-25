## 0.15.0

- Add UIStateView presets for loading/empty/error/offline/forbidden/success, custom illustrations/actions, bounded scrolling and reduced-motion handling.
- Add UIAdaptiveDialog.show/confirm with native dialog or bottom-sheet routes, typed results, explicit dismissal policy, keyboard-safe scrolling and shared motion timings.
- Add UIDateField with controlled date-only values, clear/cancel, bounds/predicate validation, native keyboard/calendar modes and named UIForm errors/submit locking.
- Add UIDatePicker.show/range with release-mode bounds validation and customizable native picker text/locale.
- Add optional UIApp locale/delegates/supportedLocales, built-in Material/Widgets/Cupertino localization delegates and en/vi defaults.
- Add three interactive galleries and customization recipes; expand accessibility, narrow/high-text, keyboard, form and lifecycle regression coverage.

## 0.14.0

- Add adaptive UIFloatingActionButton with three sizes, optional extended label, loading/reduced-motion handling, custom colors/shape/elevation/focus and opt-in Hero tags.
- Add FAB slots to UIAdaptiveScaffold, reserve scroll space and position above navigation/actions using native Scaffold geometry.
- Merge custom ButtonStyle over generated UIButton defaults; expose tooltip, focus, autofocus and long-press callbacks.
- Add controlled accent-insensitive local table search, page-only bulk selection, page-size controls, column minimum widths and error/retry states.
- Share Vietnamese search normalization with dropdowns; preserve cross-page selection and reset pagination on query/size changes.
- Add per-gallery customization recipes and a complete executable example, with selectable/copyable code modes and clipboard failure feedback.

## 0.13.0

- Unify motion timings, shorten entrance transitions and block invisible/outgoing interactions; animate content size without shrinking outgoing layouts.
- Add state-preserving UIReveal with hidden pointer/focus/semantics/ticker exclusion and reduced-motion support.
- Add search/multiline textbox presets, filled surfaces, initial values, affixes, line limits, external errors and animated validation height.
- Add titled, bounded scrollable notices and animated alert sizing/surfaces while preserving native shared snackbar controller behavior.
- Expand interactive motion/input/feedback examples and transition/accessibility/keyboard regressions.

## 0.12.0

- Add automatic landing/event/pricing wireframes and collection-aware product cards, with adaptive visual hierarchy.
- Inspect all bounded fields independently of the 12-field render limit; reuse normalized records and require coherent per-record evidence.
- Recognize named hero media, event dates, common API pagination metadata and one-level hero/pricing structures without recursive traversal.
- Automatically analyse showcase JSON after a 350ms debounce, retaining the last valid plan on malformed input.
- Add design research notes, sample presets and inference/responsive/lifecycle regressions.

## 0.11.1

- Preserve keyed input state when UIGrid children are reordered.

- Prevent helper queue cancellation from closing unrelated native SnackBars; add clearAll for atomic mixed-queue reset.
- Ignore async form responses after switching FormState identity, including late field errors.
- Cache table row-key validation for unchanged data and avoid sorting an already ordered unsorted index list.
- Fix image demo fallback text overflow at 320px with 200% text; audit all gallery pages at compact/desktop sizes.
- Add regression coverage for mixed notification queues, form identity, table paging work and responsive gallery navigation.

## 0.11.0

- Add optional managed UIForm submission, loading/interaction lock, deduplication, first-invalid focus/scroll, safe backend failures and stale completion guards.
- Add name-bound server errors to text/password/select inputs; blur-first text validation, live correction, clear action, formatters and character limits.
- Add composable UIValidators and optional UIFormController while preserving layout-only form calls.
- Add bounded, deduplicated UINotice queue, persistent important/action messages, one-shot undo callbacks, and adaptive wrapping actions.
- Add UIAlert actions/dismissal, interactive form/feedback demos, Vietnamese API guide and lifecycle/responsive regressions.

## 0.10.0

- Redesign Adaptive UI around task hierarchy, readable one-column forms, contextual support and deliberate mobile/tablet/desktop navigation.
- Add reusable UIAdaptiveScaffold / UIDestination with bottom navigation, compact/extended rails, constrained primary content, optional supporting pane, compact disclosure and persistent action footer.
- Retain keyed content across layout changes; respect keyboard insets, text scaling, RTL and local constraints.
- Add working profile/notification/security sample, functional save/reset, fit-to-preview zoom with a 100% inspection mode and design research notes.

## 0.9.0

- Add UIRadio / UIRadioGroup with native group keyboard navigation, local 48px hit targets, labeled semantics, disabled options and adaptive layout.
- Add typed UITable / UITableColumn with stable in-memory sorting, bounded page rendering, controlled row selection, custom cells and loading/empty states.
- Adaptive labeled cards on compact regions/large text, horizontal scrolling for wide desktop tables, automatic theme roles and RTL support.
- Interactive Table and Radio galleries, usage docs and keyboard/selection/pagination/responsive regressions.

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
