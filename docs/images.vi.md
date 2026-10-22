# UIImage: nguồn, khung và fallback

## Gọi nhanh

```dart
UIImage(photoUrl,
  fallbackSource: 'assets/default-cover.png',
  fallback: const Center(child: Icon(Icons.hide_image_outlined)),
  placeholder: const UIWireframe.image(),
  semanticLabel: 'Ảnh bìa hoạt động',
);
UIImage.avatar(avatarUrl,
  fallbackSource: 'assets/default-avatar.png',
  fallback: const Center(child: Text('AN')),
);
```

Tất cả các constructor đều có fallbackSource, fallback, placeholder, errorBuilder. `.source` nay nullable. String null/rỗng/chỉ khoảng trắng không tạo AssetImage. HTTP(S) cần host; các scheme khác như file/data/blob cần provider phù hợp hoặc widget riêng. `.provider(MemoryImage(bytes))` nhận ảnh trong bộ nhớ; FileImage chỉ dùng trên nền tảng hỗ trợ. Không tự suy đoán chuỗi base64 hay đường dẫn file native.

## Chuỗi xử lý lỗi

1. Nếu có `errorBuilder`, gọi builder với lỗi gốc và dùng kết quả. Builder này thay thế toàn bộ xử lý lỗi, không đồng thời tải fallbackSource hay chèn retry.
2. Nếu không, thử `fallbackSource` một lần. Được dùng khi nguồn chính vắng mặt, HTTP/asset lỗi hoặc decoder không đọc được ảnh.
3. Nếu fallbackSource không hợp lệ, trùng nguồn chính hoặc cũng lỗi, dùng `fallback` widget nếu có.
4. Nếu không có widget riêng, hiển thị giao diện lỗi mặc định. Lỗi của ảnh dự phòng dừng ở icon cuối, không tự quay về nguồn chính.

`placeholder` chỉ là giao diện chờ, không phải giao diện báo lỗi. Dùng cùng placeholder khi tải nguồn chính và dự phòng. Mặc định là nền/icon tĩnh để không tạo vòng animation liên tục. Nếu tự truyền spinner/shimmer, ứng dụng chịu trách nhiệm vòng đời và reduced motion của nó.

Flutter cung cấp [Image.errorBuilder](https://api.flutter.dev/flutter/widgets/Image/errorBuilder.html) để thay thế ảnh lỗi. UIImage áp dụng builder cho cả nguồn chính và fallbackSource; widget Image tự đặt bên trong fallback/errorBuilder/placeholder vẫn cần tự xử lý lỗi nếu có. Không hứa hẹn bắt lỗi tùy ý trong cây widget do ứng dụng cung cấp.

## Retry

`allowRetry` mặc định bật trên ảnh thường/banner; tắt trên avatar/thumbnail/provider. Có thể bật lại theo nhu cầu. Chỉ giao diện lỗi mặc định có retry; không phủ nút lên widget hoặc ảnh fallback tùy biến.

- Không tự retry theo timer, không lặp khi mất mạng.
- Mỗi yêu cầu đang chờ chỉ xử lý một lần dù nhấn liên tục.
- Xóa cache của provider thực tế (bao gồm ResizeImage) và provider gốc trước khi tạo Image mới. Flutter yêu cầu [evict đúng key](https://api.flutter.dev/flutter/painting/ImageProvider/evict.html); xóa key gốc không đồng nghĩa xóa key đã resize.
- Nếu nguồn bị thay trong lúc chờ evict, kết quả cũ không làm reset ảnh mới. Dispose trong lúc chờ không gọi setState.
- Khung nhỏ/chữ lớn dùng IconButton có tooltip; dưới 48px mỗi chiều thì bỏ thao tác retry. Giao diện lỗi vẫn hiện icon.

Retry chỉ xóa cache phía Flutter; không đảm bảo bỏ cache HTTP/CDN/browser hoặc vượt CORS. Nếu URL cần token/header, ứng dụng cung cấp NetworkImage/provider đã cấu hình. Không ghi URL/lỗi kỹ thuật lên màn hình mặc định.

## Geometry và chất lượng

Nguồn chính, placeholder và fallback dùng chung khung, clip, fit và alignment. Avatar/thumbnail giữ hình vuông và co đều nếu vùng cha nhỏ. Ảnh thường/banner giới hạn chiều cao theo constraint cha; không ép kích thước vượt parent. Chọn `BoxFit.contain` khi cần thấy trọn ảnh, `cover` khi ưu tiên lấp đầy khung. Không tự đoán ý đồ cắt ảnh từ nội dung.

Native dùng decode width theo bucket128 đến tối đa2048, không ép cả width/height làm méo tỉ lệ. Gợi ý này có thể chưa đủ sắc nét với nguồn cực rộng/hẹp bị crop mạnh: dùng `optimizeDecode: false` hoặc provider/biến thể đã crop phù hợp. Web bỏ qua decode hint, cần `variants` từ server để giảm dung lượng thực. Các biến thể rỗng bị bỏ qua; width không dương là lỗi cấu hình cần sửa, không phải lỗi tải ảnh.

Không có disk cache/offline, SVG renderer, tải lại theo kết nối hay cache buster tự động. Asset dự phòng phải có trong pubspec. Ảnh raster/ảnh động phụ thuộc decoder và nền tảng Flutter; giảm chuyển động hiện áp dụng cho fade, không dừng frame GIF do decoder phát. Thông tin chung về provider/fit/semantics có tại [Flutter Image](https://api.flutter.dev/flutter/widgets/Image-class.html).

Widget tùy biến nhận constraint của khung, nhưng vẫn có thể overflow nếu tự đặt kích thước/text quá lớn. Với fallback nhiều nội dung, chủ động wrap/padding hoặc đặt khung phù hợp. `semanticLabel` mô tả ý nghĩa ảnh kể cả khi thay thế, không đưa đường dẫn hoặc thông báo lỗi kỹ thuật làm nhãn.
