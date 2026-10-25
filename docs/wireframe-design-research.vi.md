# Nhận diện nội dung và thiết kế quảng bá · 0.12

## Đã xem gì

- [Google Ads: responsive display creative](https://support.google.com/google-ads/answer/9823397?hl=en): đã mở và xem các cặp hình đúng/sai về ảnh rõ/mờ, màu đầy đủ/bạc màu, cùng các tỷ lệ hình. Tài liệu phân biệt image asset với headline, mô tả, logo và nút để chúng có thể tái phối bố cục. Với wireframe: giữ vùng ảnh riêng, không giả lập chữ/nút dán vào ảnh.
- [Google Ads: effective display ads](https://support.google.com/google-ads/answer/1722134?hl=en): thông điệp rõ, mô tả cụ thể, hình ảnh chất lượng và các định dạng thích ứng. Áp dụng thành một vùng tiêu đề, một vùng giải thích và một hành động chính. Không suy diễn rằng bố cục này sẽ tăng chuyển đổi trong mọi ứng dụng.
- [Android: content composition and structure](https://developer.android.com/design/ui/mobile/guides/layout-and-content/content-structure): grid phân cấp cho nội dung có trọng tâm, modular grid cho nội dung ngang hàng, khoảng trống và containment để nhóm. Áp dụng: hero chia hai vùng khi đủ rộng, dọc trên vùng nhỏ; bảng gói và danh sách sản phẩm dùng thẻ ngang hàng.

Đây là tổng hợp và quyết định của thư viện từ tài liệu trên, không phải thuật toán được Google chứng nhận. Quy tắc quảng cáo áp dụng cho vùng giới thiệu/quảng bá; form, table, chat vẫn ưu tiên nhiệm vụ tương ứng. Không sao chép ảnh quảng cáo vào package, không thêm badge tin cậy hay số liệu kinh doanh giả.

## Kết quả triển khai

1. **Landing:** tiêu đề + CTA + lợi ích/subtitle/hero media. Nhận dạng cả root và một nhánh `hero` được đặt tên rõ. Hero có một vùng chữ và một ảnh chủ đạo nếu dữ liệu có dấu hiệu ảnh; mobile xếp dọc, vùng >=720 và cỡ chữ phù hợp mới chia ngang. Bên dưới là các khối hỗ trợ tách bằng khoảng cách.
2. **Event:** tên + lịch + địa điểm + dấu hiệu đăng ký/tổ chức. Thời gian/địa điểm được nhóm gần nhau, CTA riêng. Không suy ra sự kiện chỉ từ một ngày hay một chữ `event`.
3. **Pricing:** các gói có tên + giá + chu kỳ + tính năng. Chia cùng hệ thẻ, các phần tên/giá/chu kỳ/tính năng/hành động có cấp bậc rõ. Không tự tạo phần trăm giảm giá, nhãn “phổ biến” hay gói được chọn.
4. **Product collection:** vẫn nhận diện `product` nhưng `plan.isCollection` giữ bản chất danh sách; dựng nhiều thẻ thay vì ép thành một trang chi tiết.

Các hình trong wireframe là khối trung tính có semantics trang trí, không phải quảng cáo hoàn chỉnh và không hiển thị giá trị người dùng. CTA là placeholder, không có hành động thật. `itemCount` tiếp tục là số mục preview do người gọi kiểm soát.

## Chất lượng nhận diện

Quét tất cả tối đa 64 khoá thay vì để giới hạn 12 trường render ảnh hưởng quyết định. Nếu quá 12 trường, ưu tiên tên/giá/hành động và kiểu trường có ý nghĩa hơn metadata ngắn. Mỗi bản ghi được chuẩn hoá một lần, dùng lại cho nhiều quy tắc. Dấu hiệu chat/feed/product/event/pricing cần cùng tồn tại trong ít nhất 60% bản ghi mẫu, tránh ghép các trường rời rạc thành đối tượng giả.

60% là ngưỡng heuristic do thư viện chọn, không phải xác suất đo trên tập dữ liệu kiểm chuẩn. Nếu hai bố cục cạnh tranh gần nhau, confidence vẫn bị hạ theo cơ chế cũ. `layout`, `fields`, `fieldTypes` tiếp tục là cách khai báo ý định khi dữ liệu không đủ rõ. Nhận ảnh CDN không đuôi chỉ khi tên trường có nghĩa ảnh; URL tùy ý vẫn không coi là ảnh.

Chỉ lấy 8 phần tử, 64 khoá/bản ghi, tối đa 3 lớp envelope đã biết; hero tối đa 32 khoá một cấp và plans/packages/goidichvu tối đa 8 gói ×32 khoá. Không duyệt đệ quy, không tải ảnh, không gọi AI, không giữ giá trị trong plan. Tránh tự “hiểu” mọi object lồng nhau vì có thể vừa tốn tài nguyên vừa đoán nhầm cấu trúc nghiệp vụ.

Demo tự phân tích JSON sau 350 ms ngừng nhập; di chuyển con trỏ không kích hoạt phân tích lại. Timer được huỷ khi rời trang; JSON lỗi/chuỗi >20.000 ký tự giữ plan cũ. Package không cài timer; `UIWireframe.auto(data: ...)` nhận dữ liệu mới khi Flutter rebuild. Có thể giữ `UIWireframe.inspect`/`fromPlan` để tránh phân tích lại nếu dữ liệu không đổi.

Kiểm thử: ba layout mới trong ma trận 280/768/1280 px, chữ 200%, RTL, dark; dấu hiệu sau trường thứ 12, nested hero/CDN không đuôi, tiếng Việt, precedence, dữ liệu mâu thuẫn, cycle và tự phân tích/unmount của demo.
