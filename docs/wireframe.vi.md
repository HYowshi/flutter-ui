# Wireframe nhận diện cấu trúc

`UIWireframe.auto(data: sample)` tạo phác thảo tĩnh theo dữ liệu mẫu. Đây là công cụ chọn bố cục có quy tắc, không phải AI và không thể suy ra chính xác ý định sản phẩm chỉ từ JSON. Không chuyển dữ liệu thành các điều khiển hoạt động.

## Mới trong 0.12

Thêm `landing`, `event`, `pricing` (tổng 17 bố cục). `UIWireframe.auto(data: payload)` vẫn chỉ cần một lệnh; không cần chọn loại trước. Nhận root hoặc `hero` một cấp cho trang giới thiệu; ngày + địa điểm + tổ chức/đăng ký cho sự kiện; `plans/packages/goidichvu` hoặc list gói có giá + chu kỳ + tính năng cho pricing. `plan.isCollection` phân biệt danh sách sản phẩm với một chi tiết. Xem [thiết kế và giới hạn nhận diện](wireframe-design-research.vi.md).

Dấu hiệu được quét trên tối đa 64 khoá và dùng bằng chứng đồng xuất hiện trong các bản ghi, độc lập giới hạn 12 trường preview. Một nhánh hero có tối đa 32 khoá; pricing có tối đa 8×32 khoá, không duyệt đệ quy. Metadata `pagination/count/hasNext/nextCursor` được chấp nhận khi bóc envelope. Tên ảnh như `heroImage/poster/banner/coverImage` hỗ trợ CDN không có đuôi; URL tùy ý vẫn cần hint. Demo tự phân tích sau 350 ms dừng nhập, giữ plan cũ khi JSON chưa hợp lệ.

## Thứ tự quyết định

1. `layout` do người gọi chỉ định luôn thắng.
2. `fields` do người gọi cung cấp chọn form; `fieldTypes` ghi đè kiểu trường tương ứng trong dữ liệu mẫu, không tự đổi toàn màn hình thành form.
3. Bóc tối đa 3 lớp envelope `data/items/results` khi các khóa còn lại chỉ là metadata đã biết. Không tùy tiện bóc trường `data` của một đối tượng nghiệp vụ.
4. Xét dấu hiệu kết hợp: email/phone + password → form tài khoản; sender + message/text → chat; name/title + price + sku/currency/stock → product; stats + series/chart → dashboard; name + avatar + bio/email/role → profile; title + body/content → article; danh sách tương ứng → feed. Khóa tiếng Việt có dấu, snake_case và camelCase được chuẩn hóa.
5. Tập ảnh có đuôi raster nhận diện → gallery; date + event/action → timeline; nhiều boolean → settings. Các bản ghi đồng nhất có nhiều trường ngắn → table (mức bằng chứng medium).
6. Không đủ dấu hiệu → detail hoặc list. Map/List rỗng → empty. `null` không đồng nghĩa dữ liệu rỗng: chưa biết cấu trúc → detail trung tính.

`confidence` (`explicit/high/medium/low`) phản ánh mức bằng chứng trong quy tắc, không phải xác suất hay chỉ số đo trên dữ liệu người dùng. `reasons` giải thích quy tắc đã chọn. Nếu nhiều bố cục có bằng chứng gần nhau, mức đánh giá hạ xuống medium và nêu bố cục cạnh tranh. Ví dụ số có tên `price` chưa đủ để gọi là sản phẩm; URL bất kỳ chưa đủ để gọi là ảnh. Dữ liệu có thể khớp nhiều mục đích: khi đã biết màn hình, nên truyền `layout`.

## Loại trường và schema

12 loại: text, paragraph, number, date, email, phone, image, avatar, toggle, choice, password, section. Nhận diện giá trị bool/num/DateTime; chuỗi dài; email, số điện thoại quốc tế có dấu `+`, ngày ISO hợp lệ và URL/path đuôi ảnh. Các định dạng mơ hồ như ngày `01/02/2026`, mã số có toàn chữ số, ảnh CDN không có đuôi và tên trường không gợi ý ảnh cần `fieldTypes`.

```dart
UIWireframe.auto(data: payload, fieldTypes: const {
  'portrait': UIWireframeFieldType.avatar,
  'due': UIWireframeFieldType.date,
});

// Chưa tải dữ liệu, nhưng đã biết cấu trúc form:
UIWireframe.auto(fields: const [
  UIWireframeField('Email', type: UIWireframeFieldType.email),
  UIWireframeField('Password', type: UIWireframeFieldType.password),
  UIWireframeField('Remember', type: UIWireframeFieldType.toggle),
]);
```

Không suy đoán validator, quyền người dùng, trạng thái loading/error hay nghiệp vụ từ mẫu dữ liệu. Empty là bố cục minh họa, không có nội dung thông báo thật. Khi cần dùng làm skeleton tải, chỉ định preset/schema để khớp màn hình thực; không hứa hẹn giữ chính xác hình học của widget tùy biến.

## Hiệu năng và bố cục

- Mỗi lần inspect xét tối đa 8 phần tử, 64 khóa/bản ghi, 12 trường đầu ra. Chỉ xét cấu trúc ngoài, không duyệt đồ thị lồng nhau. Khóa dài được cắt ở 100 ký tự trước chuẩn hóa. Mẫu không đại diện có thể dẫn tới kết quả sai.
- `itemCount` là số khối xem trước, mặc định 3, cho phép 0–12; không tự dựng hàng nghìn bản ghi.
- `UIWireframe.inspect(...)` trả plan bất biến chỉ chứa tên/loại trường, bố cục và lý do; không giữ giá trị đầu vào. Dùng `UIWireframe.fromPlan(plan: plan)` để không phân tích lại khi rebuild. Khi dữ liệu/schema thay đổi, tạo plan mới.
- Không ticker, shimmer hay tải ảnh; không phản hồi chạm/bàn phím trong wireframe. Semantics chỉ giới thiệu một wireframe, không đọc các khối giả làm nội dung thật.
- Bảng thành thẻ ở vùng dưới compact breakpoint hoặc text scale >1.5. Grid dùng local constraints, không dò tên thiết bị. RTL, light/dark và vùng hẹp được hỗ trợ. Parent chịu trách nhiệm cuộn; vẫn phải cung cấp constraint hợp lệ cho cây Flutter.
- Không đánh giá FPS thiết bị thật từ test widget; giới hạn phép phân tích giúp tránh xử lý toàn bộ payload trong một lần dựng.

## Cơ sở Flutter

[LayoutBuilder](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html) cung cấp constraint của parent để bố trí theo vùng thực. [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) giải thích giới hạn mà widget phải tuân theo. [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html) và ExcludeSemantics được dùng để khối trang trí không bị đọc như nội dung/điều khiển thực. Các quy tắc nhận diện nghiệp vụ ở trên là quyết định của thư viện, không phải cam kết từ Flutter.
