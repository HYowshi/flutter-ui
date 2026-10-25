import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

void main() => runApp(
  const UIApp(primary: Colors.teal, locale: Locale('vi'), home: EditorRecipe()),
);

/// Controlled date, local controller lifecycle, confirmation and mounted guards.
class EditorRecipe extends StatefulWidget {
  const EditorRecipe({super.key});
  @override
  State<EditorRecipe> createState() => _EditorRecipeState();
}

class _EditorRecipeState extends State<EditorRecipe> {
  final title = TextEditingController();
  DateTime? date;
  bool saved = false;

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lịch hẹn mẫu')),
    body: UIPage(
      children: [
        UIForm(
          maxColumns: 1,
          submitLabel: 'Lưu lịch hẹn mẫu',
          onSubmit: () async {
            final accepted = await UIAdaptiveDialog.confirm(
              context,
              title: 'Lưu lịch hẹn?',
              message: 'Ví dụ chỉ lưu trạng thái trong bộ nhớ.',
              confirmLabel: 'Xác nhận lưu',
            );
            if (!mounted || !accepted) return;
            // Persist through the application's service here, then guard mounted.
            setState(() => saved = true);
          },
          children: [
            UITextField(
              name: 'title',
              label: 'Tiêu đề',
              controller: title,
              validator: UIValidators.required(),
            ),
            UIDateField(
              name: 'date',
              label: 'Ngày hẹn',
              value: date,
              onChanged: (value) => setState(() => date = value),
              validator: (value) => value == null ? 'Hãy chọn ngày hẹn.' : null,
            ),
          ],
        ),
        if (saved)
          const UIAlert(
            title: 'Đã lưu mẫu',
            message: 'Dữ liệu ở trong bộ nhớ; chưa ghi vào máy chủ.',
            tone: UITone.success,
          ),
      ],
    ),
  );
}
