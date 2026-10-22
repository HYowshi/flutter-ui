# Rà soát UI và tương tác · 0.11.1

Phạm vi: mã thư viện và showcase, Form/Thông báo mới, hàng đợi dùng chung với SnackBar Flutter, vòng đời bất đồng bộ, Table, hình ảnh, bố cục desktop/mobile, chữ lớn và các smoke test hiệu năng sẵn có.

## Vấn đề tái hiện và sửa

1. **Xoá nhầm SnackBar bên ngoài.** Helper gọi `ScaffoldFeatureController.close()` khi notice của mình vẫn đứng sau một SnackBar native. Flutter yêu cầu controller đó phải là mục hiện tại; debug phát assertion, release có thể đóng nhầm mục đầu hàng. Nay đánh dấu huỷ, chỉ đóng khi notice của helper thực sự hiện. Mục kế tiếp vẫn chạy, thông báo bên ngoài được giữ.
2. **Lỗi server của bản ghi cũ xuất hiện ở form mới.** Khi thay `formKey` nhưng giữ UIForm/Controller, request cũ vẫn áp dụng lỗi vào trường mới. Nay đổi identity sẽ vô hiệu hoá kết quả cũ, bỏ loading và lỗi cũ. Không huỷ HTTP request hay tác vụ backend.
3. **Table quét dữ liệu lại khi chuyển trang.** Với 10.000 dòng, thao tác chuyển trang gọi rowKey 10.010 lần. Nay cache kiểm tra khoá khi rows/rowKey không đổi; regression yêu cầu dưới 100 lần gọi cho cùng thao tác, vẫn kiểm tra trùng khi thay dataset. Không sort lại danh sách index đã đúng thứ tự khi chưa chọn cột sort. Dữ liệu vẫn theo hợp đồng bất biến; sort toàn bộ là tác vụ trong bộ nhớ, không biến thành server pagination.
4. **Fallback ảnh demo tràn ngang ở 320 px/chữ 200%.** Row chứa Text không có flex nên đo theo chiều rộng tự nhiên. Nay giới hạn phần chữ bằng Flexible để xuống dòng trong khung.

5. **Mất nội dung field khi đổi thứ tự UIGrid.** Widget con có key nhưng SizedBox bao ngoài không có key, khiến Flutter tái tạo field khi reorder. Nay key được giữ ở lớp bao ngoài, bao gồm GlobalKey được bọc bằng local key để không trùng key trong cây; regression xác nhận nội dung nhập được giữ.

## Ranh giới tích hợp

`UINotice.clear` chỉ xoá các notice của helper. Native Flutter không hoàn tất future `closed` của các mục đang chờ bị loại bằng `ScaffoldMessenger.clearSnackBars()`. Vì vậy khi trộn hai API và cần xoá tất cả, dùng **`UINotice.clearAll(context)`** để reset cả hai hàng đợi cùng lúc. Không dùng riêng native `clearSnackBars()` cho một hàng đợi đang có helper notice. Không cần poll hay timer để đoán trạng thái native.

Notice có Hoàn tác hoặc lỗi quan trọng được giữ đến khi xử lý/đóng; các mục sau tiếp tục chờ theo thiết kế. Đây là điều cần cân nhắc khi chọn thông báo ngắn hay banner. Callback hoàn tác của app phải còn hợp lệ khi đổi trang.

## Kiểm chứng

- 154 bài kiểm thử thư viện và 13 bài kiểm thử showcase: tổng 167.
- Toàn bộ 15 mục showcase ở 320 px/chữ 200% và 1440 px/chữ mặc định, gồm điều hướng và nội dung cuộn.
- Regression cho native/helper queue, huỷ và thêm notice mới, reset toàn bộ, response cũ sau đổi identity, công việc chuyển trang, lỗi duplicate key trên dữ liệu mới, notice đang hiện khi thu cửa sổ từ desktop xuống 280 px.
- Kiểm tra trước đó vẫn bao gồm theme, selection, dropdown/keyboard, image lifecycle/fallback/retry, wireframe inference, adaptive scaffold, RTL và keyboard insets.
- Smoke test theme: cache state có giới hạn 128; 10.000 lần lookup ấm dùng lại object; chuyển theme dựng lại consumer hai lần trong 20 khung lấy mẫu ở lần chạy kiểm tra. Không dựng lại nội dung ở mỗi tick của transition.

Các kiểm tra này tìm lỗi layout, vòng đời và công việc dư; không chứng minh không còn bug và không đo được FPS/GPU/RAM trên mọi thiết bị. Chưa có profile Android/iOS/Windows native trên thiết bị thật trong lần rà soát này. Kết nối backend, CORS, ảnh mạng thực tế và widget tuỳ biến do app cung cấp vẫn cần kiểm thử tại sản phẩm sử dụng thư viện.
