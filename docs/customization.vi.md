# Tùy chỉnh widget và Floating Action Button

Các widget có mặc định từ theme, không cần gán màu từng chỗ. Ưu tiên `tone`/`variant` để dùng lại trong các dự án. Chỉ ghi đè phần cần khác.

## FAB

```dart
Scaffold(
  floatingActionButton: UIFloatingActionButton(
    icon: Icons.add_rounded,
    tooltip: 'Tạo dự án', // tên hành động luôn có khi nhãn được thu gọn
    label: 'Tạo dự án',
    onPressed: createProject,
    tone: UITone.accent,
  ),
  body: yourPage,
);
```

- `size`: `UIFabSize.small`, `regular`, `large`; native Material giữ vùng chạm padded tối thiểu 48px cho nút nhỏ. Vùng quá nhỏ vẫn cần parent cung cấp đủ chỗ.
- `extended: null` tự hiện nhãn khi vùng chứa ≥ breakpoint compact (mặc định 600px), thu về icon ở vùng hẹp. `true` yêu cầu hiện nhãn; `false` luôn icon. Nhãn dài được giới hạn/ellipsis theo vùng chứa, tooltip giữ tên đầy đủ. Khi extended, dùng kích thước native extended; size chỉ tác dụng ở dạng icon.
- `loading: true` khóa callback; reduced motion dùng icon tĩnh thay spinner. Ứng dụng quản lý `Future`, lỗi và trạng thái loading, wrapper không tự gọi lại nghiệp vụ.
- `shape`, `elevation`, `backgroundColor`, `foregroundColor`, `focusNode`, `autofocus` tùy chỉnh cục bộ. Nếu đổi màu, nên đổi cả cặp nền/chữ và kiểm tra sáng/tối, disabled, hover/focus; thư viện không sửa màu do caller ghi đè.
- `heroTag` mặc định null để không trùng tag giữa nhiều nút. Nếu cần chuyển Hero giữa hai route, truyền cùng tag cho cặp nút tương ứng và tag khác cho các nút cùng route.
- Đặt vào `Scaffold.floatingActionButton` để Flutter tránh bàn phím/snackbar/bottomNavigationBar theo geometry native. Một trang thường chỉ có một hành động nổi chính; demo có nhiều nút để so sánh.

`UIAdaptiveScaffold` cũng nhận `floatingActionButton` và `floatingActionButtonLocation`. Với FAB, navigation và footer actions được chuyển vào slot đáy native; phần cuộn có khoảng trống cuối. Tự dùng Scaffold thì ứng dụng cần chừa khoảng cuối cho nội dung cuộn. Widget FAB tùy biến có chiều cao lớn hơn mặc định có thể cần padding riêng.

## ButtonStyle

```dart
UIButton(
  label: 'Xuất báo cáo', icon: Icons.download_outlined,
  onPressed: exportReport, fullWidth: false,
  tone: UITone.secondary,
  style: FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
```

`style` merge lên style sinh từ theme, thuộc tính không truyền giữ mặc định. Hỗ trợ `WidgetStateProperty` cho các trạng thái. `tooltip`, `focusNode`, `autofocus`, `onLongPress` bổ sung thao tác; `loading` tắt cả nhấn và nhấn giữ. Chủ sở hữu FocusNode/controller chịu trách nhiệm dispose. Không giảm kích thước chạm hoặc xóa focus indicator nếu cần truy cập bàn phím.

## Table

```dart
UITable<Person>(
  rows: people,
  searchQuery: query,
  searchText: (p) => '${p.name} ${p.email}', // bỏ để tìm mọi column.value
  pageSize: pageSize,
  onPageSizeChanged: (n) => setState(() => pageSize = n),
  pageSizeOptions: const [5, 10, 20, 50],
  rowKey: (p) => p.id,
  selectedKeys: selected,
  showSelectAll: true,
  onSelectionChanged: (keys) => setState(() => selected = keys),
  loading: loading, error: errorMessage, onRetry: reload,
  columns: [
    UITableColumn(label: 'Tên', minWidth: 220, value: (p) => p.name,
      compare: (a, b) => a.name.compareTo(b.name)),
    UITableColumn(label: 'Điểm', minWidth: 80,
      value: (p) => '${p.points}', numeric: true,
      compare: (a, b) => a.points.compareTo(b.points)),
  ],
);
```

`query`, `pageSize`, `selected`, `loading`, `errorMessage` thuộc State ứng dụng. Nối `query` với `UITextField.search(onChanged: ...)`. Bộ lọc bỏ dấu Việt và phân biệt hoa/thường; lọc trong bộ nhớ, không tải dữ liệu từ API. Không tìm nội dung tùy ý bên trong `cellBuilder`: hãy cung cấp giá trị text hoặc `searchText`. Query mới/số dòng mới quay về trang đầu; sort ổn định và chỉ dựng ô của trang hiện tại.

`showSelectAll` mặc định false để tương thích API cũ. Khi bật, checkbox có trạng thái chưa chọn/một phần/toàn trang; chỉ đổi các dòng đang hiển thị và giữ lựa chọn ở trang khác/ngoài bộ lọc. Số đã chọn tính toàn bộ selectedKeys của caller; caller quyết định dọn key cũ khi đổi dataset. `rowKey` phải duy nhất, ổn định.

`onPageSizeChanged` bật dropdown số dòng, caller cập nhật pageSize (1–100). Giá trị hiện tại luôn có trong danh sách kể cả không nằm trong pageSizeOptions. `minWidth` cột phải hữu hạn ≥48px (mặc định180px), không bao gồm padding. Desktop cuộn ngang khi cần; mobile/chữ lớn dùng thẻ nên không áp độ rộng cột.

Thứ tự trạng thái: loading → error/retry → empty → filtered results. Không có kết quả tìm kiếm có thông báo riêng, không hiển thị trang 0/-1. `error` là thông báo cho người dùng; onRetry callback do ứng dụng xử lý. `empty` thay giao diện khi dataset gốc rỗng.

Các API lọc/sort/paging hiện xử lý dữ liệu trong bộ nhớ; dữ liệu rất lớn cần phân trang/tìm kiếm server riêng. Tạo List mới khi cập nhật rows/columns; giữ columns/callback ổn định khi có thể để tận dụng cache, không sửa trực tiếp collection đang được truyền vào.

## Mã sử dụng trên website

Mỗi mục có ba chế độ: **Dùng nhanh** (đoạn ghép), **Tùy chỉnh** (thuộc tính và điểm nối nghiệp vụ), **Trang mẫu chạy được** (imports, State, controller/dispose, theme, tìm kiếm, table và FAB đầy đủ). Sao chép lấy đúng chế độ đang chọn; khi clipboard bị chặn có thể chọn text để copy thủ công.

Mã ngắn dùng tên model/callback minh họa, phải thay bằng ứng dụng thực tế. Trang hoàn chỉnh có thể dán vào main.dart của dự án đã thêm dependency youth_ui, hoặc chạy từ repo:

```sh
cd example
flutter run -t lib/customization_example.dart
```

[Source trang hoàn chỉnh](../example/lib/customization_example.dart). Không khởi tạo controller trong build; callback API phải xử lý lỗi/timeout và kiểm tra mounted trước khi setState sau await.
