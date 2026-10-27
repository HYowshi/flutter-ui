# Animation, textbox và thông báo · 0.13

## Nhịp chuyển động chung

`UIMotion.fast` =160 ms, `standard` =240 ms, `entrance` =320 ms. `UIMotion.resolve(context, duration)` trả zero nếu người dùng bật reduced motion. Đây là mặc định thiết kế của thư viện, có thể truyền duration riêng cho các widget chuyển động.

```dart
UIEntrance(key: ValueKey(replay), child: content);
UIAnimatedContent(child: Text(status, key: ValueKey(status)));
UIReveal(visible: expanded, child: details);
```

- `UIEntrance`: fade + dịch nhẹ, mặc định320 ms (trước đây450 ms). Giữ child ngoài animation builder, không dựng lại nội dung mỗi tick. Chặn bấm/focus ở đoạn đầu gần như vô hình. Đổi Key để chạy lại; không tự lặp.
- `UIAnimatedContent`: fade + scale nhẹ .98→1, đồng thời chuyển chiều cao. Truyền Key khác khi muốn chuyển nội dung. Widget cũ đang thoát không nhận bấm, focus hay semantics; không ép chiều cao cũ xuống kích thước mới gây overflow. Đây không phải cách quản lý state giữa hai màn hình/router.
- `UIReveal`: mở/thu chiều cao và opacity, giữ state child. Khi ẩn, không nhận pointer/focus, không đọc semantics và tắt ticker trong subtree. Child vẫn tồn tại/được layout, nên không dùng để giữ hàng nghìn item hoặc thay virtualized list. HTTP request/service bên ngoài không tự dừng. Field ẩn còn nằm trong Form vẫn tham gia validation; app cần quyết định trường nào được yêu cầu theo nghiệp vụ.
- Các widget trên cùng textbox/UIAlert bỏ thời lượng transition khi reduced motion được bật. Theme transition giữ cơ chế snapshot có giới hạn sẵn có. SnackBar dùng chuyển cảnh native Flutter, không reset animation controller đang dùng chung với thông báo ngoài helper; cài đặt truy cập native tiếp tục do Flutter quản lý.

`UIAnimatedSize(child: content)` cũng có thể dùng riêng. Khi reduced motion, helper bỏ size interpolator và giữ child qua một keyed subtree để không mất state; tránh AnimatedSize duration=zero thay đổi trong lúc layout.

## Textbox gọi nhanh

```dart
UITextField.search(
  onChanged: filterItems,
  onFieldSubmitted: search,
);
UITextField.multiline(
  label: 'Ghi chú', maxLength: 180,
);
UITextField(
  label: 'Ngân sách', initialValue: '250000',
  suffixText: 'VND', keyboardType: TextInputType.number,
  variant: UIInputVariant.filled,
);
```

`search` tự có icon tìm kiếm, nút xoá, bàn phím Search và nền mềm. `multiline` tăng từ3 đến6 dòng, dùng newline và capitalisation theo câu; quá6 dòng cuộn trong ô. Đây chỉ là UI, không tự truy vấn mạng hay debounce tìm kiếm.

Field thường thêm `initialValue`, `minLines`, `autofocus`, `prefixText`, `suffixText`, `textCapitalization`, `variant` và `errorText`. `outlined` giữ bề mặt mặc định; `filled` dùng surfaceContainerLow từ cùng bộ màu. Các trạng thái focus/error/disabled vẫn dùng InputDecoration native và theme chung. Lỗi/helper đổi chiều cao trong160 ms; không có rung hay animation lặp khi nhập.

Không truyền `initialValue` cùng controller. `initialValue` dùng lúc tạo State; thay nó sau đó không ghi đè phần người dùng đang sửa. Muốn cập nhật lập trình, dùng controller. Controller do ứng dụng truyền vẫn phải dispose ở ứng dụng. `readOnly` vẫn cho chọn/sao chép, khác `enabled: false`. `prefixText/suffixText` là affix theo cách hiển thị native Flutter; khi label chưa nổi, affix có thể chưa hiện. `errorText` do app kiểm soát, ưu tiên hơn lỗi managed form, app phải tự cập nhật/xoá nó. UIPasswordField cũng nhận variant/errorText. Bộ validator và name-bound server error từ0.11 giữ nguyên.

## Thông báo

```dart
UINotice.show(context,
  title: 'Đồng bộ hoàn tất',
  message: 'Các thay đổi đã được cập nhật.',
  tone: UITone.success,
);
```

Notice có title tùy chọn, nhịp chữ rõ, bo16 px và icon trạng thái. Title tham gia key chống trùng khi không truyền id. Nội dung dài giới hạn chiều cao theo viewport và keyboard insets, cuộn bên trong, không cắt mất nội dung. Nút đóng native nằm ngoài vùng nội dung cuộn. Với thông báo dài cần đọc, truyền `persistent: true` hoặc tăng duration; mặc định thông báo thường vẫn5 giây. Hoàn tác và danger giữ đến khi đóng như trước.

`UIAlert` đổi màu nền và chiều cao nhẹ khi đổi nội dung/tone, tắt duration khi reduced motion. Dùng cùng widget/key cho một trạng thái được cập nhật; tránh tạo nhiều banner chỉ khác màu cùng lúc. Hàng đợi, clear/clearAll và callback Hoàn tác giữ hợp đồng ở [hướng dẫn form & feedback](forms-feedback.vi.md).

## Kiểm chứng và giới hạn

Regression cho outgoing hit/focus/semantics, chuyển nội dung cao→thấp, giữ dữ liệu khi reveal, entrance không rebuild child mỗi frame, textbox Search/clear/read-only/multiline/error, notice dài trên320 px/chữ200% khi bàn phím chiếm240 px. Chạy lại toàn bộ test library/showcase và analyze. Các kiểm tra này không tương đương profile FPS/GPU trên thiết bị thật.

## Bảo trì 0.15.2: chuyển động và tài nguyên

`UIEntrance` giữ nguyên state con khi đổi reduced motion, hoàn tất ngay khi route tắt ticker và không chạy lại khi bật chuyển động. `UIAnimatedContent` tắt ticker bên trong nội dung đang thoát, trong khi controller của fade bên ngoài vẫn hoàn tất và gỡ nội dung cũ. Việc này không hủy Future, timer hay request do ứng dụng tạo.

`UIThemeTransition` bỏ overlay và dừng chuyển cảnh khi ứng dụng không còn resumed, route tắt ticker hoặc hệ thống bật high contrast/reduced motion. Snapshot hết dùng được dispose sau frame để tránh giải phóng khi render còn tham chiếu. Khi dùng lại ứng dụng, theme mới nhất được giữ. Ảnh chụp theme vẫn có thể chứa nội dung đang hiện trong app; đây không phải cơ chế chống chụp màn hình của hệ điều hành. Với màn hình nhạy cảm, dùng `UIApp(reduceMotion: true, ...)` hoặc `UIThemeTransition(duration: Duration.zero, ...)` để không tạo snapshot chuyển theme.

`UIPasswordField` luôn tắt suggestions, autocorrect và `enableIMEPersonalizedLearning`, kể cả khi người dùng bật hiện mật khẩu. Đây là yêu cầu gửi tới bàn phím; không thay thế mã hóa đường truyền, quản lý phiên hay lưu trữ an toàn trong ứng dụng.

Đã kiểm tra bằng widget test và analyzer; chưa đo GPU/FPS, điện năng hay bộ nhớ trên thiết bị thật. Không suy ra phần trăm tiết kiệm tài nguyên từ các kiểm thử này.

## PIN và OTP (0.16.0)

```dart
UITextField.pin(length: 4); // bàn phím số, tối đa 4 chữ số, che nội dung
UITextField.pin(
  label: 'Mã OTP',
  length: 6,
  obscureText: false,
  autofillHints: const [AutofillHints.oneTimeCode],
  onChanged: (code) {},
);
```

Preset chỉ nhận ASCII `0–9`, loại ký tự khác khi gõ/dán/autofill và cắt tại `length` (1–32, mặc định 6). Giá trị vẫn là String nên giữ `0012`. Bộ lọc áp dụng cả bàn phím vật lý; không chỉ dựa vào gợi ý bàn phím số của thiết bị. Nền tảng quyết định bàn phím thực tế.

Ô trống mặc định là tùy chọn. Nếu bắt buộc, truyền `validator: UIValidators.required()`; khi có nội dung, preset kiểm tra đúng số chữ số trước validator của ứng dụng. Đổi câu báo lỗi bằng `invalidCodeMessage`. `name`, `controller`, `focusNode`, `enabled`, `readOnly`, `errorText`, `variant` và callbacks vẫn tích hợp cùng UIForm. Controller do app tạo phải được app dispose. Giá trị gán bằng controller không đi qua input formatter; không tự sửa dữ liệu của caller, nhưng validation vẫn từ chối ký tự/độ dài sai.

Không tự chuyển focus, tự gửi khi đủ chữ số hay xác minh mã. Phím Done có thể gửi UIForm theo quy tắc hiện tại nếu không có onFieldSubmitted riêng. Việc xác minh, giới hạn số lần thử và thời hạn mã thuộc backend. Không ghi log hoặc đưa mã vào notice. Đối với OTP, autofillHints là gợi ý nền tảng, không tự đọc SMS.

`UITextField` thường cũng có `obscureText` (mặc định false, chỉ dùng một dòng). Ô mã số và nội dung được che tắt gợi ý, tự sửa và học bàn phím; UIPasswordField giữ nút hiện/ẩn hiện tại.
