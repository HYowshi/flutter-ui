# Flutter UI · Youth UI

Bộ Flutter/Dart UI dùng lại cho mobile, desktop và web, không gắn với một ứng dụng hay một bộ màu thương hiệu. Truyền **một hoặc hai màu**, nhận theme sáng/tối và để widget tự chọn màu theo vai trò.

**[Website tương tác](https://hyowshi.github.io/flutter-ui/)** · **[Nghiên cứu và quyết định thuật toán](docs/color-research.vi.md)** · **[Thiết kế truyền thông và UI](docs/visual-communication.vi.md)**

## Bắt đầu trong một phút

Trong thư mục ứng dụng Flutter, chạy **một lệnh** (tự thêm dependency và tải thư viện):

```sh
flutter pub add "youth_ui@{git: {url: https://github.com/HYowshi/flutter-ui.git, ref: v0.15.2}}"
```

Sau đó thay `lib/main.dart` của **ứng dụng mới** bằng:

```dart
import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

void main() => runApp(UIApp(
  primary: Colors.indigo,
  home: Scaffold(body: UIPage(children: [
    UITextField(label: 'Tên của bạn'),
    UIButton(label: 'Tiếp tục', onPressed: () {}),
  ])),
));
```

Chỉ khởi tạo màu ở `UIApp` một lần; các UI tự lấy theme. Có thể thêm `secondary` nếu có màu thương hiệu thứ hai. Callback và dữ liệu do ứng dụng cung cấp. Cần Flutter >=3.47.0 / Dart ^3.13.0 và Git để cài bản GitHub này.

Ứng dụng đã có `MaterialApp`/router: giữ cấu trúc hiện tại và tích hợp theme bằng `YouthUI.colors(...)` theo hướng dẫn bên dưới; không lồng thêm `UIApp`.

Bản hiện tại phát hành trên GitHub, **chưa trên pub.dev**: dùng nguyên lệnh trên, chưa dùng `flutter pub add youth_ui`.

## Cài đặt và tải bản đóng gói

Giấy phép **MIT**. Dùng Git dependency ghim `v0.15.2` theo phần Dùng nhanh bên dưới, hoặc tải ZIP/TAR.GZ tại [GitHub Releases](https://github.com/HYowshi/flutter-ui/releases/tag/v0.15.2). [Hướng dẫn cài gói đã giải nén](docs/distribution.vi.md).

## Dùng với AI

Cho AI bắt đầu từ **[llms.txt](llms.txt)** hoặc **[cổng tài liệu đọc trực tiếp](https://hyowshi.github.io/flutter-ui/ai/)**. Có [hướng dẫn tích hợp](docs/ai-guide.md), [chữ ký API lấy từ source](docs/api-reference.md), [ví dụ chạy được](example/README.md), [mẫu AGENTS.md cho dự án khác](docs/consumer-agents.md) và [bản gộp một tệp](llms-full.txt).

Prompt dùng ngay:

> Dự án dùng youth_ui từ HYowshi/flutter-ui. Đọc https://hyowshi.github.io/flutter-ui/llms.txt và ai-guide trước khi viết UI. Kiểm tra phiên bản trong pubspec.lock, dùng API đúng phiên bản, ưu tiên component có sẵn và giữ router/state/theme hiện tại.

AI không nhất thiết tự phát hiện các tệp này; hãy đưa URL hoặc thêm mẫu chỉ dẫn vào dự án sử dụng. Khi thay API/tài liệu, chạy `python tool/generate_ai_docs.py`; CI kiểm tra đồng bộ và xuất bản bản văn bản bên cạnh website.

**Mới 0.12:** wireframe tự nhận diện thêm trang quảng bá, sự kiện và gói dịch vụ; demo tự phân tích khi nhập. Xem [nghiên cứu và thay đổi nhận diện](docs/wireframe-design-research.vi.md).

**Mới 0.14:** Floating Action Button, ButtonStyle tùy biến, Table có tìm kiếm/chọn trang/đổi số dòng/lỗi thử lại và mã sử dụng ba mức. [Hướng dẫn tùy chỉnh](docs/customization.vi.md) · [Trang mẫu chạy được](example/lib/customization_example.dart).

**Mới 0.15:** trạng thái màn hình dùng lại, Dialog/Sheet thích ứng, trường ngày tích hợp form và lịch/khoảng ngày native. `UIApp` hỗ trợ locale en/vi. [Hướng dẫn](docs/states-dialog-date.vi.md).

## Dùng nhanh

**Mới 0.13:** animation mở/thu giữ state, textbox tìm kiếm/nhập nhiều dòng, notice có tiêu đề và nội dung dài. [Cách dùng animation, textbox và thông báo](docs/motion-input-notice.vi.md).

**Mới 0.11:** form tự quản lý gửi, validation theo thời điểm, lỗi server theo trường; thông báo có hàng đợi và Hoàn tác. Xem [cách dùng form và thông báo](docs/forms-feedback.vi.md).

```yaml
dependencies:
  youth_ui:
    git:
      url: https://github.com/HYowshi/flutter-ui.git
      ref: v0.15.2
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

`UIApp` tự tạo và giữ theme sáng/tối, theo hệ thống, hỗ trợ đổi chế độ qua `UIThemeToggle`. Không cần khởi tạo thêm provider hay bộ màu ở từng trang. `submit` là callback của ứng dụng; asset phải khai báo trong pubspec. Bản ví dụ ghim tag v0.15.2; dùng commit cụ thể khi cần đối chiếu chính xác.

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

UIWireframe.auto(data: sample); // JSON-like mẫu, tự nhận diện bố cục
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

**Ảnh:** khung ổn định khi loading/lỗi; fallback tùy ứng dụng, fade một lần và decode hint native. Mọi constructor (ảnh thường, avatar, thumbnail, banner, provider) đều nhận các tùy chọn dưới đây:

```dart
UIImage(photoUrl, // String?; null / chuỗi trắng không tải asset
  fallbackSource: 'assets/default-cover.png', // cũng nhận URL HTTP(S)
  fallback: const Center(child: Icon(Icons.hide_image_outlined)),
  placeholder: const UIWireframe.image(),
);
UIImage.avatar(avatarUrl,
  fallbackSource: 'assets/default-avatar.png',
  fallback: const Center(child: Text('AN')),
);
// Thay toàn bộ cách xử lý lỗi, nhận lỗi gốc:
UIImage(photoUrl, errorBuilder: (context, error, stack) =>
  const Center(child: Text('Ảnh chưa có sẵn')));
```

Thứ tự: `errorBuilder` nếu có → nếu không, thử `fallbackSource` một lần → `fallback` widget → giao diện lỗi mặc định. Ảnh fallback lỗi sẽ dừng ở widget cuối, không thử lại dây chuyền. Hai nguồn giống nhau không bị tải lặp. `placeholder` dùng trong lúc chờ cả nguồn chính và nguồn fallback. Widget tự cung cấp phải vừa khung; nếu tự đặt `Image` vào placeholder/fallback thì ứng dụng quản lý lỗi của Image đó. Các asset kể cả fallback phải khai báo trong pubspec.

`allowRetry` chỉ áp dụng cho giao diện lỗi mặc định, không chèn nút vào fallback tùy biến; avatar/thumbnail/provider mặc định tắt, ảnh thường/banner mặc định bật. Nút dùng icon khi khung nhỏ hoặc chữ lớn; không hiện nếu không đủ vùng chạm 48px. Chống nhấn lặp và bỏ qua kết quả thử lại của nguồn cũ sau khi đổi nguồn/dispose. Retry xóa đúng cache key ResizeImage và provider gốc.

Giữ `fit`, `alignment`, bo góc và khung cho cả nguồn chính/fallback. Avatar/thumbnail co đều khi parent nhỏ; ảnh thường tôn trọng chiều cao tối đa của parent. Có thể ghi đè fit/alignment/variants/optimizeDecode ở các kiểu ảnh; banner hỗ trợ height và borderRadius. Cần `semanticLabel` cho ảnh mang thông tin, kể cả nội dung thay thế. Không tự đọc URL hoặc thông báo lỗi kỹ thuật cho người dùng. API `.source` nay là `String?` vì hỗ trợ nguồn vắng mặt; code đọc thuộc tính này cần xử lý null.

Decode native theo bucket 128px, tối đa 2048px chiều ngang; web dùng provider nguyên bản. Xem [quy tắc fallback và giới hạn của ảnh](docs/images.vi.md).

Web bỏ qua cacheWidth/cacheHeight của Flutter: để giảm byte tải trên web, truyền biến thể kích thước thực từ máy chủ, không chỉ URL ảnh gốc dung lượng lớn:

```dart
UIImage('https://cdn.example.com/photo-1280.jpg', variants: const {
  320: 'https://cdn.example.com/photo-320.jpg',
  640: 'https://cdn.example.com/photo-640.jpg',
  1280: 'https://cdn.example.com/photo-1280.jpg',
});
```

Thư viện chọn biến thể theo vùng hiển thị và DPR, không tự sửa URL tùy ý hoặc vượt CORS. Không cung cấp cache ổ đĩa/offline; dùng ImageCache của Flutter. Raster có dạng rất khác khung crop có thể cần provider/chất lượng riêng (`optimizeDecode: false`). SVG dùng provider/giải pháp phù hợp riêng, không phải định dạng ảnh raster được hỗ trợ tự động.

**Wireframe:** `UIWireframe.auto(data: sample)` nhận Map/List/giá trị JSON-like, nhận diện bố cục từ cấu trúc + kiểu trường + tên khóa Việt/Anh. Có 17 bố cục: feed, dashboard, form, profile, article, product, gallery, chat, table, settings, timeline, detail, list, empty, landing, event, pricing. Bảng tự thành thẻ ở vùng hẹp/chữ lớn; bố cục dùng constraint của vùng chứa.

```dart
UIWireframe.auto(data: {'name': 'An', 'avatar': null, 'email': null});
// Khi biết ý định màn hình, chỉ định để không cần đoán:
UIWireframe.auto(data: sample, layout: UIWireframeLayout.profile);
UIWireframe.auto(fields: const [
  UIWireframeField('Email', type: UIWireframeFieldType.email),
  UIWireframeField('Password', type: UIWireframeFieldType.password),
  UIWireframeField('Category', type: UIWireframeFieldType.choice),
]);
UIWireframe.auto(data: sample, fieldTypes: const {
  'portrait': UIWireframeFieldType.avatar,
});
// Phân tích một lần, tái sử dụng kết quả bất biến:
final plan = UIWireframe.inspect(sample);
print(plan.layout); print(plan.confidence); print(plan.reasons);
UIWireframe.fromPlan(plan: plan);
```

Đây là wireframe/placeholder tĩnh, không phải UI chức năng hay mô hình AI. `high/medium/low` là mức bằng chứng của heuristic, **không phải xác suất chính xác**. Dữ liệu mơ hồ dùng detail/list, dữ liệu rỗng dùng empty; khi đang tải mà chưa biết nội dung, cung cấp schema/preset thay vì kỳ vọng đoán từ null. Không đọc màn hình, không gọi mạng, không hiển thị giá trị đầu vào. Ảnh là khối giả lập; không tải URL. Không tự sinh validator hay logic đăng nhập từ dữ liệu.

Giới hạn mỗi lần: 3 tầng envelope (`data/items/results`), 8 phần tử mẫu, 64 khóa/bản ghi và tối đa 12 trường đầu ra; `itemCount` 0–12 (mặc định 3, số khối xem trước, không phải số bản ghi thực tế). Không duyệt đệ quy; trường lồng nhau dùng khối section. Dữ liệu sau mẫu có thể khác nên chỉ định layout cho production khi đã biết màn hình. Danh sách lớn vẫn dùng lazy widget; parent quản lý cuộn. Nếu input thay đổi, tạo widget/plan mới; không giữ dữ liệu mutable rồi mong plan tự đổi.

Xem [quy tắc, ví dụ và giới hạn nhận diện](docs/wireframe.vi.md).

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
| UIRadio / UIRadioGroup | Chọn một phương án, bàn phím native, disabled và bố cục thích ứng |
| UITable / UITableColumn | Bảng/thẻ thích ứng, sort, phân trang, chọn dòng và ô tùy biến |
| UIImage | Asset/URL/provider, fallbackSource/widget/errorBuilder, placeholder, retry và khung thích ứng |
| UIWireframe | 17 bố cục, nhận diện dữ liệu/schema, giải thích lựa chọn và tự thích ứng |
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


## Table và Radio

```dart
UIRadioGroup<String>(
  label: 'Tần suất',
  value: frequency,
  options: const [
    UIOption(value: 'daily', label: 'Hàng ngày'),
    UIOption(value: 'weekly', label: 'Hàng tuần'),
    UIOption(value: 'locked', label: 'Không khả dụng', enabled: false),
  ],
  onChanged: (value) => setState(() => frequency = value),
);

UITable<Person>(
  rows: people,
  columns: [
    UITableColumn(label: 'Tên', value: (p) => p.name,
      compare: (a, b) => a.name.compareTo(b.name)),
    UITableColumn(label: 'Điểm', value: (p) => '${p.points}', numeric: true,
      compare: (a, b) => a.points.compareTo(b.points)),
  ],
  pageSize: 10,
  rowKey: (p) => p.id,
  selectedKeys: selected,
  onSelectionChanged: (keys) => setState(() => selected = keys),
);
```

`UIRadioGroup` là nhóm chọn một phương án; `onChanged: null` khóa nhóm. Từng option có `enabled`. `direction: Axis.horizontal` yêu cầu bố cục ngang khi đủ chỗ, tự xếp dọc ở vùng compact/chữ lớn. Tab/phím mũi tên/Space theo RadioGroup native. Nhãn/khoảng trống không bắt bấm hay hover; mục tiêu control là 48px. `UIRadio<T>(value:, label:)` dùng riêng bên trong Flutter RadioGroup nếu cần layout tùy biến. Các value cần khác nhau và không null; null ở group value nghĩa là chưa chọn. UIOption.icon hiện không được dùng bởi Radio.

`UITable` tự đổi bảng thành thẻ có nhãn ở vùng compact hoặc text scale >1.5. Desktop nhiều cột có thanh cuộn ngang; parent quản lý cuộn dọc. Chỉ dựng ô của trang hiện tại (pageSize 1–100, mặc định10). Header có compare thì được sắp xếp, null thì chỉ đọc; numeric chỉ căn số, muốn sort số phải truyền comparator số. Sort ổn định, không thay đổi danh sách gốc. Mobile có nút sắp xếp tương đương. `cellBuilder(context, row)` cho badge, ảnh, nút thao tác; widget tùy biến vẫn phải tuân theo constraint.

Chọn dòng là tùy chọn: cần rowKey duy nhất, selectedKeys và onSelectionChanged; chỉ checkbox nhận thao tác chọn. Set trả về bất biến, giữ lựa chọn qua các trang. Ứng dụng tự loại bỏ khóa của bản ghi đã xóa/đổi bộ dữ liệu khi cần. Loading tĩnh (`loading: true`) và trạng thái rỗng (`empty: widget`) được hỗ trợ. Tạo danh sách rows/columns mới khi dữ liệu thay đổi, tránh sửa tại chỗ vì thứ tự sort được cache. Table xử lý dữ liệu trong bộ nhớ, sort toàn danh sách; phân trang không phải server paging hay bảng ảo hóa cho dữ liệu cực lớn. Xem [chi tiết Table và Radio](docs/table-radio.vi.md).


## Bố cục ứng dụng thích ứng

`UIAdaptiveScaffold` tổ chức điều hướng và quan hệ nội dung, còn UIPage/UIGrid/UIForm là các primitive đơn giản. Form không nên chia cột chỉ vì màn hình rộng; chọn bố cục dựa trên tác vụ và độ dài nội dung.

```dart
UIAdaptiveScaffold(
  title: 'Hồ sơ cá nhân',
  subtitle: 'Quản lý thông tin và tùy chọn của bạn.',
  destinations: const [
    UIDestination(label: 'Hồ sơ', icon: Icons.person_outline),
    UIDestination(label: 'Thông báo', icon: Icons.notifications_none),
  ],
  selectedIndex: page,
  onDestinationSelected: (value) => setState(() => page = value),
  child: profileForm,
  supportingTitle: 'Gợi ý hồ sơ',
  supporting: profileSummary,
  actions: UIActions(children: [UIButton(label: 'Lưu thay đổi', onPressed: save)]),
);
```

Dùng làm màn hình gốc trong vùng có chiều cao hữu hạn (widget đã có Scaffold). Nhận 2–5 destination; ứng dụng quản lý tab, route và dữ liệu. Mobile dùng NavigationBar; tablet dùng rail; vùng expanded có thể dùng rail mở rộng. Chữ lớn ưu tiên điều hướng dưới để dành chỗ đọc. Form/nội dung chính giới hạn mặc định720px, supporting240px chỉ ra cạnh khi hai pane đủ chỗ. Compact thu gọn phần hỗ trợ vào ExpansionTile, vì thông tin quan trọng phải nằm trong child. `leading` là tùy chọn cho rail.

Action footer luôn ở ngoài vùng cuộn và bàn phím được Scaffold xử lý. Caller vẫn phải bố trí actions vừa khung và không dùng footer quá cao. Không dùng intrinsic sizing hoặc bọc cả scaffold bằng một SingleChildScrollView không giới hạn chiều cao. Scaffold giữ subtree của child/supporting/actions khi thay đổi bố cục; ứng dụng nên giữ controller/model khi thay hẳn trang hoặc route.

Demo Adaptive UI nay có thiết kế tài khoản hoàn chỉnh và ba viewport độc lập. Preview có thể thu nhỏ vừa khung website, luôn ghi % zoom; bật kích thước gốc để đánh giá chữ/vùng bấm. Thu nhỏ bản preview không phải cách library xử lý màn hình nhỏ. Xem [nghiên cứu và nguyên tắc thiết kế](docs/adaptive-design.vi.md).
