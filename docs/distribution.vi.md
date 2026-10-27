# Cài đặt và bản phân phối

Bản hiện tại: **youth_ui 0.15.2**, giấy phép **MIT**. Thư viện dùng Flutter >=3.47.0 và Dart ^3.13.0. Không phải package tên flutter_ui trên pub.dev.

## Cài trực tiếp từ GitHub

Cách nhanh nhất: mở terminal tại thư mục ứng dụng và chạy một lệnh. Lệnh tự ghi dependency và tải gói:

```sh
flutter pub add "youth_ui@{git: {url: https://github.com/HYowshi/flutter-ui.git, ref: v0.15.2}}"
```

Không cần tải ZIP hay chạy thêm `flutter pub get` sau lệnh thành công. Bản GitHub cần Git và kết nối mạng. Chưa dùng `flutter pub add youth_ui` vì bản này chưa phát hành trên pub.dev.

Nếu muốn sửa thủ công, thêm vào pubspec.yaml của ứng dụng:

```yaml
dependencies:
  flutter:
    sdk: flutter
  youth_ui:
    git:
      url: https://github.com/HYowshi/flutter-ui.git
      ref: v0.15.2
```

Chạy `flutter pub get`, rồi import `package:youth_ui/youth_ui.dart`. Không cần sao chép từng file trong lib/src. Tag cố định giúp các dự án không tự thay đổi theo main; commit cụ thể là mức ghim chính xác nhất.

## Dùng ZIP / TAR.GZ

Tải file tại [GitHub Releases](https://github.com/HYowshi/flutter-ui/releases/tag/v0.15.2), đối chiếu SHA256SUMS.txt rồi giải nén. Hai định dạng có cùng bộ file, một thư mục gốc youth_ui-0.15.2 và release.json ghi commit/hash từng file.

Ví dụ đặt thư viện vào `packages/youth_ui-0.15.2` của app:

```yaml
dependencies:
  flutter:
    sdk: flutter
  youth_ui:
    path: packages/youth_ui-0.15.2
```

`path` tính từ thư mục chứa pubspec.yaml của app. Không dùng đường dẫn ổ D của người phát triển trong dự án chia sẻ cho người khác. Thêm dependency Git thay vì path khi không muốn đưa toàn bộ thư viện vào repo app.

```dart
import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

void main() => runApp(const UIApp(
  primary: Colors.indigo,
  home: Scaffold(body: UIPage(children: [Text('Hello youth_ui')])),
));
```

Gói chỉ chứa source đã theo dõi bằng Git, tài liệu, ví dụ và kiểm thử/công cụ bảo trì; không có .git, cache SDK, log, file IDE hay output build. File SHA-256 kiểm tra tính toàn vẹn, không thay thế chữ ký xác minh danh tính.

## Chạy ví dụ và hướng dẫn AI

Trong thư mục giải nén: `cd example`, `flutter pub get`, rồi chạy `flutter run -t lib/recipes/auth_recipe.dart`, `lib/recipes/editor_recipe.dart` hoặc `lib/customization_example.dart` (mỗi lần chọn một entry point). Showcase hỗ trợ web; app native tự cung cấp platform runner của dự án đó.

[Hướng dẫn AI](ai-guide.md), [API reference](api-reference.md) và llms-full.txt đi cùng gói. Cổng công khai: https://hyowshi.github.io/flutter-ui/ai/.

## Tạo lại bản phân phối

Từ checkout sạch của đúng commit:

```sh
python tool/generate_ai_docs.py --check
python tool/build_release.py
```

Artifact nằm trong dist/, thư mục này không được commit. Script chỉ đọc file Git-tracked trong allowlist, từ chối checkout chưa commit, kiểm tra manifest của cả ZIP/TAR.GZ và tạo checksum.

`.pubignore` là bộ lọc riêng cho pub.dev: bỏ tài liệu/công cụ/kiểm thử chỉ dùng trong repository, vẫn giữ README, LICENSE, mã thư viện, bản hướng dẫn AI gộp và ví dụ dùng thật. `dart pub publish --dry-run` chỉ kiểm tra, không đăng gói. Bản này phân phối qua GitHub Release; việc đăng lên pub.dev cần luồng phát hành/tài khoản của chủ sở hữu.
