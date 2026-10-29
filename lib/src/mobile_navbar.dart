part of 'navigation.dart';

enum UIMobileNavbarVariant { standard, pill, floating, dock, centerAction }

/// Mobile bottom navigation with safe-area/keyboard handling. Uses controlled
/// selection; actions never select a destination. Extra destinations use More.
class UIMobileNavbar extends StatefulWidget {
  const UIMobileNavbar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.variant = UIMobileNavbarVariant.standard,
    this.onAction,
    this.actionIcon = Icons.add_rounded,
    this.actionLabel = 'Tạo mới',
    this.moreLabel = 'Thêm',
    this.hideOnKeyboard = true,
    this.useSafeArea = true,
    this.maxWidth = 560,
  });
  final List<UINavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final UIMobileNavbarVariant variant;
  final VoidCallback? onAction;
  final IconData actionIcon;
  final String actionLabel, moreLabel;
  final bool hideOnKeyboard, useSafeArea;
  final double maxWidth;
  @override
  State<UIMobileNavbar> createState() => _UIMobileNavbarState();
}

class _UIMobileNavbarState extends State<UIMobileNavbar> {
  bool _menuOpen = false;
  Object? _layoutSignature;

  Future<void> _more(List<int> indices, {bool includeAction = false}) async {
    if (_menuOpen) return;
    _menuOpen = true;
    final items = List<UINavigationItem>.of(widget.items);
    final actionIdentity = (widget.actionLabel, widget.actionIcon);
    final menu = [
      for (final index in indices) items[index],
      if (includeAction)
        UINavigationItem(
          label: widget.actionLabel,
          icon: widget.actionIcon,
          group: 'Hành động',
          enabled: widget.onAction != null,
        ),
    ];
    final selected = indices.indexOf(widget.selectedIndex);
    try {
      final result = await UIAdaptiveDialog.show<int>(
        context,
        title: widget.moreLabel,
        maxWidth: 420,
        builder: (routeContext) => SizedBox(
          height: math.min(420, MediaQuery.sizeOf(routeContext).height * .55),
          child: UISidebar(
            items: menu,
            selectedIndex: selected,
            width: 420,
            onSelected: (i) =>
                Navigator.of(routeContext)
                    .pop(i == indices.length ? -2 : indices[i]),
          ),
        ),
      );
      if (!mounted || result == null) return;
      if (result == -2) {
        if (includeAction &&
            actionIdentity == (widget.actionLabel, widget.actionIcon)) {
          widget.onAction?.call();
        }
        return;
      }
      if (result < 0 ||
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
    if (!widget.maxWidth.isFinite || widget.maxWidth < 120) {
      throw ArgumentError.value(
        widget.maxWidth,
        'maxWidth',
        'Must be finite and >= 120',
      );
    }
    if (widget.actionLabel.trim().isEmpty || widget.moreLabel.trim().isEmpty) {
      throw ArgumentError('Action and More labels must not be blank.');
    }
    if (widget.hideOnKeyboard && MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    final s = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(11) / 11;
    final floating = widget.variant != UIMobileNavbarVariant.standard;
    final inverse = widget.variant == UIMobileNavbarVariant.dock;
    final surface = inverse ? s.primary : s.surfaceContainerLowest;
    final foreground = inverse ? s.onPrimary : s.onSurfaceVariant;
    final active = inverse ? s.onPrimary : s.primary;
    final onActive = inverse ? s.primary : s.onPrimary;
    final captionHeight = MediaQuery.textScalerOf(context).scale(11) * 2.4;
    final itemHeight = 32 + 4 + captionHeight + 16;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final safeInsets = widget.useSafeArea
            ? MediaQuery.paddingOf(context)
            : EdgeInsets.zero;
        final width = math.min(
          math.max(0.0, viewport - safeInsets.horizontal),
          widget.maxWidth,
        );
        final margin = floating && width >= 160 ? 12.0 : 0.0;
        final usable = math.max(0.0, width - margin * 2 - 16);
        if (usable < 48) return const SizedBox.shrink();
        final wantsAction =
            widget.variant == UIMobileNavbarVariant.centerAction;
        final showAction = wantsAction && usable >= 160;
        final horizontal =
            widget.variant == UIMobileNavbarVariant.pill &&
            scale <= 1.3 &&
            usable >= 260;
        var capacity = math.max(
          1,
          math.min(
            showAction ? 4 : 5,
            ((usable - (showAction ? 64 : 0)) / 48).floor() -
                (horizontal ? 1 : 0),
          ),
        );
        if (showAction && capacity == 3) capacity = 2;
        final hiddenAction = wantsAction && !showAction;
        final overflow = widget.items.length > capacity || hiddenAction;
        final primaryCount = overflow
            ? math.min(widget.items.length, capacity - 1)
            : widget.items.length;
        final indices = List.generate(primaryCount, (i) => i);
        final hidden = [
          for (var i = primaryCount; i < widget.items.length; i++) i,
        ];
        final visible = [
          for (final i in indices) widget.items[i],
          if (overflow)
            UINavigationItem(
              label: widget.moreLabel,
              icon: Icons.more_horiz_rounded,
            ),
        ];
        final activeSlot = widget.selectedIndex < primaryCount
            ? widget.selectedIndex
            : widget.selectedIndex >= 0 && overflow
            ? visible.length - 1
            : -1;
        final signature = (width, visible.length, horizontal, showAction);
        final duration = _layoutSignature == signature
            ? UIMotion.resolve(context, UIMotion.fast)
            : Duration.zero;
        _layoutSignature = signature;
        Widget destination(int slot, double itemWidth) {
          final more = overflow && slot == visible.length - 1;
          return AnimatedContainer(
            key: ValueKey(more ? 'more' : slot),
            width: itemWidth,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: Padding(
              padding: EdgeInsets.only(top: showAction ? 20 : 0),
              child: _MobileDestination(
                item: visible[slot],
                selected: slot == activeSlot,
                horizontal: horizontal,
                variant: widget.variant,
                foreground: foreground,
                active: active,
                onActive: onActive,
                height: itemHeight,
                captionHeight: captionHeight,
                onTap: more
                    ? () =>
                          unawaited(_more(hidden, includeAction: hiddenAction))
                    : () => widget.onSelected(indices[slot]),
              ),
            ),
          );
        }

        final totalUnits =
            visible.length + (horizontal && activeSlot >= 0 ? 1 : 0);
        Widget links(List<int> slots, double available) => Row(
          children: [
            for (final slot in slots)
              destination(
                slot,
                horizontal
                    ? usable / totalUnits * (slot == activeSlot ? 2 : 1)
                    : available / slots.length,
              ),
          ],
        );
        final mid = (visible.length / 2).ceil();
        final row = showAction
            ? Row(
                children: [
                  SizedBox(
                    width: (usable - 64) / 2,
                    child: links(
                      List.generate(mid, (i) => i),
                      (usable - 64) / 2,
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    height: itemHeight + 20,
                    child: _action(context, captionHeight),
                  ),
                  SizedBox(
                    width: (usable - 64) / 2,
                    child: links([
                      for (var i = mid; i < visible.length; i++) i,
                    ], (usable - 64) / 2),
                  ),
                ],
              )
            : links(List.generate(visible.length, (i) => i), usable);
        Widget bar = Padding(
          padding: EdgeInsets.fromLTRB(
            margin,
            floating ? 8 : 0,
            margin,
            floating ? 12 : 0,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: showAction ? 20 : 0,
                child: Material(
                  color: surface,
                  elevation: floating ? 3 : 0,
                  shadowColor: s.shadow.withValues(alpha: .18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      inverse
                          ? 34
                          : floating
                          ? 26
                          : 0,
                    ),
                    side: floating && !inverse
                        ? BorderSide(color: s.outlineVariant)
                        : BorderSide.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: row,
              ),
            ],
          ),
        );
        Widget result = Align(
          heightFactor: 1,
          child: SizedBox(
            width: width,
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              label: 'Điều hướng dưới',
              child: FocusTraversalGroup(child: bar),
            ),
          ),
        );
        if (widget.useSafeArea) result = SafeArea(top: false, child: result);
        return ColoredBox(
          color: floating ? Colors.transparent : surface,
          child: result,
        );
      },
    );
  }

  Widget _action(BuildContext context, double captionHeight) {
    final s = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.actionLabel,
      button: true,
      enabled: widget.onAction != null,
      onTap: widget.onAction,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox.square(
              dimension: 56,
              child: FloatingActionButton(
                heroTag: null,
                tooltip: widget.actionLabel,
                onPressed: widget.onAction,
                backgroundColor: s.primary,
                foregroundColor: s.onPrimary,
                elevation: 4,
                shape: const CircleBorder(),
                child: Icon(widget.actionIcon, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: captionHeight,
              child: Center(
                child: Text(
                  widget.actionLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: s.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileDestination extends StatelessWidget {
  const _MobileDestination({
    required this.item,
    required this.selected,
    required this.horizontal,
    required this.variant,
    required this.foreground,
    required this.active,
    required this.onActive,
    required this.height,
    required this.captionHeight,
    required this.onTap,
  });
  final UINavigationItem item;
  final bool selected, horizontal;
  final UIMobileNavbarVariant variant;
  final Color foreground, active, onActive;
  final double height, captionHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final inverse = variant == UIMobileNavbarVariant.dock;
    final color = !item.enabled
        ? foreground.withValues(alpha: .4)
        : selected
        ? inverse
              ? onActive
              : active
        : foreground;
    final glyph = selected && !horizontal
        ? inverse
              ? onActive
              : variant == UIMobileNavbarVariant.floating
              ? s.onPrimary
              : s.onPrimaryContainer
        : color;
    final label = item.badge == null
        ? item.label
        : '${item.label}, ${item.badge}';
    Widget icon = SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Icon(
              selected ? item.selectedIcon ?? item.icon : item.icon,
              size: 24,
              color: glyph,
            ),
          ),
          if (item.badge != null && item.badge!.isNotEmpty)
            PositionedDirectional(
              top: -3,
              end: -8,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 32),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: inverse ? s.onPrimary : s.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.badge!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: inverse ? s.primary : s.onSecondaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (!horizontal) {
      icon = Container(
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          color: selected
              ? inverse
                    ? active
                    : variant == UIMobileNavbarVariant.floating
                    ? s.primary
                    : s.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            variant == UIMobileNavbarVariant.floating ? 12 : 20,
          ),
        ),
        child: Center(child: icon),
      );
    }
    final text = Text(
      item.label,
      textAlign: TextAlign.center,
      maxLines: horizontal ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: horizontal ? 12 : 11,
        height: 1.15,
        color: !item.enabled
            ? foreground.withValues(alpha: .4)
            : selected && horizontal
            ? s.onPrimaryContainer
            : selected && !inverse
            ? s.primary
            : foreground,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    return Tooltip(
      message: item.badge == null
          ? item.label
          : '${item.label} · ${item.badge}',
      excludeFromSemantics: true,
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        enabled: item.enabled,
        onTap: item.enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: horizontal && selected
                ? s.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            animationDuration: UIMotion.resolve(context, UIMotion.fast),
            child: InkWell(
              onTap: item.enabled ? onTap : null,
              excludeFromSemantics: true,
              focusColor: foreground.withValues(alpha: .16),
              hoverColor: foreground.withValues(alpha: .08),
              child: ExcludeSemantics(
                child: SizedBox(
                  height: height - 16,
                  child: horizontal
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              icon,
                              if (selected) ...[
                                const SizedBox(width: 4),
                                Flexible(child: text),
                              ],
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            icon,
                            const SizedBox(height: 4),
                            SizedBox(
                              height: captionHeight,
                              child: Align(child: text),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
