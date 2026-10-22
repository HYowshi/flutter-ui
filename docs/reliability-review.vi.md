# Rà soát 0.6 — 22/10/2026

## Phát hiện và xử lý

1. Demo cũ tạo ThemeData mỗi lần đổi mode. UIApp chỉ tạo hai endpoint khi cấu hình màu/font/adaptive thay đổi; đổi mode dùng lại endpoint. Builder màu không chạy trong animation.
2. Nội suy ThemeData có thể kéo theo resolver tương phản và nhiều widget consumer ở từng frame. Transition mới ghi một snapshot theme cũ, áp endpoint mới một lần rồi fade lớp ảnh bằng render opacity. Không clone Navigator/form. Test kiểm tra giữ dữ liệu, mode hệ thống, yêu cầu liên tục, dispose giữa animation và reduced motion. Chụp dùng toImageSync/deferred raster, chỉ sau paint; không đọc pixel về CPU để mã hóa ảnh.
3. Giới hạn snapshot khoảng 2 triệu pixel, tối đa 1.5 DPR. Ảnh RGBA xấp xỉ 8MB, chưa tính GPU/các layer khác. Chỉ một overlay; giải phóng sau frame cuối, fallback tức thời nếu capture không được hỗ trợ. Pha trộn hai endpoint không bảo đảm tỷ lệ tương phản mọi pixel ở mọi frame; high contrast tắt fade.
4. Button resolver gọi lại cùng state/surface nhiều lần. Cache riêng theo YouthColors, giới hạn 128 phần tử, không chia màu nhầm giữa light/dark. Ma trận màu cũ vẫn được chạy.
5. Dropdown chuẩn hóa tiếng Việt và đo nhãn lặp lại. Giữ kết quả lọc/nhãn chuẩn hóa/height khi entries, query hoặc typography/width không đổi. Danh sách vẫn lazy.
6. Thêm UIApp, UIImage, wireframe với default dùng được ngay; demo phát hiện tràn ngang ở hàng đổi theme trên mobile và sửa thành Wrap. Avatar/thumbnail được tách khỏi stretch constraints; ảnh loading/error không đổi khung. Placeholder/wireframe tĩnh, không có ticker thường trực.

## Bằng chứng và giới hạn

Chạy flutter analyze, format, toàn bộ widget/unit tests ở thư viện và example; build web release và kiểm tra browser. Test mới bao gồm loading/error provider giả lập, asset cục bộ, decode buckets, static placeholders, snapshot disposal, resize và dữ liệu form. Không kiểm tra mọi nhà cung cấp mạng, font, plugin/platform view hay custom widget của người dùng.

Smoke test ghi nhận live theme consumer dựng lại 2 lần qua 20 bước pump của animation, không phải 20 lần. Một lần chạy debug test song song trên máy hiện tại: tạo theme pair 357778µs; 10000 lượt cache lookup kèm matcher 149046µs. Đây là JIT/test overhead, **không phải frame timing, FPS hay độ trễ release**; số thay đổi theo máy và tải. Test kiểm tra reuse/lifecycle, không dùng ngưỡng thời gian tuyệt đối dễ flake.

Flutter doctor: thiếu Android SDK và bộ MSVC/CMake/Windows SDK cần để profile native. Chưa profile trên thiết bị Android/iOS/Windows thật; không kết luận không có lag trên mọi thiết bị. Khi tích hợp: chạy profile mode trên thiết bị đích, thu FrameTiming/DevTools cho đổi theme, cuộn list và tải ảnh; đo cold/warm riêng và đối chiếu ngân sách màn hình 60/120Hz. Capture theme có chi phí raster một lần; có thể đặt UIThemeTransition(duration: Duration.zero) hoặc reduceMotion nếu thiết bị/platform view không phù hợp.

Nguồn chính thức: [Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance), [performance best practices](https://docs.flutter.dev/perf/best-practices), [Image.network và giới hạn decode trên web](https://api.flutter.dev/flutter/widgets/Image/Image.network.html), [ảnh trên web/CORS](https://docs.flutter.dev/platform-integration/web/web-images).

## API cũ

YouthUI.colors/init và các component 0.5 tiếp tục hoạt động. UIApp là cách gọi gọn tùy chọn, không thay router hiện có. UIImage không tự cung cấp ảnh/CDN, vượt CORS hoặc biến ảnh URL gốc thành file nhỏ; native decode hint không phải tối ưu byte tải. Wireframe là mẫu static, không tạo logic ứng dụng. Bộ UI không tự sửa custom Row/fixed-size hoặc dữ liệu sai ở ngoài primitive.
