import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'adaptive_dialog.dart';
import 'motion.dart';

part 'mobile_navbar.dart';

enum UISidebarVariant { standard, tonal, floating, contrast, outline }

enum UINavbarVariant { underline, pill, filled, floating }

enum UINavigationLayout { adaptive, sidebar, navbar, mobile }

/// A controlled navigation destination. The application owns routing.
@immutable
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

void _checkNavigation(List<UINavigationItem> items, int selectedIndex) {
  if (items.isEmpty || items.any((item) => item.label.trim().isEmpty)) {
    throw ArgumentError('Navigation needs items with nonblank labels.');
  }
  if (selectedIndex < -1 || selectedIndex >= items.length) {
    throw RangeError.index(selectedIndex, items, 'selectedIndex');
  }
}

Object _identity(UINavigationItem item) =>
    item.id ?? (item.label, item.icon, item.group);

enum _LinkStyle { block, pill, line, outline }

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.foreground,
    required this.selectedColor,
    required this.onSelectedColor,
    this.style = _LinkStyle.block,
    this.compact = false,
    this.horizontal = false,
    this.marker = false,
  });
  final UINavigationItem item;
  final bool selected, compact, horizontal, marker;
  final VoidCallback onTap;
  final Color foreground, selectedColor, onSelectedColor;
  final _LinkStyle style;

  @override
  Widget build(BuildContext context) {
    final color = !item.enabled
        ? foreground.withValues(alpha: .4)
        : selected
        ? onSelectedColor
        : foreground;
    final radius = BorderRadius.circular(style == _LinkStyle.pill ? 28 : 12);
    final badge = item.badge;
    return Tooltip(
      message: badge == null ? item.label : '${item.label} · $badge',
      excludeFromSemantics: true,
      child: Semantics(
        label: badge == null ? item.label : '${item.label}, $badge',
        button: true,
        selected: selected,
        enabled: item.enabled,
        onTap: item.enabled ? onTap : null,
        child: Material(
          color:
              selected &&
                  style != _LinkStyle.line &&
                  style != _LinkStyle.outline
              ? selectedColor
              : Colors.transparent,
          animationDuration: UIMotion.resolve(context, UIMotion.fast),
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: selected && style == _LinkStyle.outline
                ? BorderSide(color: onSelectedColor, width: 1.5)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: Builder(
            builder: (linkContext) => InkWell(
              excludeFromSemantics: true,
              onTap: item.enabled ? onTap : null,
              onFocusChange: (focused) {
                if (focused) {
                  unawaited(
                    Scrollable.ensureVisible(
                      linkContext,
                      duration: UIMotion.resolve(context, UIMotion.fast),
                      alignment: .5,
                    ),
                  );
                }
              },
              focusColor: color.withValues(alpha: .16),
              hoverColor: color.withValues(alpha: .08),
              splashColor: color.withValues(alpha: .12),
              child: ExcludeSemantics(
                child: Stack(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 8 : 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: compact
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          mainAxisSize: horizontal
                              ? MainAxisSize.min
                              : MainAxisSize.max,
                          children: [
                            Icon(
                              selected
                                  ? item.selectedIcon ?? item.icon
                                  : item.icon,
                              size: 22,
                              color: color,
                            ),
                            if (!compact) ...[
                              const SizedBox(width: 12),
                              Flexible(
                                fit: horizontal ? FlexFit.loose : FlexFit.tight,
                                child: Text(
                                  item.label,
                                  maxLines: horizontal ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (badge != null && badge.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 46,
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: .1),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      child: Text(
                                        badge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (selected && (marker || style == _LinkStyle.line))
                      PositionedDirectional(
                        start: style == _LinkStyle.line ? 14 : 0,
                        end: style == _LinkStyle.line ? 14 : null,
                        top: style == _LinkStyle.line ? null : 12,
                        bottom: style == _LinkStyle.line ? 0 : 12,
                        width: style == _LinkStyle.line ? null : 3,
                        height: style == _LinkStyle.line ? 3 : null,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bounded, scrollable navigation with five visual treatments and an icon rail.
/// Give it a finite height (Scaffold/Expanded/SizedBox). Slots must fit its width.
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
  @override
  State<UISidebar> createState() => _UISidebarState();
}

class _UISidebarState extends State<UISidebar> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkNavigation(widget.items, widget.selectedIndex);
    if (!widget.width.isFinite || widget.width < 64) {
      throw ArgumentError.value(
        widget.width,
        'width',
        'Must be finite and >= 64',
      );
    }
    final s = Theme.of(context).colorScheme;
    final inverse = widget.variant == UISidebarVariant.contrast;
    final surface = inverse
        ? s.primary
        : switch (widget.variant) {
            UISidebarVariant.tonal => s.surfaceContainerLow,
            _ => s.surfaceContainerLowest,
          };
    final foreground = inverse ? s.onPrimary : s.onSurface;
    final selectedColor = inverse
        ? s.onPrimary
        : widget.variant == UISidebarVariant.tonal
        ? s.primary
        : s.primaryContainer;
    final onSelectedColor = inverse
        ? s.primary
        : widget.variant == UISidebarVariant.tonal
        ? s.onPrimary
        : widget.variant == UISidebarVariant.outline
        ? s.primary
        : s.onPrimaryContainer;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          throw FlutterError(
            'UISidebar requires bounded height. Use Expanded or SizedBox.',
          );
        }
        final width = math.min(
          widget.collapsed ? 80.0 : widget.width,
          constraints.maxWidth,
        );
        if (width < 64 || constraints.maxHeight == 0) {
          return const SizedBox.shrink();
        }
        final compact = widget.collapsed || width < 200;
        final floating = widget.variant == UISidebarVariant.floating;
        final entries = <({int? index, String? group})>[];
        String? previousGroup;
        for (var i = 0; i < widget.items.length; i++) {
          final group = widget.items[i].group;
          if (!compact &&
              group != null &&
              group.isNotEmpty &&
              group != previousGroup) {
            entries.add((index: null, group: group));
          }
          previousGroup = group;
          entries.add((index: i, group: null));
        }
        return SizedBox(
          width: width,
          child: Padding(
            padding: EdgeInsets.all(floating ? 6 : 0),
            child: Material(
              color: surface,
              elevation: floating ? 2 : 0,
              shadowColor: s.shadow.withValues(alpha: .14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(floating ? 24 : 0),
                side: widget.variant == UISidebarVariant.outline
                    ? BorderSide(color: s.outlineVariant)
                    : BorderSide.none,
              ),
              clipBehavior: Clip.antiAlias,
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                label: widget.semanticLabel,
                child: FocusTraversalGroup(
                  child: Scrollbar(
                    controller: _scroll,
                    child: CustomScrollView(
                      controller: _scroll,
                      primary: false,
                      slivers: [
                        if (widget.title != null ||
                            widget.subtitle != null ||
                            widget.leading != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                compact ? 10 : 18,
                                22,
                                compact ? 10 : 18,
                                20,
                              ),
                              child: Row(
                                mainAxisAlignment: compact
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                                children: [
                                  SizedBox.square(
                                    dimension: 36,
                                    child:
                                        widget.leading ??
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: foreground.withValues(
                                              alpha: .09,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              11,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.layers_outlined,
                                            color: foreground,
                                            size: 22,
                                          ),
                                        ),
                                  ),
                                  if (!compact &&
                                      (widget.title != null ||
                                          widget.subtitle != null)) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (widget.title != null)
                                            Text(
                                              widget.title!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: foreground,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -.4,
                                              ),
                                            ),
                                          if (widget.subtitle != null)
                                            Text(
                                              widget.subtitle!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: foreground,
                                                fontSize: 11,
                                                height: 1.5,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 8 : 12,
                          ),
                          sliver: SliverList.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, position) {
                              final entry = entries[position];
                              if (entry.index == null) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    14,
                                    18,
                                    8,
                                    10,
                                  ),
                                  child: Semantics(
                                    header: true,
                                    child: Text(
                                      entry.group!,
                                      style: TextStyle(
                                        color: foreground,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final index = entry.index!;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: _NavLink(
                                  item: widget.items[index],
                                  selected: index == widget.selectedIndex,
                                  onTap: () => widget.onSelected(index),
                                  foreground: foreground,
                                  selectedColor: selectedColor,
                                  onSelectedColor: onSelectedColor,
                                  compact: compact,
                                  marker:
                                      widget.variant ==
                                      UISidebarVariant.standard,
                                  style: switch (widget.variant) {
                                    UISidebarVariant.outline =>
                                      _LinkStyle.outline,
                                    UISidebarVariant.floating =>
                                      _LinkStyle.pill,
                                    _ => _LinkStyle.block,
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.footer != null)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(compact ? 8 : 16),
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(color: foreground),
                                  child: IconTheme(
                                    data: IconThemeData(color: foreground),
                                    child: widget.footer!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Top navigation. Narrow layouts use a native adaptive menu instead of
/// squeezing links; wide layouts retain horizontal scroll for long labels.
class UINavbar extends StatefulWidget {
  /// Mobile bottom navigation. Use in Scaffold.bottomNavigationBar.
  static UIMobileNavbar mobile({
    Key? key,
    required List<UINavigationItem> items,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
    UIMobileNavbarVariant variant = UIMobileNavbarVariant.standard,
    VoidCallback? onAction,
    IconData actionIcon = Icons.add_rounded,
    String actionLabel = 'Tạo mới',
    String moreLabel = 'Thêm',
    double maxWidth = 560,
    bool hideOnKeyboard = true,
    bool useSafeArea = true,
  }) => UIMobileNavbar(
    key: key,
    items: items,
    selectedIndex: selectedIndex,
    onSelected: onSelected,
    variant: variant,
    onAction: onAction,
    actionIcon: actionIcon,
    actionLabel: actionLabel,
    moreLabel: moreLabel,
    maxWidth: maxWidth,
    hideOnKeyboard: hideOnKeyboard,
    useSafeArea: useSafeArea,
  );

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
  @override
  State<UINavbar> createState() => _UINavbarState();
}

class _UINavbarState extends State<UINavbar> {
  bool _menuOpen = false;
  Future<void> _openMenu() async {
    if (_menuOpen) return;
    _menuOpen = true;
    final items = List<UINavigationItem>.of(widget.items);
    final selectedIndex = widget.selectedIndex;
    try {
      final result = await UIAdaptiveDialog.show<int>(
        context,
        title: widget.title ?? 'Điều hướng',
        maxWidth: 420,
        builder: (routeContext) => SizedBox(
          height: math.min(420, MediaQuery.sizeOf(routeContext).height * .55),
          child: UISidebar(
            items: items,
            selectedIndex: selectedIndex,
            width: 420,
            variant: UISidebarVariant.tonal,
            onSelected: (index) => Navigator.of(routeContext).pop(index),
          ),
        ),
      );
      if (!mounted ||
          result == null ||
          result < 0 ||
          result >= items.length ||
          result >= widget.items.length) {
        return;
      }
      if (_identity(items[result]) == _identity(widget.items[result]) &&
          widget.items[result].enabled) {
        widget.onSelected(result);
      }
    } finally {
      _menuOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkNavigation(widget.items, widget.selectedIndex);
    final s = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final floating = widget.variant == UINavbarVariant.floating;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = width < 760 || scale > 1.4;
        return SizedBox(
          width: width,
          child: Padding(
            padding: EdgeInsets.all(floating ? 8 : 0),
            child: Material(
              color: widget.variant == UINavbarVariant.filled
                  ? s.surfaceContainerLow
                  : s.surfaceContainerLowest,
              elevation: floating ? 2 : 0,
              shadowColor: s.shadow.withValues(alpha: .14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(floating ? 28 : 0),
                side: floating
                    ? BorderSide(color: s.outlineVariant)
                    : BorderSide.none,
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 18,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    if (compact) ...[
                      IconButton(
                        tooltip: widget.menuLabel,
                        icon: const Icon(Icons.menu_rounded),
                        onPressed: _openMenu,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (widget.leading != null &&
                        (!compact || width >= 360)) ...[
                      SizedBox.square(dimension: 32, child: widget.leading!),
                      const SizedBox(width: 10),
                    ],
                    if (widget.title != null)
                      if (compact)
                        Expanded(child: _brand(context))
                      else
                        SizedBox(
                          width: math.min(180 * scale, width * .22),
                          child: _brand(context),
                        ),
                    if (!compact)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          primary: false,
                          child: Row(
                            children: [
                              for (var i = 0; i < widget.items.length; i++)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 6,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 220 * scale,
                                    ),
                                    child: _NavLink(
                                      item: widget.items[i],
                                      selected: i == widget.selectedIndex,
                                      onTap: () => widget.onSelected(i),
                                      foreground: s.onSurface,
                                      selectedColor:
                                          widget.variant ==
                                              UINavbarVariant.filled
                                          ? s.primary
                                          : s.primaryContainer,
                                      onSelectedColor: switch (widget.variant) {
                                        UINavbarVariant.filled => s.onPrimary,
                                        UINavbarVariant.underline => s.primary,
                                        _ => s.onPrimaryContainer,
                                      },
                                      horizontal: true,
                                      style:
                                          widget.variant ==
                                              UINavbarVariant.underline
                                          ? _LinkStyle.line
                                          : _LinkStyle.pill,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (!compact)
                      IconButton(
                        tooltip: widget.menuLabel,
                        icon: const Icon(Icons.more_horiz_rounded),
                        onPressed: _openMenu,
                      ),
                    if (compact && widget.title == null) const Spacer(),
                    if (widget.trailing != null && width >= 280) ...[
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: math.max(0, math.min(200, width * .3)),
                        ),
                        child: widget.trailing!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _brand(BuildContext context) => Text(
    widget.title!,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.4),
  );
}

/// Ready-to-use shell. Owns a Scaffold, not a router or a page scroll view.
/// The content subtree retains state across sidebar/navbar breakpoint changes.
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
    this.mobileNavbarVariant = UIMobileNavbarVariant.standard,
    this.onMobileAction,
    this.mobileActionIcon = Icons.add_rounded,
    this.mobileActionLabel = 'Tạo mới',
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
  final UIMobileNavbarVariant mobileNavbarVariant;
  final VoidCallback? onMobileAction;
  final IconData mobileActionIcon;
  final String mobileActionLabel;
  final bool collapsed;
  @override
  State<UINavigationScaffold> createState() => _UINavigationScaffoldState();
}

class _UINavigationScaffoldState extends State<UINavigationScaffold> {
  final _content = GlobalKey();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final sidebar =
          widget.layout != UINavigationLayout.navbar &&
          widget.layout != UINavigationLayout.mobile &&
          scale <= 1.5 &&
          constraints.maxWidth >=
              (widget.layout == UINavigationLayout.sidebar ? 760 : 1024);
      final mobile =
          widget.layout == UINavigationLayout.mobile ||
          (!sidebar && constraints.maxWidth < 760);
      final content = KeyedSubtree(key: _content, child: widget.child);
      return Scaffold(
        appBar: mobile
            ? AppBar(
                title: widget.title == null
                    ? null
                    : Text(
                        widget.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                leading: widget.leading == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: widget.leading,
                      ),
                actions: [
                  if (widget.trailing != null)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * .42,
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: widget.trailing,
                      ),
                    ),
                ],
              )
            : null,
        bottomNavigationBar: mobile
            ? UIMobileNavbar(
                items: widget.items,
                selectedIndex: widget.selectedIndex,
                onSelected: widget.onSelected,
                variant: widget.mobileNavbarVariant,
                onAction: widget.onMobileAction,
                actionIcon: widget.mobileActionIcon,
                actionLabel: widget.mobileActionLabel,
              )
            : null,
        body: SafeArea(
          child: sidebar
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UISidebar(
                      items: widget.items,
                      selectedIndex: widget.selectedIndex,
                      onSelected: widget.onSelected,
                      title: widget.title,
                      subtitle: widget.subtitle,
                      leading: widget.leading,
                      footer: widget.sidebarFooter,
                      collapsed: widget.collapsed,
                      variant: widget.sidebarVariant,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          if (widget.trailing != null)
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: widget.trailing,
                              ),
                            ),
                          Expanded(child: content),
                        ],
                      ),
                    ),
                  ],
                )
              : mobile
              ? content
              : Column(
                  children: [
                    UINavbar(
                      items: widget.items,
                      selectedIndex: widget.selectedIndex,
                      onSelected: widget.onSelected,
                      title: widget.title,
                      leading: widget.leading,
                      trailing: widget.trailing,
                      variant: widget.navbarVariant,
                    ),
                    Expanded(child: content),
                  ],
                ),
        ),
      );
    },
  );
}
