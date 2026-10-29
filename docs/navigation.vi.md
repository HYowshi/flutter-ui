# Sidebar & Navbar · 0.19

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
  mobileNavbarVariant: UIMobileNavbarVariant.pill,
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

## Năm navbar mobile ở dưới

Đặt vào `Scaffold.bottomNavigationBar`, không đặt lên trên nội dung:

```dart
Scaffold(
  body: page,
  bottomNavigationBar: UINavbar.mobile(
    items: items,
    selectedIndex: selected,
    onSelected: (i) => setState(() => selected = i),
    variant: UIMobileNavbarVariant.pill,
  ),
);
```

`UIMobileNavbar(...)` là constructor const tương đương. Chỉ cần truyền items, selectedIndex, onSelected; màu lấy từ theme.

Có thể truyền `onReselected: (index) => scrollController.animateTo(0, duration: const Duration(milliseconds: 240), curve: Curves.easeOut)` để app xử lý riêng lần bấm lại tab hiện tại. Khi có callback này, lần bấm lại chỉ gọi onReselected; khi bỏ qua, vẫn gọi onSelected như các bản trước. Controller thuộc ứng dụng, chỉ cuộn khi `hasClients`; tôn trọng thiết lập giảm chuyển động của app. Menu Thêm cũng hỗ trợ chọn lại trang hiện tại. Trên shell dùng `onMobileReselected`. Việc tải lại dữ liệu hay cuộn trang do app quyết định, thư viện không tự gọi API.


| Variant | Thiết kế |
|---|---|
| standard / Classic | Thanh liền cạnh dưới, biểu tượng chọn trên nền tonal, nhãn luôn hiện |
| pill / Active Pill | Capsule nổi nhẹ, mục chọn mở rộng để hiện icon + nhãn; chữ lớn chuyển sang nhãn hai dòng |
| floating | Khối bo nổi, icon chọn mang nền primary, nhãn bên dưới |
| dock / Contrast Dock | Dock màu primary, icon chọn đảo màu, nhãn luôn hiện |
| centerAction | Nút hành động tròn nhô giữa, các trang chia đều hai bên |

Center Action nhận `onAction`, `actionIcon`, `actionLabel`; callback null thì nút bị vô hiệu hóa. Nút này không đổi selectedIndex, không đại diện cho một trang. Toàn bộ nút nhô vẫn nằm trong vùng nhận chạm thực tế.

Mặc định `useSafeArea: true`, `hideOnKeyboard: true`, `maxWidth: 560`. Chừa vùng vuốt/cạnh màn hình; ẩn khi bàn phím mở. Khi tự quản lý SafeArea, có thể tắt useSafeArea để tránh padding trùng. Mục tiêu là 3–5 trang cùng cấp. Khi có quá nhiều trang hoặc vùng chứa hẹp, các mục dư đi vào `Thêm` (`moreLabel`); nếu trang đang chọn bị ẩn, Thêm mang trạng thái chọn. Vùng quá hẹp không thể chứa một mục chạm 48 px thì thanh được ẩn; app cần bảo đảm bố cục tối thiểu hữu dụng.

Nhãn hai dòng và chiều cao tự tăng theo text scale; tooltip/semantics vẫn giữ đầy đủ nhãn và badge. `enabled:false` chặn pointer, keyboard và semantics. Các mục có id ổn định; menu đang mở bỏ qua lựa chọn lỗi thời nếu danh sách bị thay đổi. Không dùng nhãn làm URL hay lệnh thực thi.

## Top navbar cũ

`UINavbar(...)` vẫn giữ underline/pill/filled/floating cho header trên desktop để tương thích API cũ. Có title/leading/trailing, cuộn liên kết ngang và menu thu gọn. Với navbar mobile, chọn `UINavbar.mobile(...)` hoặc `UIMobileNavbar(...)` như trên.

## Khung tự thích ứng

UINavigationScaffold sở hữu Scaffold và SafeArea:

- layout adaptive: sidebar khi local width >=1024 px và text scale <=1.5; từ 760 px dùng top navbar, dưới 760 px dùng navbar mobile.
- layout sidebar: ưu tiên sidebar từ 760 px; dưới 760 px dùng navbar mobile, vùng rộng với chữ lớn dùng top navbar.
- layout navbar: top navbar từ 760 px, navbar mobile khi hẹp hơn.
- layout mobile: luôn dùng navbar mobile.

Nội dung chính được giữ bằng key nội bộ khi đổi cách bố trí; không mất TextField/State chỉ vì resize. Điều này không thay việc lưu state giữa các route do app thay đổi. Brand/action slots có thể xuất hiện/ẩn theo layout; không dùng chúng làm nơi giữ form/draft quan trọng.

Shell không tự thêm scroll view cho child. Truyền UIPage/ListView hoặc nội dung có constraints phù hợp; không lồng thêm Scaffold/MaterialApp trừ khi chủ đích. App đã có shell/router có thể dùng UISidebar và UINavbar.mobile riêng. UIAdaptiveScaffold/UIDestination cũ vẫn dành cho bố cục có supporting pane và 2–5 destinations; không trộn hai loại model mà không chuyển đổi rõ ràng.

## Tương tác và thiết kế

Selected state dùng nền, hình dạng/vạch/viền và độ đậm chữ; nhãn rõ ràng, thứ tự mục ổn định giữa desktop và mobile. Các mục có tooltip, selected/enabled semantics, InkWell focus/hover/pressed, hỗ trợ Tab/Shift+Tab và Enter/Space. Tôn trọng reduced motion; không có blur nền, shimmer hay animation lặp. Sidebar dựng mục theo SliverList, không lưu cache item vô hạn.

Nhóm là tiêu đề phân loại một cấp, không phải cây menu nhiều tầng/accordion. Hãy giữ Navbar ngắn; với nhiều mục, ưu tiên Sidebar và cấu trúc nhóm rõ ràng. Tham khảo [Fluent navigation guidance](https://fluent2.microsoft.design/components/web/react/core/nav/usage) về hierarchy, selection, reflow và footer. Đây là triển khai Flutter riêng, không phải bản sao Fluent hoặc Material.

## Demo và recipe

Gallery “Sidebar & Navbar” cho đổi 5 Sidebar, 5 navbar mobile trong khung điện thoại, rail và chọn mục; các bản xem trước dùng dữ liệu minh họa, cùng một theme. Menu ở preview hẹp trên desktop có thể là dialog vì viewport thật vẫn rộng.

[navigation_recipe.dart](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/recipes/navigation_recipe.dart) là entry point chạy được:

```sh
cd example
flutter pub get
flutter run -t lib/recipes/navigation_recipe.dart
```

Kiểm thử gồm narrow/large text/RTL/dark, từng variant, keyboard, mục vô hiệu hóa, menu lỗi thời và giữ bản nháp khi resize. Các kiểm thử này không phải phép đo FPS/GPU trên thiết bị thật.

## Nguồn tham khảo thiết kế

- [Android: layout và navigation](https://developer.android.com/design/ui/mobile/guides/layout-and-content/layout-and-nav-patterns): trang cùng cấp, navbar 3–5 điểm đến, phân biệt action và destination.
- [Fluent Nav](https://fluent2.microsoft.design/components/web/react/core/nav/usage): phân nhóm, chỉ dấu chọn, nội dung ngắn và dễ quét.
- [Mobile Bottom Navbar UI — econev](https://www.behance.net/gallery/188483211/-Mobile-Bottom-Navbar-UI-by-econev): tham khảo capsule chọn và độ tương phản.
- [Bottom Navigation Bar — Raafi G](https://dribbble.com/shots/20958519-Bottom-Navigation-Bar): tham khảo nhịp bố cục với hành động giữa.
- [App Tab Bar Animation — Excellent Martial](https://dribbble.com/shots/21587832-App-Tab-Bar-Animation): tham khảo trạng thái chọn và chuyển động.

Các mẫu trong thư viện là triển khai Flutter riêng bằng theme roles và hình học cơ bản; không đóng gói lại ảnh hay tài nguyên của tác giả tham khảo. Các concept chỉ là nguồn cảm hứng thị giác, không phải bằng chứng về hiệu năng hay usability.
