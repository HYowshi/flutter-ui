import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_ui/youth_ui.dart';
import 'package:flutter_ui_showcase/recipes/auth_recipe.dart';
import 'package:flutter_ui_showcase/recipes/editor_recipe.dart';

void main() {
  testWidgets('auth recipe validates and completes only a mock submission', (
    tester,
  ) async {
    await tester.pumpWidget(
      const UIApp(
        primary: Colors.indigo,
        locale: Locale('en'),
        home: AuthRecipe(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng nhập mẫu'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập thông tin.'), findsNWidgets(2));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'example-pass');
    await tester.ensureVisible(find.text('Đăng nhập mẫu'));
    await tester.tap(find.text('Đăng nhập mẫu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(
      find.text('Biểu mẫu hợp lệ. Chưa tạo phiên đăng nhập thật.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor recipe wires controlled date and never saves on cancel', (
    tester,
  ) async {
    await tester.pumpWidget(
      const UIApp(
        primary: Colors.teal,
        locale: Locale('en'),
        home: EditorRecipe(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Lịch tư vấn');
    final picked = DateTime(2026, 11, 25);
    // Native date selection is tested in the library; exercise this page's binding.
    tester.widget<UIDateField>(find.byType(UIDateField)).onChanged!(picked);
    await tester.pumpAndSettle();
    expect(tester.widget<UIDateField>(find.byType(UIDateField)).value, picked);
    await tester.ensureVisible(find.text('Lưu lịch hẹn mẫu'));
    await tester.tap(find.text('Lưu lịch hẹn mẫu'));
    // Form remains busy while confirmation is open, so its spinner is active.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Đã lưu mẫu'), findsNothing);
    await tester.tap(find.text('Lưu lịch hẹn mẫu'));
    // Form remains busy while confirmation is open, so its spinner is active.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Xác nhận lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Đã lưu mẫu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
