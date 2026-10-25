import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

void main() => runApp(const UIApp(primary: Colors.indigo, home: CustomPage()));

class CustomPage extends StatefulWidget {
  const CustomPage({super.key});
  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  final search = TextEditingController();
  final rows = <String>['An', 'Bình', 'Chi', 'Dũng'];
  Set<Object> selected = {};
  int pageSize = 5;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void addItem() {
    setState(() => rows.add('Thành viên ${rows.length + 1}'));
    UINotice.show(context, title: 'Đã thêm', message: rows.last);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Danh sách của tôi'),
      actions: const [UIThemeToggle()],
    ),
    floatingActionButton: UIFloatingActionButton(
      icon: Icons.add_rounded,
      tooltip: 'Thêm thành viên',
      label: 'Thêm thành viên',
      onPressed: addItem,
    ),
    body: UIPage(
      children: [
        UITextField.search(
          controller: search,
          onChanged: (_) => setState(() {}),
        ),
        UITable<String>(
          rows: List.unmodifiable(rows),
          searchQuery: search.text,
          pageSize: pageSize,
          onPageSizeChanged: (n) => setState(() => pageSize = n),
          rowKey: (name) => name,
          selectedKeys: selected,
          showSelectAll: true,
          onSelectionChanged: (keys) => setState(() => selected = keys),
          columns: [
            UITableColumn(
              label: 'Tên',
              value: (name) => name,
              compare: (a, b) => a.compareTo(b),
            ),
          ],
        ),
        // Khoảng cuối để FAB không che hàng cuối khi cuộn hết.
        const SizedBox(height: 120),
      ],
    ),
  );
}
