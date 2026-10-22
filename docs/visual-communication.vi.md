# Thiết kế truyền thông, quảng cáo và cách áp dụng vào UI

Tài liệu này bổ sung góc nhìn truyền thông thị giác cho bộ UI. Mục tiêu là làm rõ giá trị, dẫn sự chú ý đúng chỗ và giúp người dùng nhận ra hành động tiếp theo. Đây là tổng hợp nghiên cứu và quy tắc thực hành cho project, không phải chứng nhận chuyên môn hoặc kết quả A/B test.

## Nguồn và phạm vi

- [Google: ABCDs of effective video ads](https://support.google.com/google-ads/answer/14783551?hl=en) đề xuất Attention, Branding, Connection, Direction. Điểm hữu ích: thông điệp tập trung, nhận diện nhất quán và CTA rõ. Đây là hướng dẫn quảng cáo YouTube; không lấy các mức tăng hiệu quả quảng cáo để hứa hẹn hiệu quả UI, không bê nguyên audio/pacing/video hook sang ứng dụng.
- [NN/g: Five principles of visual design](https://www.nngroup.com/articles/principles-visual-design/) giải thích vai trò của kích thước tương đối, phân cấp, cân bằng, tương phản và Gestalt. Áp dụng chúng để thứ tự nhìn bám sát thứ tự quan trọng của tác vụ; không bắt mọi màn hình theo một sơ đồ mắt cố định.
- [Rosenholtz và cộng sự, CHI2005: Feature Congestion](https://www.mit.edu/~yzli/clutter.pdf) đề xuất thước đo clutter dựa trên đặc trưng thị giác, được kiểm tra với đánh giá độ rối của bản đồ. Bài báo cũng phân biệt mật độ thông tin với cách biểu diễn/tổ chức, và lưu ý phụ thuộc tác vụ. Với UI, đây là cơ sở để đặt câu hỏi về cạnh tranh thị giác; không biến thước đo bản đồ thành điểm chấm thẩm mỹ phổ quát.
- [NN/g: Aesthetic-usability effect](https://www.nngroup.com/articles/aesthetic-usability-effect/) ghi nhận rằng hình thức đẹp có thể làm người dùng cảm thấy sản phẩm dễ dùng hơn hoặc bỏ qua vấn đề nhỏ. Điều này không chứng minh tác vụ thực sự nhanh hơn; vẫn phải quan sát thao tác và lỗi.

## Bộ kỹ năng cần áp dụng cùng nhau

### 1. Xác định thông điệp và đối tượng

Trước khi chọn màu/ảnh, viết một câu: màn hình này giúp ai đạt điều gì? Với trang thư viện: lập trình viên muốn dựng giao diện Flutter nhất quán và dùng lại nhanh. Tiêu đề nên nói được lợi ích đó, phần mô tả chỉ rõ cách sản phẩm đáp ứng. Từ ngữ gây ấn tượng nhưng không giải thích sản phẩm cần được thay bằng ý cụ thể.

Một vùng giới thiệu nên tập trung vào một thông điệp nổi bật. Đây là quy tắc biên tập của project, không phải định luật giới hạn trí nhớ con người. Dashboard vẫn có thể cần nhiều chỉ số và bảng; người sử dụng thường xuyên có mục tiêu khác người lần đầu xem landing page.

### 2. Art direction và key visual

Key visual cần minh họa điều đang hứa: component thật, cách phối theme hoặc một luồng làm việc cụ thể. Hình minh họa trang trí chỉ dùng khi nó bổ trợ ý nghĩa. Không thêm số người dùng, đánh giá, logo khách hàng hay kết quả kinh doanh nếu chưa có bằng chứng.

Với Flutter UI, preview dùng chính component và màu theme. Không dựng một mockup hứa hẹn chức năng thư viện chưa có. Ảnh chỉ cần một tiêu điểm rõ, crop và nền phù hợp để chữ vẫn đọc được; khi ảnh mang thông tin thì giữ nhãn tiếp cận.

### 3. Dẫn mắt bằng bố cục

Thứ tự mong muốn trong phần giới thiệu: lợi ích → minh họa/bằng chứng → hành động. Có thể tạo thứ bậc bằng cỡ chữ, độ đậm, khoảng cách và vị trí trước khi tăng số màu. Căn chỉnh theo một trục và nhóm những nội dung có quan hệ; khoảng cách ngoài nhóm cần đủ phân biệt với khoảng cách bên trong.

Cân bằng không bắt buộc đối xứng. Một khối chữ lớn có thể cân với một preview nhỏ hơn nhưng có nhiều chi tiết. Khoảng trắng cần phục vụ nhóm nội dung và nhịp đọc; không kéo giãn form hoặc giấu dữ liệu chỉ để trông thoáng.

### 4. Typography và nội dung

Dùng một cấp tiêu đề có ưu tiên rõ, một mô tả ngắn và nhãn hành động cụ thể. Cỡ chữ phải thể hiện quan hệ, không chọn từng cỡ ngẫu nhiên. Giữ tiếng Việt đủ dấu, chiều cao dòng và khoảng cách hợp lý; kiểm tra nhãn dài và font fallback. Cắt dòng headline phải được thử lại trên mobile và chữ lớn.

Nội dung ứng dụng khác quảng cáo: lỗi cần nói chuyện gì xảy ra và cách sửa; nút cần mô tả hành động thật; thông báo thành công chỉ xuất hiện khi thao tác thực sự thành công. Không dùng văn phong hô hào trong form, bảng dữ liệu hoặc xác nhận xóa.

### 5. Màu sắc, tương phản và nhận diện

Chọn màu theo vai trò của theme: primary cho hành động ưu tiên, surface cho cấu trúc, semantic colors cho trạng thái. Hạn chế các điểm nhấn cùng tranh sự chú ý trong một vùng quyết định. Không gán ý nghĩa cứng như màu đỏ luôn tăng chuyển đổi hoặc một màu luôn tạo cùng cảm xúc cho mọi văn hóa/ngữ cảnh.

Giữ nhận diện qua nhiều yếu tố: typography, hình dạng, khoảng cách, giọng viết và cách dùng ảnh. Không ép màu thương hiệu lên mọi bề mặt hoặc làm mờ hành động phụ đến mức khó đọc. Màu trạng thái không được là tín hiệu duy nhất.

### 6. CTA và đường đi tiếp theo

Trong hero của project, ưu tiên một CTA solid, một lựa chọn phụ nhẹ hơn nếu thực sự cần. Quy tắc này áp dụng cho vùng quyết định, không cấm các điều khiển cần thiết ở phần demo bên dưới. Nhãn CTA nói rõ đích đến và phải dẫn đến đúng nội dung.

Không thêm CTA thứ ba với lời mời chung chung dẫn sang một chức năng không liên quan. Phần xem trước nên minh họa lợi ích thay vì cạnh tranh với đường bắt đầu sử dụng. Không dùng khan hiếm giả, đếm ngược vô nghĩa, nút đóng bị giấu hoặc ép người dùng thực hiện hành động phụ.

### 7. Chuyển động có vai trò

Quảng cáo video cần nhịp kể chuyện; UI cần phản hồi và định hướng. Entrance dùng một lần nếu giúp nhận ra nội dung mới, chuyển trạng thái cần giữ liên hệ trước/sau. Không dùng shimmer, nhấp nháy, glow hoặc parallax liên tục chỉ để thu hút chú ý. Giữ reduced motion và không làm mất vị trí nhập/focus.

### 8. Thích ứng theo kênh và thiết bị

Trên mobile, đưa lợi ích và hành động tới gần luồng đọc, giảm chi tiết phụ, giữ vùng bấm và chữ thật. Desktop có thể đặt preview cạnh thông điệp, nhưng vẫn giới hạn độ dài dòng. Tablet cần cân mật độ và khả năng chạm. Bản preview thu nhỏ trong website không thay thế việc kiểm tra UI ở kích thước gốc.

## Áp dụng ngay vào trang giới thiệu

- Đổi headline thành “UI đồng bộ. Bắt đầu từ một màu.” để nêu lợi ích và khả năng thật.
- Mô tả rõ workflow: khởi tạo theme từ màu thương hiệu, ghép component cho Flutter mobile/desktop/web.
- Đặt “Bắt đầu sử dụng” làm CTA chính, “Xem component” là lối khám phá phụ.
- Thay CTA “Thử ngay” dẫn sang Animation trong preview bằng minh họa vai trò màu. Preview tập trung giải thích theme.
- Giữ các component tác vụ như Table, Radio và form có mật độ phù hợp, không phủ phong cách quảng cáo lên chúng.

## Cách rà soát thiết kế sau này

1. Nêu được đối tượng, tác vụ và thông điệp chính bằng một câu.
2. Xem screenshot: yếu tố nổi bật nhất có đúng là điều người dùng cần chú ý không?
3. Kiểm tra headline, preview và CTA có cùng nói về một lợi ích không.
4. Thử đọc và thao tác ở mobile/desktop, light/dark, chữ lớn và reduced motion.
5. Thử bằng bàn phím, kiểm tra focus, label, contrast và thông báo lỗi.
6. Đo hoàn thành tác vụ, lỗi, khả năng tìm thấy hành động và mức hiểu nội dung. Nếu có A/B test, xác định giả thuyết và thước đo trước; không lấy số lần bấm cao hơn để kết luận trải nghiệm tốt hơn nếu người dùng hiểu nhầm.

Những quy tắc trên hướng dẫn quyết định thiết kế; không tự chứng minh UI đã đẹp, dễ dùng hoặc tăng chuyển đổi. Cần phản hồi người dùng và quan sát sử dụng thật để kiểm chứng.
