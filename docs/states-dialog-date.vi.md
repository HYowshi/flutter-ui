# Trạng thái màn hình, popup và chọn ngày

## Trạng thái màn hình

```dart
UIStateView.loading(progress: uploadProgress, onAction: cancelUpload);
UIStateView.empty(message: 'Tạo dự án đầu tiên của bạn.', onAction: createProject);
UIStateView.error(message: 'Chưa tải được nội dung.', onAction: reload);
UIStateView.offline(onAction: reconnect);
UIStateView.forbidden(onAction: requestAccess);
UIStateView.success(message: 'Mọi thay đổi đã lưu.', onAction: continueFlow);
```

Chỉ `onAction` mới làm xuất hiện nút chính; bỏ callback thì chỉ còn nội dung. Nhãn mặc định theo trạng thái và có thể đổi bằng `actionLabel`. Loading nhận tiến độ 0–1; bỏ progress dùng spinner, reduced motion dùng biểu tượng tĩnh. Thư viện không tự chạy request, dò mạng, cache bản nháp hay xác định quyền. Nội dung demo chỉ minh họa; ứng dụng phải thực hiện nghiệp vụ thật.

Tùy chỉnh toàn bộ nội dung và hình bằng constructor chung:

```dart
UIStateView(
  kind: UIStateKind.empty,
  title: 'Không có kết quả', message: 'Hãy thử từ khóa ngắn hơn.',
  illustration: const Icon(Icons.search_off_outlined, size: 64),
  actionLabel: 'Xóa bộ lọc', onAction: clearFilter,
  secondaryActionLabel: 'Quay lại', onSecondaryAction: goBack,
);
```

Nội dung tối đa 480px, tự cuộn khi vùng chứa thấp/chữ lớn; parent vẫn cần cung cấp kích thước hợp lệ. Illustration nên có kích thước hữu hạn; mặc định mang tính trang trí và được loại khỏi semantics, thông tin cần thiết hãy đưa vào title/message. Các nhãn mặc định của thư viện hiện là tiếng Việt; thay title/message/actionLabel để bản địa hóa nội dung cho dự án.

## Dialog / Bottom Sheet

```dart
final accepted = await UIAdaptiveDialog.confirm(context,
  title: 'Lưu thay đổi?', message: 'Các cập nhật sẽ được lưu vào hồ sơ.',
  confirmLabel: 'Lưu',
);
if (!context.mounted || !accepted) return;
await saveProfile();
```

`confirm` trả true khi bấm nút chính; hủy, đóng, Back hoặc dismiss trả false. `danger: true` đổi vai trò màu cho hành động nhạy cảm. Không tự gọi API hay chạy thao tác xóa.

```dart
final result = await UIAdaptiveDialog.show<String>(context,
  title: 'Chỉnh sửa', presentation: UIPresentation.auto,
  dismissible: true, showClose: true, maxWidth: 600,
  builder: (routeContext) => const YourEditor(),
  actionsBuilder: (routeContext) => [
    UIButton(label: 'Áp dụng',
      onPressed: () => Navigator.pop(routeContext, 'saved')),
  ],
);
```

- `auto`: khi mở, vùng MediaQuery nhỏ hơn compactBreakpoint (mặc định600px) dùng sheet; còn lại dialog. Có thể ép `UIPresentation.dialog` hoặc `.sheet`.
- Resize khi đang mở giữ nguyên route để tránh mất dữ liệu/focus; kích thước và cuộn tiếp tục thích ứng. Kiểu trình bày mới được chọn khi mở lần kế tiếp.
- Header, body và actions cùng vùng cuộn, nên nội dung dài hoặc bàn phím lớn vẫn có thể tới được thao tác cuối. Không đặt Expanded/ListView vô hạn trong builder; dùng Column(mainAxisSize: min), danh sách có chiều cao hữu hạn hoặc sliver riêng khi nội dung rất lớn.
- `dismissible: false` chặn chạm ngoài, Back và kéo sheet để đóng; nút đóng/callback `Navigator.pop(routeContext)` vẫn chủ động đóng. Với showClose:false, hãy cung cấp thao tác kết thúc hoặc hủy trong nội dung.
- Cả hai dùng root navigator mặc định; `useRootNavigator:false` khi muốn route thuộc navigator lồng nhau. Dùng context trong builder/actionsBuilder để pop đúng route.
- Native routes quản lý focus/barrier và bàn phím. Reduced motion bỏ transition của wrapper. Muốn thay đổi state trong popup dùng StatefulWidget riêng hoặc StatefulBuilder; setState của trang phía sau không tự cập nhật route.
- Theme được capture theo cơ chế route Flutter. Provider đặt dưới navigator không tự được chuyển sang route; truyền dữ liệu/controller cần dùng hoặc đặt provider ở scope thích hợp. Wrapper không cung cấp state restoration.

## Ngày và khoảng ngày

```dart
DateTime? appointment; // biến trong State
UIDateField(
  name: 'appointment', label: 'Ngày hẹn', value: appointment,
  onChanged: (date) => setState(() => appointment = date),
  firstDate: DateTime(2026), lastDate: DateTime(2030, 12, 31),
  selectableDayPredicate: (date) => date.weekday <= DateTime.friday,
  validator: (date) => date == null ? 'Hãy chọn ngày hẹn' : null,
  helper: 'Chỉ chọn ngày làm việc.',
);
```

`value` và callback do ứng dụng sở hữu, hãy cập nhật value trong onChanged. Callback null hoặc enabled:false vô hiệu hóa sửa. Hủy picker giữ nguyên giá trị; nút xóa (clearable mặc địnhtrue) gửi null. Field dùng được trong Form thông thường hoặc UIForm. Với UIForm, name nối lỗi server, tự khóa khi gửi và xóa lỗi của đúng trường khi người dùng đổi ngày. Form reset không tự reset state của ứng dụng: khi muốn reset controlled field, đặt value về giá trị ban đầu.

Mặc định khoảng ngày 01/01/1900–31/12/2100. Bounds tính cả hai đầu và bỏ phần giờ. Nếu giá trị của field không còn hợp lệ sau khi đổi bounds/predicate, validator báo lỗi; mở picker không đưa giá trị cũ sai vào native picker. Hãy luôn kiểm tra validator/giá trị trước khi gửi dữ liệu.

```dart
final date = await UIDatePicker.show(context,
  initialDate: appointment,
  firstDate: DateTime(2026), lastDate: DateTime(2030, 12, 31),
  title: 'Ngày hẹn',
  entryMode: DatePickerEntryMode.input, // calendar / input / *Only
);
final range = await UIDatePicker.range(context,
  initialRange: selectedRange, title: 'Khoảng thời gian',
  confirmLabel: 'Áp dụng',
);
```

Helper trả null khi hủy. Với range, khi vùng hẹp dưới400px và chữ lớn/tiêu đề không đủ chỗ, mặc định mở nhập ngày trực tiếp để tránh header native tràn; đo text một lần lúc mở, không giảm text scale. Có thể chủ động truyền entryMode để chọn cách trình bày. Cỡ tiêu đề range mặc định dùng titleLarge ở vùng hẹp, giữ style DatePickerTheme do caller chỉ định. Bounds đảo, initialDate/initialRange ngoài khoảng, initialDate bị predicate loại trừ sẽ ném ArgumentError trước khi mở, kể cả release. `selectableDayPredicate` hiện chỉ áp dụng chọn ngày đơn; range dùng khoảng giới hạn, không tự áp quy tắc ngày làm việc hay số ngày tối đa. Không tự quét toàn bộ lịch để tìm ngày thay thế. Phần định dạng/parse/chọn ngày/bàn phím/calendar theo Flutter native; hiệu ứng của picker native do Flutter quản lý.

DateTime kết quả là ngày không kèm giờ, không phải timestamp hay lịch hẹn đã gắn múi giờ. Ứng dụng phải quyết định giờ, timezone và cách lưu; không tự chuyển date-only sang UTC. Cập nhật value/bounds, đổi tên field hoặc hủy owner khi picker mở sẽ bỏ qua kết quả cũ; native route vẫn có thể được đóng bình thường.

`invalidDateMessage` thay lỗi khi ngày nằm ngoài bounds/predicate. `format` thay cách hiển thị field, không đổi parser của hộp nhập native. `locale` trên field/helper chỉ đổi picker; locale của app quyết định hiển thị mặc định trong field. Dùng UIApp.locale để đồng bộ:

```dart
UIApp(
  primary: Colors.indigo,
  locale: const Locale('vi'),
  home: const HomePage(),
);
```

UIApp cài sẵn delegates Material/Widgets/Cupertino, supportedLocales mặc định en/vi và theo hệ thống khi không truyền locale. Có thể truyền thêm delegates (ưu tiên trước mặc định) và supportedLocales. Nếu dùng MaterialApp riêng, tự cấu hình flutter_localizations/delegates và supportedLocales để native picker có locale mong muốn. Những chuỗi nghiệp vụ do caller truyền vẫn phải được ứng dụng dịch.
