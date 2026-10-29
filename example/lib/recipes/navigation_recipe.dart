import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

const navigationItems = [
  UINavigationItem(
    id: 'home',
    label: 'Tổng quan',
    icon: Icons.home_outlined,
    group: 'WORKSPACE',
  ),
  UINavigationItem(
    id: 'projects',
    label: 'Dự án',
    icon: Icons.folder_outlined,
    badge: '8',
    group: 'WORKSPACE',
  ),
  UINavigationItem(
    id: 'inbox',
    label: 'Tin nhắn',
    icon: Icons.chat_outlined,
    badge: '12',
    group: 'WORKSPACE',
  ),
  UINavigationItem(
    id: 'settings',
    label: 'Cài đặt',
    icon: Icons.settings_outlined,
    group: 'QUẢN LÝ',
  ),
];

void main() =>
    runApp(const UIApp(primary: Colors.indigo, home: NavigationRecipe()));

/// Reuse this page inside the consumer's existing app/router; no nested UIApp.
class NavigationRecipe extends StatefulWidget {
  const NavigationRecipe({super.key});
  @override
  State<NavigationRecipe> createState() => _NavigationRecipeState();
}

class _NavigationRecipeState extends State<NavigationRecipe> {
  int selected = 0;
  bool collapsed = false;
  @override
  Widget build(BuildContext context) => UINavigationScaffold(
    title: 'Forma',
    subtitle: 'Design workspace',
    items: navigationItems,
    selectedIndex: selected,
    onSelected: (index) => setState(() => selected = index),
    sidebarVariant: UISidebarVariant.floating,
    navbarVariant: UINavbarVariant.pill,
    collapsed: collapsed,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Thu gọn / mở rộng',
          icon: const Icon(Icons.view_sidebar_outlined),
          onPressed: () => setState(() => collapsed = !collapsed),
        ),
        const UIThemeToggle(),
      ],
    ),
    child: UIPage(
      children: [
        Text('WORKSPACE / ${navigationItems[selected].label.toUpperCase()}'),
        Text(
          navigationItems[selected].label,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const Text('Thay nội dung này bằng trang hoặc router của ứng dụng.'),
        UITextField.multiline(label: 'Bản nháp'),
        const UIAlert(
          message: 'Thử resize cửa sổ: nội dung đang nhập được giữ khi đổi Sidebar/Navbar.',
        ),
      ],
    ),
  );
}
