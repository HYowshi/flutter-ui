import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

const navigationItems = [
  UINavigationItem(
    id: 'home',
    label: 'Tổng quan',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard_rounded,
    group: 'WORKSPACE',
  ),
  UINavigationItem(
    id: 'projects',
    label: 'Dự án',
    icon: Icons.folder_open_outlined,
    selectedIcon: Icons.folder_rounded,
    badge: '8',
    group: 'WORKSPACE',
  ),
  UINavigationItem(
    id: 'inbox',
    label: 'Tin nhắn',
    icon: Icons.chat_bubble_outline_rounded,
    badge: '12',
    group: 'WORKSPACE',
  ),
  UINavigationItem(
    id: 'team',
    label: 'Thành viên',
    icon: Icons.people_outline_rounded,
    group: 'QUẢN LÝ',
  ),
  UINavigationItem(
    id: 'settings',
    label: 'Cài đặt',
    icon: Icons.tune_rounded,
    group: 'QUẢN LÝ',
  ),
];

const sidebarNames = ['Workspace', 'Tonal', 'Floating', 'Contrast', 'Outline'];
const navbarNames = ['Underline', 'Pill', 'Filled', 'Floating'];

class NavigationDemo extends StatefulWidget {
  const NavigationDemo({super.key});
  @override
  State<NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationDemo> {
  UISidebarVariant sidebar = UISidebarVariant.floating;
  UINavbarVariant navbar = UINavbarVariant.pill;
  int selected = 1;
  bool collapsed = false;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(
          context,
          '01',
          'Sidebar collection',
          'Năm cách tổ chức không gian. Cùng một bộ dữ liệu và theme.',
        ),
        const SizedBox(height: 18),
        UIGrid(
          maxColumns: 5,
          minItemWidth: 140,
          children: [
            for (final variant in UISidebarVariant.values)
              _StyleTile(
                label: sidebarNames[variant.index],
                selected: sidebar == variant,
                onTap: () => setState(() => sidebar = variant),
                inverse: variant == UISidebarVariant.contrast,
                rounded: variant == UISidebarVariant.floating,
                outlined: variant == UISidebarVariant.outline,
              ),
          ],
        ),
        const SizedBox(height: 18),
        UISwitch(
          label: 'Thu gọn thành icon rail',
          value: collapsed,
          onChanged: (value) => setState(() => collapsed = value),
        ),
        const SizedBox(height: 16),
        Container(
          height: 560,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: s.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: s.outlineVariant),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                if (constraints.maxWidth < 620) const Spacer(),
                UISidebar(
                  width: constraints.maxWidth.clamp(64, 264).toDouble(),
                  items: navigationItems,
                  selectedIndex: selected,
                  onSelected: (i) => setState(() => selected = i),
                  variant: sidebar,
                  collapsed: collapsed,
                  title: 'Forma',
                  subtitle: 'Design workspace',
                  footer: _Profile(
                    compact: collapsed || constraints.maxWidth < 200,
                  ),
                ),
                if (constraints.maxWidth >= 620)
                  Expanded(
                    child: NavigationWorkspace(
                      title: navigationItems[selected].label,
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        _section(
          context,
          '02',
          'Navbar collection',
          'Bốn nhịp điệu cho ứng dụng và website. Vùng hẹp mở menu riêng.',
        ),
        const SizedBox(height: 18),
        UIGrid(
          maxColumns: 4,
          minItemWidth: 150,
          children: [
            for (final variant in UINavbarVariant.values)
              _StyleTile(
                label: navbarNames[variant.index],
                selected: navbar == variant,
                onTap: () => setState(() => navbar = variant),
                horizontal: true,
                rounded: variant == UINavbarVariant.floating,
                outlined: variant == UINavbarVariant.underline,
              ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 340,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: s.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: s.outlineVariant),
          ),
          child: Column(
            children: [
              UINavbar(
                items: navigationItems,
                selectedIndex: selected,
                onSelected: (i) => setState(() => selected = i),
                title: 'Forma',
                variant: navbar,
                leading: Icon(Icons.layers_rounded, color: s.primary),
                trailing: CircleAvatar(
                  radius: 16,
                  backgroundColor: s.secondaryContainer,
                  foregroundColor: s.onSecondaryContainer,
                  child: const Text('LN', style: TextStyle(fontSize: 11)),
                ),
              ),
              Expanded(
                child: NavigationWorkspace(
                  title: navigationItems[selected].label,
                  minimal: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const UIAlert(
          message:
              'Chọn mục để thử tương tác. Mở menu ở vùng hẹp, dùng Tab/Enter trên PC. '
              'Màu sắc đi theo theme; đây là dữ liệu giao diện mẫu, không tạo route hoặc gọi dịch vụ.',
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    String number,
    String title,
    String description,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$number / NAVIGATION',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          letterSpacing: 1.7,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -.7,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        description,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.6,
        ),
      ),
    ],
  );
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.inverse = false,
    this.rounded = false,
    this.outlined = false,
    this.horizontal = false,
  });
  final String label;
  final bool selected, inverse, rounded, outlined, horizontal;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final background = inverse ? s.primary : s.surfaceContainerLow;
    final ink = inverse ? s.onPrimary : s.primary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: s.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? s.primary : s.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(rounded ? 16 : 7),
                  ),
                  child: horizontal
                      ? Row(
                          children: [
                            for (var i = 0; i < 3; i++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: i == 0
                                          ? ink
                                          : ink.withValues(alpha: .16),
                                      borderRadius: BorderRadius.circular(
                                        outlined ? 2 : 12,
                                      ),
                                    ),
                                    child: const SizedBox(height: 9),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < 3; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: FractionallySizedBox(
                                  widthFactor: i == 0 ? .9 : .62,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == 0
                                          ? ink
                                          : ink.withValues(alpha: .2),
                                      borderRadius: BorderRadius.circular(
                                        rounded ? 9 : 2,
                                      ),
                                      border: outlined && i == 0
                                          ? Border.all(color: ink)
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: s.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final color =
        DefaultTextStyle.of(context).style.color ??
        Theme.of(context).colorScheme.onSurface;
    final avatar = CircleAvatar(
      radius: 17,
      backgroundColor: color.withValues(alpha: .1),
      foregroundColor: color,
      child: const Text(
        'LN',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
    if (compact) return Tooltip(message: 'Linh Nguyễn', child: avatar);
    return Row(
      children: [
        avatar,
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Linh Nguyễn',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                'Personal workspace',
                maxLines: 2,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Decorative application content shared by the gallery and executable recipe.
class NavigationWorkspace extends StatelessWidget {
  const NavigationWorkspace({
    super.key,
    required this.title,
    this.minimal = false,
  });
  final String title;
  final bool minimal;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return UIPage(
      children: [
        Text(
          'WORKSPACE / ${title.toUpperCase()}',
          style: TextStyle(
            color: s.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -.8,
          ),
        ),
        Text(
          'Một góc nhìn rõ ràng cho công việc hôm nay.',
          style: TextStyle(color: s.onSurfaceVariant, height: 1.6),
        ),
        if (!minimal) ...[
          UIGrid(
            maxColumns: 2,
            minItemWidth: 120,
            children: [
              for (final stat in [
                ('08', 'Dự án đang chạy'),
                ('24', 'Đầu việc tuần này'),
              ])
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: s.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.$1,
                        style: TextStyle(
                          color: s.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stat.$2,
                        style: TextStyle(
                          color: s.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: s.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thiết kế tiếp theo',
                  style: TextStyle(
                    color: s.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Một hệ giao diện. Nhiều cách thể hiện.',
                  style: TextStyle(
                    color: s.onPrimaryContainer,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: .72,
                    minHeight: 5,
                    color: s.primary,
                    backgroundColor: s.onPrimaryContainer.withValues(alpha: .1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
