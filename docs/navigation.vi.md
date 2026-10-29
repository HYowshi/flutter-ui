# Sidebar & Navbar · 0.18

## Chọn mẫu rồi gọi widget

```dart
final items = [
  UINavigationItem(id: 'home', label: 'Tổng quan', icon: Icons.home_outlined),
  UINavigationItem(id: 'inbox', label: 'Tin nhắn', icon: Icons.chat_outlined, badge: '12'),
];

UINavigationScaffold(
  title: 'Workspace',
  items: items,
  selectedIndex: selected,
  onSelected: (index) => setState(() => selected = index),
  sidebarVariant: UISidebarVariant.floating,
  navbarVariant: UINavbarVariant.pill,
  child: page,
);
```

Các màu lấy từ ColorScheme của UIApp/theme hiện tại. Không cần gán màu riêng cho từng mục. Tham số style chỉ chọn cách thể hiện; caller sở hữu selectedIndex và routing. `onSelected` có thể cập nhật State, gọi router hiện tại hoặc đổi page. Không tự thêm route, gọi API hay mở URL từ label/id.

## Năm Sidebar

| Variant | Ngôn ngữ thiết kế |
|---|---|
| standard | Bề mặt nhẹ, selected nền mềm và vạch ở đầu dòng |
| tonal | Nền phân lớp, mục chọn mang màu primary với chữ onPrimary |
| floating | Khối bo 24 px, bóng nhẹ, mục chọn dạng pill |
| contrast | Nền primary toàn khối, chữ onPrimary, mục chọn đảo vai trò màu |
| outline | Khung và đường viền nhấn mục chọn, nền ít nhiễu |

`UISidebar` có title/subtitle/leading/footer, nhóm `UINavigationItem.group`, badge và enabled. `collapsed: true` chuyển thành rail 80 px; chiều rộng thực dưới 200 px cũng ẩn nhãn, giữ tooltip và tên semantics. Nhãn dài tối đa hai dòng, sau đó ellipsis; tooltip/semantics giữ nhãn đầy đủ. Badge là chuỗi do app định dạng, ví dụ `99+`.

Sidebar mặc định rộng 264 px; width phải hữu hạn và >=64. Widget cần chiều cao hữu hạn: đặt trong Expanded/Scaffold hoặc SizedBox. Nếu parent cho chiều rộng nhỏ hơn 64 px thì sidebar không được hiển thị. Dùng Navbar/menu hoặc shell tự thích ứng khi vùng quá nhỏ, thay vì ép Sidebar cạnh nội dung.

Header, mục và footer cùng nằm trong vùng cuộn. Footer ở phía cuối vùng còn lại khi đủ chỗ, cuộn tiếp khi không đủ; không che các mục bên dưới. Footer/leading phải vừa constraints, dùng nội dung gọn; không đặt Expanded hay ListView không giới hạn vào footer. Khi tự thu gọn sidebar, truyền footer phù hợp dạng rail (ví dụ avatar thay vì hàng thông tin dài).

## Bốn Navbar

| Variant | Ngôn ngữ thiết kế |
|---|---|
| underline | Mục đang chọn có đường nhấn dưới chân |
| pill | Capsule nền mềm quanh mục đang chọn |
| filled | Mục chọn primary đậm, nền thanh dùng surfaceContainerLow |
| floating | Thanh bo 28 px, viền/bóng nhẹ và capsule |

`UINavbar` là thanh điều hướng trên, không phải bottom NavigationBar. Có title, leading và trailing; tận dụng theme của ứng dụng. Vùng rộng cho các liên kết cuộn ngang, kèm nút menu tất cả mục để chuột cũng truy cập được mục nằm ngoài vùng nhìn. Nhãn ngang giới hạn một dòng và có tooltip đầy đủ.

Khi rộng dưới 760 px hoặc text scale >1.4, các mục chuyển vào menu native có focus, đóng bằng Back/Escape/outside và tự chọn dialog/sheet theo viewport. Vùng hẹp dưới 360 px bỏ leading trang trí, dưới 280 px bỏ trailing để ưu tiên nút menu và title. Các slot phải tự phù hợp chiều rộng còn lại; tránh nhét form hoặc một hàng action dài vào header.

Menu chụp danh sách/index khi mở. Dùng `id` ổn định cho từng destination; khi menu đang mở mà danh sách bị đổi thứ tự/thay mục, lựa chọn lỗi thời không được áp dụng nhầm. Nếu không có id, danh tính mặc định là `(label, icon, group)`. `enabled:false` chặn chọn cả bằng pointer, keyboard và semantics.

## Khung tự thích ứng

UINavigationScaffold sở hữu Scaffold và SafeArea:

- layout adaptive: sidebar khi local width >=1024 px và text scale <=1.5; còn lại Navbar.
- layout sidebar: ưu tiên sidebar từ 760 px; vẫn về Navbar khi vùng quá hẹp hoặc chữ lớn.
- layout navbar: Navbar trên mọi kích thước.

Nội dung chính được giữ bằng key nội bộ khi đổi hai cách bố trí; không mất TextField/State chỉ vì resize. Điều này không thay việc lưu state giữa các route do app thay đổi. Brand/action slots có thể xuất hiện/ẩn theo layout; không dùng chúng làm nơi giữ form/draft quan trọng.

Shell không tự thêm scroll view cho child. Truyền UIPage/ListView hoặc nội dung có constraints phù hợp; không lồng thêm Scaffold/MaterialApp trừ khi chủ đích. App đã có shell/router có thể dùng UISidebar và UINavbar riêng. UIAdaptiveScaffold/UIDestination cũ vẫn dành cho bố cục có supporting pane và 2–5 destinations; không trộn hai loại model mà không chuyển đổi rõ ràng.

## Tương tác và thiết kế

Selected state dùng nền, hình dạng/vạch/viền và độ đậm chữ; nhãn rõ ràng, thứ tự mục ổn định giữa desktop và mobile. Các mục có tooltip, selected/enabled semantics, InkWell focus/hover/pressed, hỗ trợ Tab/Shift+Tab và Enter/Space. Tôn trọng reduced motion; không có blur nền, shimmer hay animation lặp. Sidebar dựng mục theo SliverList, không lưu cache item vô hạn.

Nhóm là tiêu đề phân loại một cấp, không phải cây menu nhiều tầng/accordion. Hãy giữ Navbar ngắn; với nhiều mục, ưu tiên Sidebar và cấu trúc nhóm rõ ràng. Tham khảo [Fluent navigation guidance](https://fluent2.microsoft.design/components/web/react/core/nav/usage) về hierarchy, selection, reflow và footer. Đây là triển khai Flutter riêng, không phải bản sao Fluent hoặc Material.

## Demo và recipe

Gallery “Sidebar & Navbar” cho đổi 5 Sidebar, 4 Navbar, rail và chọn mục; các bản xem trước dùng dữ liệu minh họa, cùng một theme. Menu ở preview hẹp trên desktop có thể là dialog vì viewport thật vẫn rộng.

[navigation_recipe.dart](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/recipes/navigation_recipe.dart) là entry point chạy được:

```sh
cd example
flutter pub get
flutter run -t lib/recipes/navigation_recipe.dart
```

Kiểm thử gồm narrow/large text/RTL/dark, từng variant, keyboard, mục vô hiệu hóa, menu lỗi thời và giữ bản nháp khi resize. Các kiểm thử này không phải phép đo FPS/GPU trên thiết bị thật.
