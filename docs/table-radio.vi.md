# Table và Radio

## Radio

`UIRadioGroup<T>` nhận `options: List<UIOption<T>>`, `value: T?`, `onChanged`, nhãn nhóm và direction tùy chọn. Giá trị option phải duy nhất, không null. `value: null` là chưa chọn; `onChanged: null` khóa toàn nhóm. Từng option cũng có thể khóa riêng bằng enabled. Nhóm dùng label của UIOption; icon chưa được hiển thị.

Chọn một giá trị là trạng thái do ứng dụng quản lý, không tự lưu. Bố cục mặc định dọc; direction.horizontal chỉ chuyển ngang khi vùng chứa đủ rộng và chữ không quá lớn. Nhãn dài xuống dòng, mục tiêu bấm48px; không biến cả dòng/nhãn thành vùng hover. Nhóm độc lập không chia sẻ lựa chọn dù dùng cùng kiểu T.

Tab/Shift+Tab vào/ra nhóm, phím mũi tên đổi lựa chọn và Space chọn theo [RadioGroup native](https://api.flutter.dev/flutter/widgets/RadioGroup-class.html). Không dùng API groupValue/onChanged đã deprecated của từng Radio; tham khảo [migration của Flutter](https://docs.flutter.dev/release/breaking-changes/radio-api-redesign). Native semantics giữ trạng thái selected/disabled. `UIRadio<T>` dùng trực tiếp bên trong Flutter RadioGroup khi ứng dụng cần tự bố trí nhóm.

## Table

`UITable<T>` nhận danh sách rows và `List<UITableColumn<T>>`. Cột có label, `value(row)` cho text mặc định, cellBuilder tùy chọn, numeric để căn số, compare để cho phép sắp xếp. compare null thì cột không có hành động sort. Truyền comparator số cho số/ngày; không sort giá trị đã format bằng từ điển rồi kỳ vọng thứ tự số đúng. Ô chức năng/nút/badge có thể dùng cellBuilder; ứng dụng tự xử lý callback và constraint.

Desktop dùng DataTable với chiều cao dòng theo nội dung, bảng nhiều cột có cuộn ngang và scrollbar. Vùng dưới compact breakpoint hoặc text scale >1.5 chuyển thành thẻ có nhãn từng cột, giữ sort/paging/selection. Parent quản lý cuộn dọc. Nút sort trên mobile tương đương header desktop. Thứ tự bằng nhau giữ vị trí ban đầu; sort không thay đổi input.

Phân trang mặc định10, cho phép1–100. Chỉ dựng cell của trang hiện tại. Tuy nhiên rows vẫn là toàn bộ dữ liệu trong bộ nhớ, comparator sort toàn bộ danh sách; đây không phải server pagination hoặc DataGrid ảo hóa. [Flutter lưu ý DataTable đo cột hai lượt và không phù hợp với việc dựng hàng loạt dòng cùng lúc](https://api.flutter.dev/flutter/material/DataTable-class.html); giới hạn trang giúp giới hạn phần render, không phải cam kết FPS cho mọi dữ liệu.

Lựa chọn là tùy chọn: rowKey phải duy nhất, selectedKeys là Set<Object> do ứng dụng giữ, onSelectionChanged trả set bất biến mới. Chọn chỉ qua checkbox48px, không bắt bấm toàn dòng hoặc ô dữ liệu. Không tự xóa lựa chọn ở trang khác. Khi dữ liệu bị xóa hoặc đổi dataset, ứng dụng lọc lại selectedKeys nếu cần. Chưa cung cấp select-all/tri-state hoặc resize/reorder cột.

Giữ các key ổn định để nội dung ô không đổi state sang dòng khác khi sort. Có thể dùng rowKey ngay cả khi không bật selection. Nếu bỏ rowKey, hàng dùng vị trí của bản ghi trong input làm key; không nên bỏ với cell có state hoặc dataset thay đổi thứ tự. Ô ở trang khác bị tháo khỏi cây; dữ liệu nhập/chỉnh sửa cần được giữ trong model/controller bên ngoài theo rowKey nếu muốn giữ qua các trang.

Loading dùng thông báo tĩnh, không ticker. Empty có widget tùy biến. Trong loading/empty không hiển thị các thao tác của dữ liệu cũ. Dữ liệu mới phải tạo list rows/columns mới, tránh mutate tại chỗ vì thứ tự được cache. Thay đổi cấu trúc cột có thể reset sort; chỉ đổi callback/mảng cột mới với cùng nhãn cột giữ sort. Cột cần nhãn ổn định, nên dùng nhãn khác nhau.

Màu bề mặt/viền/chữ theo theme. Dòng được chọn dùng primaryContainer, ô tùy biến nhận UISurfaceScope của dòng để các UI khác tính màu theo bề mặt thực. RTL và chữ200% có kiểm thử; không bảo đảm một widget cố định quá lớn do cellBuilder tự cung cấp sẽ tự khớp.
