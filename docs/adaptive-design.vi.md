# Adaptive UI: quyết định và phạm vi

## Cơ sở

- [Flutter: general approach](https://docs.flutter.dev/ui/adaptive-responsive/general): dùng constraint thực của vùng chứa cho layout, MediaQuery cho dữ liệu viewport/hệ thống.
- [Flutter: best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices): không suy layout từ tên thiết bị; giới hạn độ rộng nội dung trên màn hình lớn; hỗ trợ cửa sổ resize.
- [Flutter: accessibility UI design](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling): giữ khả năng đọc khi người dùng tăng chữ; bố cục phải dành đủ không gian.
- [Flutter: SegmentedButton](https://api.flutter.dev/flutter/material/SegmentedButton-class.html): lựa chọn được điều khiển từ ứng dụng, giữ semantics/keyboard native trong chế độ ngang.

## Design policy của thư viện

Các ngưỡng 600/1024px, min column 280px, max content 1120px là mặc định có thể đổi, không phải kết luận rằng mọi giao diện có cùng ngưỡng tối ưu. Không thu nhỏ font để cứu overflow. Kết nối chuột chỉ đổi khoảng đệm; không suy rằng PC luôn có chuột hoặc mobile không có bàn phím. Vùng chạm vẫn ≥48px cho button, checkbox và switch.

`UIAdaptiveBuilder` đăng ký thay đổi mouse tracker và nhận constraints qua LayoutBuilder; MediaQuery làm dependency cho text scaler, hướng chữ và size khi không có width hữu hạn. Chỉ có một nhóm mặc định trong ThemeExtension, không cần cài thêm wrapper. Khi không có YouthUI theme, config vẫn có fallback mặc định.

SegmentedButton native dùng các segment cùng chiều rộng. Thư viện đo nhãn bằng TextPainter với kiểu chữ, hướng chữ và text scaler thực; dự trù 64px mỗi segment cho padding + dấu chọn/icon. Nếu tổng không vừa, đổi thành Column các button có cùng giá trị được chọn. Đây là ước lượng bảo thủ, không phải thuật toán đánh giá thẩm mỹ. Giữ callback, disabled và semantics của từng lựa chọn.

Form/grid dùng Wrap các tile có width tính từ vùng chứa, không fixed aspect ratio. Khi tăng chữ, min column width tăng (tối đa hệ số 2) để giảm số cột. Widget con giữ cùng thứ tự/identity khi resize, nên TextFormField không mất controller nội bộ. Không dùng AnimatedSwitcher giữa các bố cục form vì có thể làm mất state.

## Kiểm chứng

Widget tests kiểm tra bố cục 280/360/768/1440px ở cỡ chữ 100/200%, gồm RTL; form chuyển cột vẫn giữ dữ liệu; narrow panel trong viewport rộng; nhóm nút chuyển stack/wrap; long label; row không ràng buộc width; kết nối chuột và vùng chạm; chọn segmented vẫn giữ giá trị qua fallback; config truyền đủ sang light/dark. Showcase test kiểm tra đổi preview 360→1080→360 và chữ lớn vẫn giữ nội dung form.

Đây không phải chứng nhận mọi màn hình, mọi font hoặc mọi thiết bị đã được thử. Chưa kiểm tra bằng thiết bị vật lý iOS/Android/desktop; các test dùng Flutter widget harness và trình duyệt. Caller vẫn sở hữu nội dung, state, thông tin validation và điều hướng. Không tự suy ra kiến trúc thông tin, chuyển tab thành drawer hay sửa một Row/fixed height tùy ý ngoài các primitive đã cung cấp. Không hỗ trợ intrinsic sizing quanh các widget dùng LayoutBuilder; dùng bounded constraints. UIPage phải nằm trong vùng có chiều cao hữu hạn, và UIGrid không thay thế danh sách lazy cho dữ liệu lớn.
