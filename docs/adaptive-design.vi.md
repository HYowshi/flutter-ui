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


## Rà soát thiết kế giao diện — 0.10

Bản demo cũ chỉ chứng minh widget không overflow: form chia hai cột, card kéo giãn, không có cấu trúc điều hướng. Điều đó chưa chứng minh giao diện phù hợp mục đích hoặc dễ sử dụng. Bản mới dùng một tác vụ có thật — quản lý tài khoản — để kiểm chứng thiết kế, thay vì gom widget vào cùng một màn hình.

### Nguồn nghiên cứu

- [Flutter adaptive best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices): thiết kế theo điểm mạnh của từng hình thức sử dụng, làm tốt tương tác chạm trước, không dựa vào tên thiết bị và không chiếm hết chiều ngang màn hình. Áp dụng: dùng local width, giữ mục tiêu chạm, giới hạn độ rộng nội dung thay vì phóng to cả form.
- [Material canonical layouts qua Android Developers](https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts): quan hệ giữa nội dung chính và pane phụ quyết định bố cục; khi đổi kích thước cần giữ trạng thái. Áp dụng ở đây là supporting pane, không phải list-detail: gợi ý chỉ hỗ trợ form, không phải một trang nghiệp vụ ngang hàng.
- [Carbon 2x Grid](https://www.carbondesignsystem.com/building-blocks/foundations/2x-grid/guidelines) và [Spacing](https://www.carbondesignsystem.com/building-blocks/foundations/spacing/overview): bố cục bắt đầu từ mục tiêu/nội dung; khoảng cách và tương phản thể hiện quan hệ, cùng một tỉ lệ cho mọi thứ sẽ làm mất phân cấp. Áp dụng: title → mô tả → section → trường → helper; khoảng cách trong nhóm nhỏ hơn giữa các nhóm, phần hỗ trợ không cạnh tranh với hành động chính.
- [Fluent 2 layout](https://fluent2.microsoft.design/layout): cấu trúc và quy tắc co giãn cần phối hợp để nội dung giữ thứ bậc trên nhiều kích thước. Áp dụng: nội dung chính có max-width; điều hướng đổi cách trình bày, pane phụ chỉ sang cạnh khi đủ diện tích. Các breakpoint của Fluent/Material không được xem là cùng một tiêu chuẩn cứng.

Đây là tổng hợp để quyết định thiết kế của thư viện, không phải tuyên bố ứng dụng tự động đạt chuẩn của các hệ thiết kế trên.

### Những thay đổi cụ thể

| Vùng | Compact | Medium | Expanded |
| --- | --- | --- | --- |
| Điều hướng | Thanh dưới, nhãn rõ | Rail gọn | Rail mở rộng nếu chữ còn vừa |
| Nội dung chính | Một luồng cuộn | Giữ form ở độ rộng dễ đọc | Form một cột, không kéo giãn hết màn hình |
| Nội dung hỗ trợ | Disclosure, mở khi cần | Dưới nội dung chính nếu hai pane chưa vừa | Bên cạnh khi đủ độ rộng cho cả hai |
| Hành động | Footer ngoài vùng cuộn | Cùng vị trí ổn định | Cùng vị trí ổn định |
| Chữ lớn | Xuống dòng, tăng chiều cao | Ưu tiên điều hướng dưới và một luồng | Tách pane chỉ khi đủ chỗ sau khi tính cỡ chữ |

Ngưỡng của UIAdaptiveConfig vẫn600/1024. Đây là policy của thư viện, không sửa sang840 chỉ vì tài liệu Material có ngưỡng đó. Pane dùng mức tối thiểu440px cho phần chính (nhân cỡ chữ) +24gap +supportingWidth, còn max-width mặc định của phần chính là720. Tài khoản là một tác vụ nhập liên tiếp, nên không chia tên/email thành hai cột chỉ vì có chỗ. Header mobile dùng headline nhỏ hơn desktop, nhưng vẫn tôn trọng textScaler; không giảm chữ để chữa overflow.

UIAdaptiveScaffold giữ subtree qua GlobalKey khi đổi quan hệ layout. Điều hướng/route và dữ liệu vẫn do caller quản lý. Widget có Scaffold để xử lý bàn phím và SafeArea, cần parent có height hữu hạn. Supporting có thể thu gọn ở compact nên không đặt trường bắt buộc hoặc cảnh báo quan trọng vào đó. Footer tùy biến không được tự làm quá cao hoặc có Row không co giãn. leading tùy chọn; không ép biểu tượng thương hiệu vào ứng dụng của caller.

### Cách đánh giá

- Kiểm tra điều hướng dưới → rail → sidebar khi thay local width, đồng thời giữ nội dung đã nhập.
- Kiểm tra vị trí/độ rộng primary-supporting và disclosure mobile, RTL, chữ200%, keyboard inset và hành động còn nhìn thấy.
- Demo có profile/notification/security hoạt động, save có validation và reset có tác dụng. Chỉ state trong phiên demo; không có API/lưu bền vững.
- Kiểm tra trực quan ở360/768/1080. Frame preview thay đổi kích thước logical thật; fit-to-preview là zoom của bản trình bày, không phải thuật toán responsive của app. Luôn hiển thị %; chế độ kích thước gốc dùng scrollbar để kiểm tra chữ/vùng chạm ở100%.
- Không đồng nhất “test không overflow” với “thiết kế đẹp”. Vẫn cần rà soát ảnh render: thứ bậc có rõ không, thông tin phụ có lấn át không, form có bị kéo dài ngang không và hành động chính có dễ tìm không. Chưa có user study hoặc kiểm thử thiết bị vật lý.
