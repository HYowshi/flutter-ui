# Nối API với Youth UI

## Tải dữ liệu: chỉ truyền hàm và cách hiển thị

```dart
UIAsyncView<List<Member>>(
  load: api.fetchMembers,
  isEmpty: (members) => members.isEmpty,
  builder: (context, members) => UITable<Member>(
    rows: members,
    columns: [UITableColumn(label: 'Họ tên', value: (member) => member.name)],
  ),
);
```

`api.fetchMembers` là hàm của ứng dụng trả `Future<List<Member>>`. Có thể dùng http, Dio, Firebase hoặc repository đang có. Core youth_ui không thêm HTTP dependency, không giữ base URL/token hay đổi kiến trúc state/router của ứng dụng.

Widget tự tải một lần sau khi mount, hiện loading, dữ liệu hoặc lỗi có nút Thử lại. `isEmpty` do ứng dụng chỉ định, không đoán cấu trúc JSON. Không có `isEmpty` thì mọi kết quả hợp lệ (kể cả null nếu T nullable) được chuyển cho builder. Exception không tự hiện `toString()` trên màn hình: mặc định dùng câu lỗi an toàn, tùy chỉnh bằng `failureMessage`. `onError` nhận lỗi/stack cho xử lý của ứng dụng; không log token, mã PIN hay body chứa dữ liệu riêng tư. `loadingBuilder`, `emptyBuilder`, `errorBuilder` thay giao diện theo ý muốn; errorBuilder nhận callback retry.

Các trạng thái mặc định tự cuộn khi cần. Khi dùng trong Column/scroll view, đặt vùng tải trong `SizedBox(height: ...)` hoặc giới hạn chiều cao hợp lý. Nếu builder trả UIPage/ListView, parent phải cung cấp chiều cao hữu hạn; không lồng hai scroll view không giới hạn. UITable vẫn là bảng phân trang trong bộ nhớ, không tự phân trang server.

## Tải lại, lọc và đổi tài khoản

```dart
// Tạo trong State, dispose khi đóng trang.
final list = UIAsyncController();

UIAsyncView<List<Member>>(
  controller: list,
  requestKey: (accountId, query),
  load: () => api.fetchMembers(query),
  isEmpty: (rows) => rows.isEmpty,
  builder: (context, rows) => MembersList(rows: rows),
);

final loaded = await list.reload(); // true: load hiện tại thành công, kể cả rỗng
```

- Rebuild, đổi theme hoặc tạo closure `load` mới không tự gọi API. Đổi `requestKey` theo equality hoặc gọi reload mới tải lại. Dùng key immutable và đưa account/query/record liên quan vào đó; không đưa token vào chuỗi log hay URL.
- Khi đổi requestKey, dữ liệu của yêu cầu trước được gỡ ngay. Kết quả/lỗi cũ không ghi đè phiên mới. Refresh dùng trạng thái loading thay nội dung cũ; subtree trong builder được dựng lại. Đặt form/draft cần giữ state bên ngoài vùng tải, như recipe.
- Các lần reload đồng thời dùng chung Future và không tạo request trùng. Đổi key trong khi request đang chạy có thể tạo request mới; đây không phải hàng đợi hay rate limiter.
- Future<bool> trả false khi lỗi, bị thay thế, view đã đóng, controller chưa gắn hoặc đã dispose. Không có callback gửi thành công giả sau khi view bị đóng.
- Một controller chỉ gắn với một view tại một thời điểm. Controller do app tạo thì app dispose; không tạo controller trong build. Có thể dùng `ListenableBuilder` với `controller.isLoading` để cập nhật riêng nút tải lại.
- Đây là bỏ qua kết quả lỗi thời, **không hủy request mạng**. Future Dart không tự có cancellation. HTTP client, Dio CancelToken, timeout và đóng client thuộc ứng dụng. Không có polling, retry tự động hoặc cache/offline ngầm.
- Nếu đã dùng Riverpod/BLoC hoặc cơ chế async riêng, tiếp tục dùng chúng và nối kết quả vào component/UIStateView; không bắt buộc thêm một lớp quản lý state nữa.

## Gửi Form và lỗi theo trường

```dart
UIForm(
  onSubmit: () => api.createMember(name: name.text, email: email.text),
  onSuccess: () { list.reload(); },
  children: [
    UITextField(name: 'name', label: 'Họ tên', controller: name),
    UITextField(name: 'email', label: 'Email', controller: email),
  ],
);

// Trong lớp API, ánh xạ lỗi validation của backend:
throw UIFormException(fieldErrors: {'email': 'Email đã được sử dụng.'});
```

UIForm đã có validation, trạng thái đang gửi, khóa gửi đồng thời và lỗi theo `name`. Tên trường phải khớp hợp đồng backend; không giả định mọi backend dùng cùng JSON. Đưa thông báo phù hợp người dùng vào UIFormException, không truyền HTML/stack trace/body lỗi thô. `onSuccess` chỉ chạy khi callback gửi hoàn tất thành công; thông báo kết quả và refresh danh sách do ứng dụng chọn.

Không tự retry POST sau timeout: server có thể đã lưu trước khi client mất kết nối. Idempotency key, giao dịch, xác thực, phân quyền và giới hạn số lần thử cần được thiết kế ở ứng dụng/backend.

## Recipe HTTP chạy được

[api_recipe.dart](https://github.com/HYowshi/flutter-ui/blob/main/example/lib/recipes/api_recipe.dart) là ví dụ đầy đủ dùng http.Client có thể inject để test. Trong repo:

```sh
cd example
flutter pub get
flutter run -t lib/recipes/api_recipe.dart --dart-define=API_BASE_URL=https://your-server.example/api/
```

Không truyền API_BASE_URL thì recipe hiển thị hướng dẫn cấu hình, không gọi server. URL trên là chỗ thay thế bằng backend của bạn. Nếu sao chép recipe sang ứng dụng khác, chạy `flutter pub add http`. Client do recipe tạo được đóng khi đóng trang; client inject do caller sở hữu. Cấu hình client/base URL cố định trong vòng đời trang; dùng Key mới khi thay cấu hình đó.

Hợp đồng ví dụ (hãy đổi để khớp backend thật):

| Endpoint | Request / response |
|---|---|
| GET `/api/members` | 200: `[{"id":1,"name":"An","email":"an@example.com"}]` |
| POST `/api/members` | JSON `{"name":"An","email":"an@example.com"}`; thành công 200/201 với JSON hoặc 204 không body |
| POST lỗi validation | 422: `{"fieldErrors":{"email":"Email đã được sử dụng."}}` |

Mẫu kiểm tra schema, giới hạn response 1 MiB, chờ header tối đa 20 giây và giới hạn thời gian chờ giữa các chunk 20 giây. Đây không phải deadline tổng hay hủy request header khi timeout. Các status bất ngờ dùng lỗi an toàn; không tự theo redirect hay retry. HTTPS được yêu cầu, ngoại trừ HTTP loopback cho phát triển. Token có thể lấy từ session hiện tại qua `MembersApi.accessToken`, không nhúng secret vào mã nguồn/dart-define. Backend lớn nên dùng server pagination thay vì nâng giới hạn tải tùy tiện.

Web cần CORS từ backend; không tắt kiểm tra TLS hay tìm cách vượt CORS. Native cần cấu hình quyền mạng của ứng dụng. Xem [Flutter networking](https://docs.flutter.dev/cookbook/networking/fetch-data) và [http Client/testing](https://pub.dev/packages/http). Demo “Kết nối API” trên website chỉ mô phỏng Future cục bộ; recipe/test mới minh họa transport HTTP và mapping GET/POST/422, không có backend được cung cấp kèm thư viện.
