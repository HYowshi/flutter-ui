# Form và thông báo · 0.11

## Gọi nhanh

```dart
final email = TextEditingController(); // dispose trong State.dispose

UIForm(
  submitLabel: 'Lưu hồ sơ',
  onSubmit: () async {
    await api.save(email.text); // mạng do ứng dụng cung cấp
  },
  onSuccess: () => UINotice.show(context,
    message: 'Đã lưu hồ sơ.', tone: UITone.success),
  children: [
    UITextField(
      name: 'email', label: 'Email', controller: email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      validator: UIValidators.email(), clearable: true,
    ),
    UIPasswordField(
      name: 'password', textInputAction: TextInputAction.done,
      validator: UIValidators.minLength(8),
    ),
  ],
);
```

`onSubmit` tự thêm nút gửi; không truyền thì `UIForm(children: ...)` vẫn là form bố cục như trước. `maxColumns: 1` giữ một cột; mặc định tối đa hai, tự giảm theo không gian/cỡ chữ. Có thể dùng `formKey` và validator Flutter như cũ.

`UITextField` và `UIPasswordField` mặc định kiểm tra khi rời ô. Khi đã có lỗi, sửa nội dung sẽ kiểm tra lại. Gửi kiểm tra toàn form, focus và cuộn đến trường lỗi đầu tiên đang được mount. Đổi `autovalidateMode` nếu cần cách khác. `UIValidators.required`, `email`, `minLength`, `combine` là tiện ích cơ bản; email validator chỉ kiểm tra hình dạng, không chứng minh địa chỉ tồn tại. Quy tắc nghiệp vụ và validation server vẫn thuộc ứng dụng.

Trong lúc gửi, form khoá tương tác và nút hiển thị loading; gọi submit nhiều lần chỉ chạy một yêu cầu. Không thay cây field hay xoá dữ liệu khi thất bại. `TextInputAction.done` gửi form nếu không cung cấp `onFieldSubmitted` riêng. Các field hỗ trợ focus, autofill, định dạng qua `inputFormatters`, `maxLength` và giới hạn nhiều dòng. Không tự format điện thoại/số tiền nếu chưa biết vùng và đơn vị.

## Lỗi server và thử lại

```dart
onSubmit: () async {
  final result = await api.save(email.text);
  if (result.emailTaken) {
    throw const UIFormException(
      message: 'Hồ sơ chưa được lưu.',
      fieldErrors: {'email': 'Email đã được sử dụng.'},
    );
  }
}
```

`name` khớp key trong `fieldErrors`; hỗ trợ text, password và `UISelect`. Sửa trường nào thì xoá lỗi server của trường đó, giữ lỗi những trường khác. Lỗi chung hiển thị đầu form đến lần gửi tiếp theo. Với lỗi kết nối, throw `UIFormException(message: ...)` để thử lại mà giữ dữ liệu.

Lỗi không dự kiến dùng `failureMessage` an toàn, không đưa nguyên exception ra màn hình. Nhận lỗi gốc qua `onError(error, stack)` để xử lý/log theo quy định của ứng dụng. Không log mật khẩu hoặc dữ liệu nhạy cảm. `onSuccess` chỉ chạy khi callback hoàn tất thành công và form còn tồn tại.

Nếu cần nút gửi ngoài form, truyền `UIFormController`, gọi `await controller.submit()` và lắng nghe `isSubmitting`, `error`, `fieldErrors`. Giá trị trả về false nếu không hợp lệ, đang gửi, thất bại hoặc đã rời form. Một controller chỉ gắn một form; caller dispose sau khi tháo form. Khi form rời cây hoặc đổi `formKey` sang bản ghi mới, kết quả bất đồng bộ cũ bị bỏ qua ở UI; helper không huỷ HTTP request hay đảo ngược tác vụ server. Không lồng `Form` khác trong `UIForm`. Field được tạo lazy nhưng chưa mount sẽ không được Flutter Form kiểm tra; dùng validation model cho form nhiều bước/danh sách dài.

## Thông báo

```dart
UINotice.show(context,
  message: 'Đã lưu trữ tài liệu.',
  tone: UITone.success,
  actionLabel: 'Hoàn tác',
  onAction: restoreDocument,
);

UIAlert(
  title: 'Bạn đang ngoại tuyến',
  message: 'Bản nháp vẫn được giữ.',
  tone: UITone.warning,
  actionLabel: 'Thử lại', onAction: reconnect,
  // onDismiss: hideBanner,
);
```

- `UINotice.show` dùng ScaffoldMessenger gần nhất, cần gọi từ event/callback dưới MaterialApp và có Scaffold. Không cần provider riêng. Một notice hiện tại, tối đa năm mục tính cả mục đang hiện; hàng đợi đầy trả false, giữ các mục đã nhận.
- Trùng `id` sẽ bị bỏ qua khi đang hiện/chờ. Nếu không có id, so sánh nội dung, tone và nhãn hành động. Dùng id riêng theo tác vụ nếu câu chữ giống nhau nhưng dữ liệu/callback khác nhau. Đây là gộp bỏ bản trùng, không cộng số lượng hay thay callback của bản cũ.
- Thông báo thường tự đóng sau năm giây (`duration` chỉnh được). Có hành động hoặc tone danger thì mặc định giữ đến khi thao tác/đóng. `persistent` có thể ghi đè. Nút hành động bố trí dưới nội dung để có chỗ xuống dòng; mọi notice có nút đóng.
- `UINotice.clear(context)` đóng/xoá hàng đợi của helper trong messenger đó. Các SnackBar được ứng dụng tạo trực tiếp không bị xoá. Khi helper còn nằm sau một SnackBar khác, mục bị huỷ sẽ được bỏ qua khi đến lượt; không đóng thông báo bên ngoài để lấy chỗ. Nếu trộn hai hệ thống, thứ tự hiển thị vẫn theo ScaffoldMessenger. Khi cần xoá toàn bộ cả hai loại, dùng `UINotice.clearAll(context)` thay cho `ScaffoldMessenger.clearSnackBars()`: native Flutter không hoàn tất future `closed` của những mục chờ bị bỏ, nên gọi trực tiếp API native đó có thể làm helper mất tín hiệu để chạy tiếp.
- Hoàn tác gọi callback một lần, không tự phục hồi dữ liệu. Callback cần còn hợp lệ khi đổi trang: dùng service/model sống đủ lâu, hoặc kiểm tra `mounted` trước khi cập nhật State. Đợi API thành công trước khi báo thành công; xử lý lỗi của tác vụ hoàn tác tại ứng dụng.
- Notice dùng chuyển động và thông báo truy cập của SnackBar Flutter. `UIAlert` mặc định live region, có thể tắt bằng `liveRegion: false` cho hướng dẫn tĩnh. Dùng nội dung và biểu tượng cùng màu trạng thái; không dựa riêng vào màu.

Inline cho lỗi trường, banner cho trạng thái trang, notice cho phản hồi ngắn, dialog cho quyết định cần chặn luồng. Trung tâm thông báo có lưu trữ/đã đọc, lưu nháp và cảnh báo rời form chưa thuộc đợt nâng cấp này.

## Cơ sở và kiểm chứng

Theo API Flutter [validation](https://docs.flutter.dev/cookbook/forms/validation), [FormState.validateGranularly](https://api.flutter.dev/flutter/widgets/FormState/validateGranularly.html) và [SnackBar persist](https://api.flutter.dev/flutter/material/SnackBar/persist.html). Helper dựa trên trạng thái native của Flutter thay vì một hệ form/toast độc lập. Test bao gồm blur/correction, focus, chống gửi trùng, lỗi server, dữ liệu không controller, kết quả muộn sau unmount, hàng đợi/chống trùng/Hoàn tác, màn hình nhỏ + chữ 200% + RTL. Không thay thế kiểm thử với backend và công nghệ hỗ trợ thực tế của từng sản phẩm.
