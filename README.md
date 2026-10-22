# Flutter UI · Youth UI

Bộ widget Flutter/Dart dùng lại, khởi tạo bảng màu một lần và kế thừa trong toàn ứng dụng.

**Website:** https://hyowshi.github.io/flutter-ui/

## Có gì trong repo?

- `lib/`: package `youth_ui`, không phụ thuộc React và không dùng package runtime bên thứ ba.
- `example/`: website Flutter Web tương tác, responsive, có mã ví dụ sao chép được.
- `test/`: kiểm tra theme, tương tác, validation và giảm chuyển động.
- `.github/workflows/pages.yml`: phân tích, kiểm tra và tự xuất bản GitHub Pages.

## Dùng ngay

```yaml
dependencies:
  youth_ui:
    git:
      url: https://github.com/HYowshi/flutter-ui.git
      ref: main
```

```dart
import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

MaterialApp(
  theme: YouthUI.init(
    primary: const Color(0xFF1565C0),
    secondary: const Color(0xFFDA251D),
    accent: const Color(0xFFF9C846),
  ),
  home: const HomePage(),
);

// Trong HomePage, không cần set lại màu:
UIButton(label: 'Tiếp tục', onPressed: submit);
UITextField(label: 'Email', validator: validateEmail);
UIPasswordField();
UIBadge(label: 'Đã duyệt', tone: UITone.success);
```

`primary` bắt buộc; `secondary`, `accent`, `surface`, `background`, `brightness`, `fontFamily` tùy chọn. Material 3 sinh palette từ seed; nút chọn chữ đen/trắng theo độ sáng màu nền. Đổi `ThemeData` để đổi toàn bộ widget theo cơ chế theme của Flutter. Logo hoặc ảnh nội dung không tự đổi màu. Không có global singleton hay thiết lập lại màu ở từng widget.

Khi dùng trong dự án cùng ổ đĩa có thể thay Git dependency bằng `path: ../../Flutter UI` tùy vị trí `pubspec.yaml`. Khi cần bản ổn định, pin commit thay vì `main`.

## Components

| Widget | Chức năng / hiệu ứng |
| --- | --- |
| `UIButton` | solid, soft, outline, ghost; tone; icon; loading; disabled; Material hover/focus/ripple |
| `UITextField` | Form validation, multiline, keyboard, controller, autofill, disabled |
| `UIPasswordField` | Hiện/ẩn mật khẩu, controller, validation, autofill |
| `UISelect<T>` | Dropdown có validation và nhãn |
| `UICheckbox`, `UISwitch` | Lựa chọn với nhãn và trạng thái |
| `UICard` | Bề mặt, ripple và nâng nhẹ khi có onTap |
| `UIBadge` | Nhãn trạng thái theo tone |
| `UIAlert` | Thông báo có live-region, icon và nội dung |
| `UIEntrance` | Fade + dịch lên, 450ms; thay Key để replay |
| `UIAnimatedContent` | Fade + scale khi thay child Key, 250ms |

`UITone`: primary, secondary, accent, success, warning, danger. Success/warning lấy từ `YouthPalette` ThemeExtension, có thể override qua `ThemeData.copyWith(extensions: [...])`.

## Showcase

Đổi màu seed có sẵn hoặc nhập HEX, bật sáng/tối, chạy validation, loading, hover card, dialog và animation. Nút “Giảm chuyển động” tắt motion của widget thư viện và chuyển theme; thiết lập giảm chuyển động hệ thống được tôn trọng. Widget Material native có cơ chế animation riêng của Flutter. Demo không đăng ký tài khoản, gửi email hay thu thập dữ liệu.

```sh
flutter pub get
flutter test
cd example
flutter run -d chrome
```

## Kiểm tra và build

Yêu cầu Flutter 3.47.5 / Dart 3.13.x hoặc bản tương thích mới hơn.

```sh
flutter analyze
flutter test
cd example
flutter test
flutter build web --release --base-href /flutter-ui/ --no-web-resources-cdn
```

Workflow GitHub Pages chạy lại khi push vào `main`. Web build chứa CanvasKit cục bộ, không cần CDN renderer khi chạy. Đây là bộ nền tảng, chưa có data table hoặc date picker tùy chỉnh; chưa phát hành trên pub.dev. Các trang React trong dự án Đoàn cũ là dự án riêng và không nằm trong repo này.
