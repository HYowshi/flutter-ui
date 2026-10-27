import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

/// Local Future simulation: no website visitor data is sent to an endpoint.
class ApiConnectionDemo extends StatefulWidget {
  const ApiConnectionDemo({super.key});
  @override
  State<ApiConnectionDemo> createState() => _ApiConnectionDemoState();
}

class _ApiConnectionDemoState extends State<ApiConnectionDemo> {
  final controller = UIAsyncController();
  String mode = 'data';
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<List<String>> load() async {
    final requested = mode;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (requested == 'error') throw StateError('Simulated API failure');
    return requested == 'empty' ? [] : ['Nguyễn An', 'Trần Bình', 'Lê Chi'];
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const UIAlert(
        message:
            'API mô phỏng cục bộ. Website không gửi dữ liệu tới server. '
            'Mẫu HTTP GET/POST chạy được nằm trong api_recipe.dart.',
      ),
      const SizedBox(height: 16),
      UIActions(
        children: [
          UIButton(
            label: 'Có dữ liệu',
            onPressed: () => setState(() => mode = 'data'),
          ),
          UIButton(
            label: 'Dữ liệu rỗng',
            onPressed: () => setState(() => mode = 'empty'),
          ),
          UIButton(
            label: 'Mô phỏng lỗi',
            onPressed: () => setState(() => mode = 'error'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ListenableBuilder(
        listenable: controller,
        builder: (_, _) => UIButton(
          label: 'Tải lại API',
          loading: controller.isLoading,
          onPressed: () => unawaited(controller.reload()),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 320,
        child: UIAsyncView<List<String>>(
          controller: controller,
          requestKey: mode,
          load: load,
          isEmpty: (rows) => rows.isEmpty,
          builder: (_, rows) => SingleChildScrollView(
            child: UITable<String>(
              label: 'Kết quả API mô phỏng',
              rows: rows,
              columns: [
                UITableColumn(label: 'Thành viên', value: (row) => row),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
