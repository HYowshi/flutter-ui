import 'package:flutter/material.dart';

import 'adaptive.dart';

@immutable
class UIDestination {
  const UIDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

/// A bounded app frame: bottom navigation, rail or sidebar; readable primary
/// content and an optional supporting pane. Local constraints, not device names.
class UIAdaptiveScaffold extends StatefulWidget {
  const UIAdaptiveScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.subtitle,
    this.supporting,
    this.supportingTitle = 'Thông tin thêm',
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation = FloatingActionButtonLocation.endFloat,
    this.contentMaxWidth = 720,
    this.supportingWidth = 240,
  });
  final String title;
  final String supportingTitle;
  final String? subtitle;
  final List<UIDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final Widget? supporting, actions, leading;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final double contentMaxWidth, supportingWidth;
  @override
  State<UIAdaptiveScaffold> createState() => _UIAdaptiveScaffoldState();
}

class _UIAdaptiveScaffoldState extends State<UIAdaptiveScaffold> {
  final _content = GlobalKey();
  final _support = GlobalKey();
  final _actions = GlobalKey();
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.destinations.length < 2 || widget.destinations.length > 5) {
      throw ArgumentError('UIAdaptiveScaffold supports 2–5 destinations.');
    }
    if (widget.selectedIndex < 0 ||
        widget.selectedIndex >= widget.destinations.length) {
      throw RangeError.index(
        widget.selectedIndex,
        widget.destinations,
        'selectedIndex',
      );
    }
    if (!widget.contentMaxWidth.isFinite ||
        widget.contentMaxWidth < 280 ||
        !widget.supportingWidth.isFinite ||
        widget.supportingWidth < 160) {
      throw ArgumentError(
        'contentMaxWidth >= 280 and supportingWidth >= 160 must be finite.',
      );
    }
    return UIAdaptiveBuilder(
      builder: (context, ui) {
        final s = Theme.of(context).colorScheme;
        final bottom = ui.compact || ui.textScale > 1.5;
        final sidebar = ui.expanded && ui.textScale <= 1.25;
        final navWidth = bottom
            ? 0.0
            : sidebar
            ? 192.0
            : 88.0;
        final gutter = ui.compact ? 20.0 : 28.0;
        final available = ui.width - navWidth - gutter * 2;
        final split =
            widget.supporting != null &&
            available >=
                (440 * ui.textScale.clamp(1, 2)) + 24 + widget.supportingWidth;
        final content = KeyedSubtree(key: _content, child: widget.child);
        final supporting = widget.supporting == null
            ? null
            : KeyedSubtree(key: _support, child: widget.supporting!);
        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.title,
                style:
                    (ui.compact
                            ? Theme.of(context).textTheme.headlineSmall
                            : Theme.of(context).textTheme.headlineMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.6,
                        ),
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: TextStyle(color: s.onSurfaceVariant, height: 1.6),
              ),
            ],
            const SizedBox(height: 28),
            if (split)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 24),
                  SizedBox(width: widget.supportingWidth, child: supporting),
                ],
              )
            else ...[
              content,
              if (supporting != null) ...[
                const SizedBox(height: 24),
                if (ui.compact)
                  ExpansionTile(
                    title: Text(
                      widget.supportingTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    maintainState: true,
                    children: [supporting],
                  )
                else
                  supporting,
              ],
            ],
          ],
        );
        final Widget? footer = widget.actions == null
            ? null
            : Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 12),
                decoration: BoxDecoration(
                  color: s.surfaceContainerLowest,
                  border: Border(top: BorderSide(color: s.outlineVariant)),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: widget.contentMaxWidth,
                    ),
                    child: KeyedSubtree(key: _actions, child: widget.actions!),
                  ),
                ),
              );
        final navigation = NavigationBar(
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          height: 80 + 32 * (ui.textScale - 1).clamp(0, 2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final d in widget.destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon ?? d.icon),
                label: d.label,
              ),
          ],
        );
        final main = Expanded(
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _scroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      gutter,
                      gutter,
                      gutter +
                          (widget.floatingActionButton == null
                              ? 0
                              : 112 * ui.textScale.clamp(1, 2)),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              widget.contentMaxWidth +
                              (split ? 24 + widget.supportingWidth : 0),
                        ),
                        child: body,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.actions != null && widget.floatingActionButton == null)
                footer!,
            ],
          ),
        );
        return Scaffold(
          floatingActionButton: widget.floatingActionButton,
          floatingActionButtonLocation: widget.floatingActionButtonLocation,
          backgroundColor: s.surface,
          bottomNavigationBar:
              widget.floatingActionButton == null || (!bottom && footer == null)
              ? null
              : SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [?footer, if (bottom) navigation],
                  ),
                ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!bottom)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: s.surfaceContainerLow,
                            border: BorderDirectional(
                              end: BorderSide(color: s.outlineVariant),
                            ),
                          ),
                          child: NavigationRail(
                            selectedIndex: widget.selectedIndex,
                            onDestinationSelected: widget.onDestinationSelected,
                            backgroundColor: Colors.transparent,
                            minWidth: 88,
                            minExtendedWidth: 192,
                            extended: sidebar,
                            scrollable: true,
                            groupAlignment: -1,
                            leading: widget.leading,
                            labelType: sidebar
                                ? NavigationRailLabelType.none
                                : NavigationRailLabelType.all,
                            destinations: [
                              for (final d in widget.destinations)
                                NavigationRailDestination(
                                  icon: Icon(d.icon),
                                  selectedIcon: Icon(d.selectedIcon ?? d.icon),
                                  label: Text(d.label),
                                ),
                            ],
                          ),
                        ),
                      main,
                    ],
                  ),
                ),
                if (bottom && widget.floatingActionButton == null) navigation,
              ],
            ),
          ),
        );
      },
    );
  }
}
