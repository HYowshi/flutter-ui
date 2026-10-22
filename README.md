# Flutter UI · Youth UI 0.3

Bộ Flutter/Dart UI dùng lại cho mobile, desktop và web, không gắn với một ứng dụng hay một bộ màu thương hiệu. Truyền **một hoặc hai màu**, nhận theme sáng/tối và để widget tự chọn màu theo vai trò.

**[Website tương tác](https://hyowshi.github.io/flutter-ui/)** · **[Nghiên cứu và quyết định thuật toán](docs/color-research.vi.md)**

## Dùng nhanh

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

final ui = YouthUI.colors(
  primary: const Color(0xFF1565C0),
  // secondary: const Color(0xFFDA251D), // tùy chọn
);

MaterialApp(
  theme: ui.light,
  darkTheme: ui.dark,
  themeMode: ThemeMode.system,
  home: const HomePage(),
);

// Bên dưới, không truyền màu lại:
UIButton(label: 'Tiếp tục', onPressed: submit);
UITextField(label: 'Email', validator: validateEmail);
UIPasswordField();
UIBadge(label: 'Đã xác nhận', tone: UITone.success);
```

Tạo ui một lần ở cấp ứng dụng. Pin commit khi cần dependency ổn định thay vì dùng main.

## Khởi tạo nâng cao

```dart
YouthUI.init(
  primary: const Color(0xFF1565C0),
  secondary: const Color(0xFFDA251D), // optional second seed
  accent: const Color(0xFFF9C846),   // optional third seed
  profile: UIProfile.reading,
  contrastLevel: 1,
  brightness: Brightness.dark,
);
```

- `primary` bắt buộc; secondary/accent thiếu sẽ **tự sinh**, không mặc định đỏ/vàng.
- `UIProfile.balanced`: mặc định. `reading`: neutral ít chroma hơn. `expressive`: màu nhấn có giới hạn chroma cao hơn. Đây là design policy, không dự đoán cảm xúc.
- `contrastLevel` 0..1; từ 0.5, các cặp chữ được Youth UI audit nhắm 7:1; mặc định 4.5:1. Không có nghĩa toàn ứng dụng đạt WCAG AAA.
- `surface`, `background` optional: override opaque trong dải tone phù hợp mode (light ≥85, dark ≤30). Màu không phù hợp báo lỗi.
- `fontFamily` optional. Native Material widgets vẫn kế thừa ColorScheme.

## Sinh màu có ràng buộc

Engine dùng HCT và DynamicScheme của **Material Color Utilities** để sinh đủ nhóm primary/secondary/tertiary/error/surface/fixed. Giữ brand gốc riêng, ánh xạ lại vai trò theo light/dark, sửa tone để thỏa tương phản.

UIButton có resolver cho default, hover, pressed, focus, selected, disabled. Màu trạng thái được phối trước, kiểm tra sau. Badge/Alert dùng cặp opaque soft/onSoft; UICard tự cấp ngữ cảnh surface.

```dart
final colors = YouthColors.of(context);
final originalBrand = colors.brandPrimary;
final checks = colors.audit(); // label, foreground, background, ratio, minimum, passed
```

Nếu tạo container riêng có màu nền khác, bọc `UISurfaceScope(color: actualBackground, child: ...)`. Không đưa nền ảnh/gradient vào và giả định kiểm tra màu phẳng vẫn đúng.

## Component

| Widget | Chức năng |
| --- | --- |
| UIButton | solid/soft/outline/ghost, tone, icon, loading, disabled, state colors và focus |
| UITextField | Form validation, multiline, controller, keyboard, autofill |
| UIPasswordField | Hiện/ẩn mật khẩu, validation, controller |
| UISelect<T> | Dropdown có nhãn và validation |
| UICheckbox / UISwitch | Control gọn, nhãn tùy chọn, hover/focus cục bộ, bàn phím, disabled |
| UIToggleButton | Nút bật/tắt độc lập với icon và trạng thái được chọn |
| UISegmentedControl<T> / UIOption<T> | Nhóm chọn một giá trị, hỗ trợ khóa từng lựa chọn |
| UICard | Surface context, hover lift và ripple khi có onTap |
| UIBadge / UIAlert | Status theo cặp màu, icon và nội dung |
| UIEntrance | Fade + dịch lên, mặc định 450ms |
| UIAnimatedContent | Fade + scale, mặc định 250ms |

`UITone`: primary, secondary, accent, success, warning, danger. Tone là vai trò, không gán lại màu cho mỗi widget. Trạng thái phải có label/icon phù hợp, không dựa riêng vào hue.

## Lựa chọn và vùng tương tác

```dart
UICheckbox(
  label: 'Nhận thông báo qua email', // có thể bỏ nhãn
  value: checked,
  onChanged: (v) => setState(() => checked = v ?? false),
);
UISwitch(value: notifications, onChanged: setNotifications);
UIToggleButton(
  label: 'Lưu mục này',
  icon: Icons.bookmark_border_rounded,
  value: saved,
  onChanged: setSaved,
);
UISegmentedControl<String>(
  options: const [
    UIOption(value: 'list', label: 'Danh sách'),
    UIOption(value: 'grid', label: 'Lưới'),
  ],
  value: view,
  onChanged: setView,
);
```

Các widget được điều khiển bằng state của ứng dụng; truyền `onChanged: null` để vô hiệu hóa. `UICheckbox` và `UISwitch` hỗ trợ `focusNode`/`autofocus`. Toggle độc lập dùng cho bật/tắt; segmented control dùng khi chỉ chọn một trong các phương án.

Checkbox và switch không tô nền hoặc bắt bấm trên cả hàng: chỉ control nhận tương tác, nhãn chỉ hiển thị và được gắn vào semantics của control. Vẫn giữ vùng chạm cao 48 logical pixel quanh hình vẽ nhỏ để dễ bấm trên mobile. Hover/focus nằm trong vùng này; Tab và Space vẫn hoạt động. Đây là thay đổi hành vi so với 0.2: bấm nhãn không đổi lựa chọn nữa.

Button chỉ phản hồi trong hình nút, input trong ô nhập. `UICard` chỉ có hiệu ứng tương tác khi truyền `onTap`; nếu có, cả card là một hành động. Khi card chứa các control độc lập, hãy để `onTap` trống.

## Website showcase

Thử một seed hoặc hai seed; nhập HEX; chọn profile; đổi light/dark; tăng tương phản; xem kết quả audit theo từng cặp; chạy component/animation và sao chép mã Dart. Demo không đăng ký tài khoản hoặc gửi dữ liệu.

```sh
flutter pub get
flutter test
cd example
flutter test
flutter run -d chrome
```

## Kiểm tra / triển khai

Flutter 3.47.5 / Dart 3.13.x. Chạy `flutter analyze`, `flutter test` ở root và example. Test ma trận chuẩn kiểm tra 166.080 cặp màu/trạng thái trên 20 seed, 2 mode, 3 profile, 7 surface. Đây là kiểm tra kỹ thuật; chưa là nghiên cứu người dùng về độ đẹp hoặc hiệu suất tác vụ.

```sh
cd example
flutter build web --release --base-href /flutter-ui/ --no-web-resources-cdn
```

Push main sẽ chạy kiểm tra và xuất bản GitHub Pages. Package chưa phát hành trên pub.dev.

## Migration từ 0.1

`YouthUI.init(primary: ...)` vẫn nhận các tham số cũ, nhưng **màu primary đầu ra có thể khác seed**, để thích ứng mode và khả năng đọc. Dùng `YouthColors.brandPrimary` khi cần đúng mã nhận diện. Đỏ/vàng chỉ xuất hiện khi được truyền vào như seed hoặc khi phù hợp vai trò trạng thái, không là mặc định thương hiệu của mọi sản phẩm.

`YouthPalette` vẫn có để tương thích các getter success/warning. Các component mới đọc nhóm màu từ `YouthColors`; muốn thay engine nên tạo theme nhất quán, không chỉ ghi đè một trường ThemeExtension cũ.

**Giới hạn:** audit đo các role/state endpoint, không mọi pixel của mọi layout và mọi frame nội suy. Không bảo đảm mọi custom style, đồ thị, nền ảnh hay gradient. Xem đầy đủ phạm vi và nguồn trong [tài liệu nghiên cứu](docs/color-research.vi.md).
