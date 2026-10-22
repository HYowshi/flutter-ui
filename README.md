# Flutter UI · Youth UI 0.6

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

void main() => runApp(UIApp(
  primary: const Color(0xFF1565C0),
  // secondary: const Color(0xFFDA251D), // tùy chọn
  home: Scaffold(body: UIPage(children: [
    UIForm(children: [UITextField(label: 'Email'), UIPasswordField()]),
    UIImage('assets/photo.png'),
    UIActions(children: [UIButton(label: 'Tiếp tục', onPressed: submit)]),
    UIThemeToggle(),
  ])),
));
```

`UIApp` tự tạo và giữ theme sáng/tối, theo hệ thống, hỗ trợ đổi chế độ qua `UIThemeToggle`. Không cần khởi tạo thêm provider hay bộ màu ở từng trang. `submit` là callback của ứng dụng; asset phải khai báo trong pubspec. Pin commit khi cần dependency ổn định thay vì dùng main.

Với MaterialApp/router sẵn có, vẫn dùng `YouthUI.colors(...)` một lần rồi đặt `theme: ui.light`, `darkTheme: ui.dark`. Muốn transition mới: đặt `themeAnimationDuration: Duration.zero` và trong builder trả `UIThemeTransition(theme: Theme.of(context), child: child!)`. Không chồng hai animation theme.

## Theme, ảnh và wireframe gọi nhanh

```dart
// Controller là tùy chọn; nếu truyền vào, ứng dụng chịu trách nhiệm dispose.
final theme = UIThemeController(mode: ThemeMode.system);
UIApp(primary: Colors.indigo, controller: theme, home: const HomePage());
theme.mode = ThemeMode.dark;

UIImage('assets/photo.png');             // asset
UIImage('https://example.com/photo.jpg'); // HTTP(S), cần CORS hợp lệ trên web
UIImage.avatar('assets/avatar.png');
UIImage.thumbnail('assets/photo.png');
UIImage.banner('assets/photo.png');       // 16:9 gọn, 21:9 vùng rộng
UIImage.provider(MemoryImage(bytes));     // provider tùy chọn

UIWireframe.page();
UIWireframe.page(layout: UIWireframeLayout.dashboard);
UIWireframe.page(layout: UIWireframeLayout.form);
UIWireframe.card();
UIWireframe.list(count: 3);
UIWireframe.line(widthFactor: .7);
UIWireframe.image();
UIWireframe.avatar();
```

**Transition:** fade 220ms từ một ảnh chụp theme cũ sang UI mới đang hoạt động. Không clone cây widget, không tính lại HCT theo từng frame; giới hạn snapshot khoảng 2 triệu pixel, DPR ≤1.5 và giải phóng sau fade. Đổi liên tục sẽ kết thúc ở theme được yêu cầu cuối cùng. Reduced motion/high contrast chuyển ngay. Renderer/platform view không hỗ trợ chụp thì dùng cập nhật trực tiếp. Đây là tối ưu có giới hạn bộ nhớ, không phải bảo đảm FPS cho mọi thiết bị.

**Ảnh:** khung/tỉ lệ ổn định khi loading/lỗi; placeholder tĩnh, fade một lần, giữ aspect nguồn khi gợi ý decode native; bucket 128px, tối đa 2048px chiều ngang. Không tải khi vùng chứa bằng 0; avatar/thumbnail giữ kích thước ngay trong cột giãn rộng. Fallback không lặp retry tự động, URL lỗi có nút thử lại khi đủ chỗ. `semanticLabel` dành cho ảnh có nội dung; không đọc đường dẫn asset. Tôn trọng constraint cha, `fit`, `alignment`, `width`, `height` có thể ghi đè.

Web bỏ qua cacheWidth/cacheHeight của Flutter: để giảm byte tải trên web, truyền biến thể kích thước thực từ máy chủ, không chỉ URL ảnh gốc dung lượng lớn:

```dart
UIImage('https://cdn.example.com/photo-1280.jpg', variants: const {
  320: 'https://cdn.example.com/photo-320.jpg',
  640: 'https://cdn.example.com/photo-640.jpg',
  1280: 'https://cdn.example.com/photo-1280.jpg',
});
```

Thư viện chọn biến thể theo vùng hiển thị và DPR, không tự sửa URL tùy ý hoặc vượt CORS. Không cung cấp cache ổ đĩa/offline; dùng ImageCache của Flutter. Raster có dạng rất khác khung crop có thể cần provider/chất lượng riêng (`optimizeDecode: false`). SVG dùng provider/giải pháp phù hợp riêng, không phải định dạng ảnh raster được hỗ trợ tự động.

**Wireframe:** mẫu phác thảo/placeholder tĩnh, theo theme và responsive; không phải mô hình AI hoặc công cụ thiết kế kéo thả. Không ticker/shimmer hoặc request dữ liệu. Dành cho bố cục nhỏ; danh sách dữ liệu lớn vẫn cần widget lazy.

Xem [rà soát độ ổn định và hiệu năng](docs/reliability-review.vi.md) cho test, phạm vi và giới hạn đo.

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
| UIApp / UIThemeToggle | Khởi tạo một lần, giữ theme pair và chuyển light/dark |
| UIImage | Asset/URL/provider, avatar/banner/thumbnail, placeholder/lỗi và decode hint |
| UIWireframe | Các block tĩnh và mẫu feed/dashboard/form responsive |
| --- | --- |
| UIButton | solid/soft/outline/ghost, state colors; tự giãn trong vùng hẹp và xuống dòng nhãn dài |
| UITextField | Form validation, multiline, controller, keyboard, autofill |
| UIPasswordField | Hiện/ẩn mật khẩu, validation, controller |
| UISelect<T> | Popup PC / sheet mobile, tìm kiếm, chọn mục, phím tắt, validation |
| UICheckbox / UISwitch | Control gọn, nhãn tùy chọn, hover/focus cục bộ, bàn phím, disabled |
| UIToggleButton | Nút bật/tắt độc lập với icon và trạng thái được chọn |
| UISegmentedControl<T> / UIOption<T> | Nhóm chọn một giá trị, hỗ trợ khóa từng lựa chọn |
| UICard | Padding theo vùng chứa, surface context, hover/ripple khi có onTap |
| UIBadge / UIAlert | Status theo cặp màu, icon và nội dung |
| UIEntrance | Fade + dịch lên, mặc định 450ms |
| UIAnimatedContent | Fade + scale, mặc định 250ms |
| UIPage | Safe area, cuộn trang, giới hạn chiều rộng trên desktop |
| UIForm / UIGrid | Tự chia cột theo vùng chứa và cỡ chữ, chiều cao theo nội dung |
| UIActions | Nút xếp dọc trong vùng hẹp, tự wrap trong vùng rộng |
| UIAdaptiveBuilder | Dữ liệu adaptive cho component tự viết |

`UITone`: primary, secondary, accent, success, warning, danger. Tone là vai trò, không gán lại màu cho mỗi widget. Trạng thái phải có label/icon phù hợp, không dựa riêng vào hue.

## Tự thích ứng PC / mobile

Không cần truyền `isMobile` hoặc kích thước vào từng widget. Mặc định các widget đọc **constraints của vùng chứa**, text scaler của hệ thống và trạng thái kết nối chuột. Một panel 360px trên desktop cũng dùng layout gọn, dù cửa sổ ngoài rộng 1440px. Resize không nhân toàn bộ kích thước UI theo tỷ lệ màn hình.

```dart
// Vẫn chỉ một lần khởi tạo; cấu hình adaptive có mặc định sẵn.
final ui = YouthUI.colors(primary: const Color(0xFF1565C0));

// Trong màn hình: không viết breakpoint, Row/Column hay media query.
Scaffold(
  body: UIPage(children: [
    UICard(child: UIForm(formKey: formKey, children: [
      UITextField(label: 'Tên hiển thị'),
      UITextField(label: 'Email', validator: validateEmail),
      UIPasswordField(),
    ])),
    UIActions(children: [
      UIButton(label: 'Lưu thay đổi', onPressed: save),
      UIButton(label: 'Hủy', variant: UIButtonVariant.outline, onPressed: cancel),
    ]),
  ]),
);
```

| Thành phần | Tự thích ứng |
| --- | --- |
| Button / toggle | Vùng chứa <600px: giãn rộng nếu width hữu hạn; vùng rộng: ôm nội dung. Nhãn dài xuống dòng, không ellipsis; target tối thiểu 48px. |
| Segmented control | Đo nhãn với font và text scaler thực tế; nếu nhóm không vừa chiều ngang, chuyển sang các nút chọn xếp dọc. Giữ giá trị và disabled. |
| Text / password / select | Padding theo vùng chứa và chuột; menu tự chọn popup/sheet theo viewport và input; hàng có chiều cao theo nội dung; helper/lỗi hỗ trợ tối đa 6 dòng. |
| Checkbox / switch | Nhãn xuống dòng, control giữ vùng chạm 48px; không nở vùng hover sang nhãn hoặc cả hàng. |
| Card / badge / alert | Card giảm padding trong vùng hẹp; badge và nội dung alert xuống dòng. |
| UIForm / UIGrid | 1–2 / 1–4 cột mặc định. Chữ lớn làm giảm số cột, giữ cỡ chữ người dùng; không ép chiều cao tile. |
| UIPage / UIActions | Trang cuộn, safe area, padding 16/24/32px, nội dung tối đa 1120px; actions xếp dọc dưới 600px, wrap ở vùng rộng. |

Tùy chỉnh một lần nếu dự án cần:

```dart
final ui = YouthUI.colors(
  primary: Colors.indigo,
  adaptive: const UIAdaptiveConfig(
    compactBreakpoint: 640,
    expandedBreakpoint: 1100,
    minColumnWidth: 300,
    maxContentWidth: 1200,
  ),
);
```

`UIButton(fullWidth: false)` và `UICard(padding: ...)` vẫn cho phép ghi đè có chủ ý. Trong `Row` không có width hữu hạn, button giữ kích thước nội dung; muốn tự chuyển cả nhóm giữa hàng/cột thì dùng `UIActions`. `UIGrid` dành cho form/nhóm nội dung nhỏ; danh sách dữ liệu lớn vẫn cần ListView/GridView dạng lazy. Đặt `UIPage` trong vùng có chiều cao hữu hạn như `Scaffold.body`, vì nó quản lý cuộn của trang.

Bộ UI tự xử lý các component và khối bố cục ở trên; không thể sửa overflow do một `Row`, fixed height hoặc widget tùy chỉnh do ứng dụng bên ngoài áp đặt. Với `IntrinsicWidth`/`IntrinsicHeight`, tránh bọc các component dựa trên LayoutBuilder; dùng constraint hữu hạn. Các quy tắc và phạm vi kiểm tra được ghi trong [thiết kế adaptive](docs/adaptive-design.vi.md).

## Dropdown menu đồng bộ

```dart
UISelect<String>(
  label: 'Không gian làm việc',
  initialValue: 'personal',
  options: const [
    UIOption(value: 'personal', label: 'Cá nhân', icon: Icons.person_outline),
    UIOption(value: 'team', label: 'Nhóm', icon: Icons.groups_outlined),
    UIOption(value: 'archive', label: 'Lưu trữ', enabled: false),
  ],
  onChanged: (value) => setState(() => workspace = value),
  validator: (value) => value == null ? 'Hãy chọn một mục.' : null,
);
```

- PC: popup bám theo ô chọn, cùng chiều rộng (giới hạn theo viewport), tự tránh mép màn hình. Mobile: sheet khi viewport < compact breakpoint và không có chuột kết nối; có đóng, safe area và chừa bàn phím ảo. Một field hẹp trên desktop vẫn dùng popup.
- Màu nền/chữ/viền/hover/focus/selected/disabled dùng tokens của theme; không thêm màu cố định. Hàng ≥48px, nhãn dài xuống dòng, có dấu chọn và scrollbar.
- Tìm kiếm tự bật từ 8 mục có nhãn, hỗ trợ gõ tiếng Việt không dấu, nút xóa và trạng thái không có kết quả. Có thể chỉ định `searchable: true/false`, `searchHint`, `emptyLabel`, `hint`, `helper`.
- Danh sách dùng lazy builder. Với `UIOption`/Text, đo chiều cao theo font và text scaler để cuộn đến mục đang chọn; Home/End và ↑/↓ di chuyển qua cả danh sách, bỏ qua mục disabled. Enter chọn; Esc hoặc bấm ngoài đóng. Desktop trả focus về ô chọn.
- Hỗ trợ Form.validate/reset, `autovalidateMode`, `focusNode`, `autofocus` và `enabled`. Null `onChanged` hoặc không còn mục enabled sẽ khóa ô chọn.

`items: List<DropdownMenuItem<T>>` cũ vẫn hoạt động, giữ child/onTap/enabled; không truyền đồng thời `items` và `options`. Với child tùy chỉnh, truyền `optionLabel` nếu cần tìm kiếm hoặc giá trị đọc cho screen reader. Child tự đặt màu có thể ghi đè theme; muốn tự đồng bộ hoàn toàn nên dùng `UIOption`. Cuộn đến vị trí của child tùy chỉnh dùng chiều cao ước lượng, còn nội dung Text/UIOption dùng đo nhãn. Giá trị phải riêng biệt và khác null; null đại diện chưa chọn. `initialValue` là giá trị ban đầu/reset, state chọn do form quản lý; đổi value đầu vào không phải API controlled.

Mục **Dropdown menu** trên website có danh sách dài, nhãn dài, mục bị khóa, tìm không dấu và form bắt buộc. Các primitive dựa trên MenuAnchor và modal bottom sheet của Flutter: [MenuAnchor](https://api.flutter.dev/flutter/material/MenuAnchor-class.html), [showModalBottomSheet](https://api.flutter.dev/flutter/material/showModalBottomSheet.html).

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

Thử một seed hoặc hai seed; nhập HEX; chọn profile; đổi light/dark; tăng tương phản; xem kết quả audit theo từng cặp; chạy component/animation và sao chép mã Dart. Mục **Adaptive UI** có preview 360/768/1080px và chế độ chữ lớn 200%; cùng một màn hình mẫu không chứa nhánh kiểm tra thiết bị. Demo không đăng ký tài khoản hoặc gửi dữ liệu.

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
