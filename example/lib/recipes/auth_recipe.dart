import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

void main() => runApp(const UIApp(primary: Colors.indigo, home: AuthRecipe()));

/// Demonstrates UI only. Replace the submission callback with your auth service.
class AuthRecipe extends StatefulWidget {
  const AuthRecipe({super.key});
  @override
  State<AuthRecipe> createState() => _AuthRecipeState();
}

class _AuthRecipeState extends State<AuthRecipe> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Đăng nhập'),
      actions: const [UIThemeToggle()],
    ),
    body: UIPage(
      children: [
        const Text('Ví dụ giao diện; chưa kết nối dịch vụ xác thực.'),
        UIForm(
          maxColumns: 1,
          submitLabel: 'Đăng nhập mẫu',
          onSubmit: () async {
            // Replace with await authService.signIn(email.text.trim(), password.text).
            // Expected API errors can throw UIFormException with named fieldErrors.
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          onSuccess: () => UINotice.show(
            context,
            message: 'Biểu mẫu hợp lệ. Chưa tạo phiên đăng nhập thật.',
            tone: UITone.success,
          ),
          children: [
            UITextField(
              name: 'email',
              label: 'Email',
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              validator: UIValidators.combine([
                UIValidators.required(),
                UIValidators.email(),
              ]),
            ),
            UIPasswordField(
              name: 'password',
              controller: password,
              autofillHints: const [AutofillHints.password],
              validator: UIValidators.combine([
                UIValidators.required(),
                UIValidators.minLength(8),
              ]),
            ),
          ],
        ),
      ],
    ),
  );
}
