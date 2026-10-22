# Thị giác, tâm lý và thuật toán màu Youth UI 0.2

Nghiên cứu và triển khai: 22/10/2026.

## Kết luận

Một hoặc hai màu là đủ để khởi tạo một hệ màu sử dụng được, nhưng không đủ để biết sở thích, văn hóa, thị lực, môi trường ánh sáng hoặc mục đích của mọi ứng dụng. Vì vậy Youth UI sinh các **vai trò màu có ràng buộc**, không tuyên bố tự tìm ra phối màu đẹp nhất hay tối ưu tâm lý cho mọi người.

Bản 0.2 chuyển từ “sinh rồi ghi đè vài mã màu” sang:

**Seed thương hiệu → họ màu HCT → vai trò Material → cặp chữ/nền → trạng thái theo bề mặt → kiểm tra tương phản.**

## 1. Thị giác: điều gì liên quan trực tiếp tới UI?

### Phân biệt sắc màu và phân biệt sáng tối không phải cùng một việc

Màu được cảm nhận từ so sánh tín hiệu của nhiều nhóm tế bào nón. Không nên xem mỗi nón là một bộ đọc màu đỏ/xanh đơn giản. Việc hai vật khác hue không tự chứng minh rằng chữ trên nền đọc tốt. Chọn hue và kiểm tra luminance cần là hai bước riêng. Đây là suy luận thiết kế từ nền tảng thị giác, không phải mô phỏng đầy đủ võng mạc trong thuật toán.

Nguồn: [Purves et al., Cones and Color Vision](https://www.ncbi.nlm.nih.gov/books/NBK11059/), [Kalloniatis & Luu, The Perception of Color](https://www.ncbi.nlm.nih.gov/books/NBK11538/).

**Áp dụng:** dùng HCT để điều chỉnh tone và chroma, sau đó đo relative-luminance contrast trên màu sRGB thực. Không dùng khoảng cách hue để thay thế tỷ lệ tương phản.

### Sự chú ý phụ thuộc mục tiêu và các yếu tố cạnh tranh

Nghiên cứu visual search cho thấy color và luminance cùng tham gia các cơ chế hướng chú ý. Một màu nổi không tồn tại độc lập với nền và các vật xung quanh. Không suy ra rằng màu bão hòa hơn luôn tốt hơn cho mọi nút.

Nguồn: [Neural differences between chromatic- and luminance-driven attentional salience](https://pubmed.ncbi.nlm.nih.gov/32196068/), [Mapping the color space of saccadic selectivity](https://pubmed.ncbi.nlm.nih.gov/21635320/).

**Áp dụng:** nền có chroma thấp; màu mạnh dành cho vai trò nhấn. Có profile reading/balanced/expressive. Các giới hạn chroma là policy kỹ thuật của thư viện, không phải ngưỡng đã được thí nghiệm chứng minh là tối ưu.

### Phân đoạn nền và nội dung

Một thí nghiệm change blindness ghi nhận rằng thay đổi trong vùng nền có thể bị bỏ qua khi chú ý không hướng tới đó. Đây không phải lý do để làm mọi thông báo chớp hoặc đổi màu liên tục.

Nguồn: [Foreground-background segmentation and attention](https://pubmed.ncbi.nlm.nih.gov/15597185/).

**Áp dụng:** thông báo đặt gần hành động; dùng label và icon; phân lớp surface/canvas. Các quyết định vị trí thông báo thuộc thiết kế màn hình, không thể được giải quyết chỉ bằng hàm sinh palette.

## 2. Tâm lý màu: tránh những khẳng định quá đơn giản

Các thí nghiệm về màu đỏ cho thấy sở thích có thể thay đổi theo ngữ cảnh trình bày. Không có cơ sở ở đây để tuyên bố “xanh luôn đáng tin”, “đỏ luôn xấu” hay “vàng luôn vui” trong mọi ứng dụng.

Nguồn: [Maier et al., Context specificity of implicit preferences](https://pubmed.ncbi.nlm.nih.gov/19803595/). Tổng quan để nhận diện giới hạn nghiên cứu: [Elliot, Color and psychological functioning](https://pmc.ncbi.nlm.nih.gov/articles/PMC4383146/).

**Áp dụng:** màu thương hiệu và trạng thái là hai lớp riêng. Success, warning và danger giữ ý nghĩa quy ước và luôn đi cùng dấu hiệu khác màu. Hai seed rất giống nhau không bị ép đổi thành màu lạ; phân biệt vai trò còn dựa vào độ nhấn, nhãn và hình dạng.

Thuật toán không dự đoán cảm xúc người dùng. Việc khẳng định một bảng màu tăng niềm tin hay tăng chuyển đổi cần nghiên cứu với người dùng thật trong bối cảnh cụ thể.

## 3. Light/dark và môi trường nhìn

Nghiên cứu về polarity và kích thước đồng tử ghi nhận lợi thế phân biệt một số kích thích nhỏ ở điều kiện nền sáng, đồng thời có đánh đổi với phát hiện kích thích mờ. Không thể suy ra một chế độ hiển thị luôn tốt nhất cho mọi người.

Nguồn: [The effect of pupil size and peripheral brightness on detection and discrimination performance](https://pubmed.ncbi.nlm.nih.gov/31875153/).

Apple khuyến nghị kiểm tra các mode, tương phản và điều kiện ánh sáng/thiết bị khác nhau. Một đoạn mã không thể suy ra ánh sáng môi trường chỉ từ chiều rộng cửa sổ. [Apple HIG — Color](https://developer.apple.com/design/human-interface-guidelines/color)

**Áp dụng:** sinh light và dark riêng, dùng ThemeMode.system nếu phù hợp; có tùy chọn tăng tương phản. Seed nguyên bản giữ trong brandPrimary; action không bị ép giữ cùng HEX ở cả hai mode.

## 4. Mobile, desktop, application và website

| Bối cảnh | Nhu cầu chính | Quyết định của bộ UI |
| --- | --- | --- |
| Mobile touch | Vùng chạm rõ; không phụ thuộc hover | Nút tối thiểu cao 48 logical px; native controls giữ hành vi Material |
| Desktop mouse/keyboard | Hover, focus, chọn và nhấn phải nhận ra | Resolver riêng cho hover/pressed/focus/selected; focus có viền 2px |
| Website nhiều ảnh | Ảnh đã tạo tải màu | Profile reading có nền ít chroma; không tự nhuộm mọi card |
| Ứng dụng nhiều dữ liệu | Cần phân vùng và ý nghĩa ổn định | Neutral layers, status và action tách vai trò |
| Marketing/landing | Có thể cần nhận diện mạnh hơn | Profile expressive nâng giới hạn màu nhấn, không bỏ tương phản |

Đây là định hướng sử dụng; không tự nhận diện loại trang rồi đổi bảng màu. Android khuyến nghị vùng touch target 48dp cho các control và cho phép khác biệt với đầu vào chính xác. [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility/apps)

Fluent dùng neutral cho cấu trúc và surface, tách brand khỏi semantic colors, hạn chế lạm dụng màu thương hiệu trên vùng lớn. [Fluent 2 — Color](https://fluent2.microsoft.design/color)

Không áp dụng một tỷ lệ phần trăm màu cố định cho mọi màn hình. Mật độ, thứ bậc, nội dung, khoảng cách và hình ảnh vẫn cần thiết kế.

## 5. Cơ sở thuật toán

Material Color Utilities cung cấp HCT, tonal palettes và DynamicScheme. Bản 0.2 dùng thư viện chính thức này; không mô tả thuật toán thị giác của Google như do Youth UI tự phát minh.

Nguồn: [Material Color Utilities — Creating color schemes](https://github.com/material-foundation/material-color-utilities/blob/main/dev_guide/creating_color_scheme.md), [Flutter ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html).

### Dữ liệu đầu vào

- primary: bắt buộc, opaque.
- secondary: tùy chọn; thiếu thì tự sinh.
- accent: seed thứ ba tùy chọn; thiếu thì tự sinh.
- profile: balanced mặc định, reading hoặc expressive.
- contrastLevel: 0..1. Từ 0.5 trở lên, các cặp chữ do Youth UI audit có mục tiêu 7:1.
- brightness: light/dark cho init(); colors() sinh cả hai.

Seed alpha bị từ chối thay vì âm thầm phối lên một nền giả định. Giá trị contrast không hữu hạn hoặc ngoài khoảng bị từ chối.

### Sinh các họ màu

1. Chuyển seed sang HCT.
2. Primary giữ hue; chroma được giới hạn theo profile.
3. Secondary có seed riêng thì sinh cả họ từ seed đó, gồm solid/container/on/fixed. Nếu không có, sinh họ dịu hơn từ primary.
4. Accent không nhập thì được suy ra từ hue chính và hue phụ nếu có. Góc hue của policy này là heuristic thiết kế, không phải định luật tâm lý.
5. Neutral và neutral-variant có chroma thấp để không tranh chú ý với nội dung.
6. DynamicScheme ánh xạ tone theo brightness và contrast.
7. Success/warning có hue quy ước ổn định, không bị đổi nghĩa theo seed.

Input gần xám vẫn gần xám; không bịa một màu thương hiệu rực chỉ để có thêm màu. Input đỏ/vàng nguyên bản không được dùng làm mặc định cho mọi sản phẩm nữa.

### Sửa các cặp màu và trạng thái

- Chữ và nền được đánh giá theo cặp.
- Tìm tone HCT gần tone ban đầu trong các mức nguyên 0..100 đáp ứng mọi nền được yêu cầu.
- Điều chỉnh foreground trên các surface được hỗ trợ; error nếu không có lời giải chung, thay vì báo pass sai.
- Soft fills là màu opaque theo role; không trộn alpha ở một nơi nhưng kiểm tra trên nền khác.
- Hover dùng 8%, pressed 12%, focus 10% trước khi kiểm tra. Đây là policy của Youth UI.
- Nếu lớp trạng thái làm chữ không đạt mục tiêu, sửa lại tone nền trước để giữ cực sáng/tối của chữ ổn định, tránh chữ đảo đen/trắng khi hover.
- UICard tự cung cấp UISurfaceScope. Custom surface có thể cấp scope tương tự.
- Input border và focus được kiểm tra với bề mặt chuẩn; viền trang trí card không bị nâng thành màu đậm vô cớ.

Hai hàm uiReadable() và uiReadableOn() nhận màu nền thực đã phối alpha; chúng không phân tích ảnh nền.

## 6. Chuẩn đo và cách hiểu kết quả

Chữ thường cần 4.5:1; chữ lớn có ngưỡng khác theo định nghĩa WCAG. Một số control/icon/state cần 3:1 với màu kề liên quan. Không được dùng màu làm dấu hiệu duy nhất.

Nguồn: [W3C Contrast Minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html), [Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html), [Focus Visible](https://www.w3.org/WAI/WCAG22/Understanding/focus-visible.html).

`YouthColors.audit()` trả về nhãn cặp, màu thực, ngưỡng và ratio; không chỉ trả một cờ “đẹp”. 40 cặp audit gồm solid/soft của sáu tone và body/muted/focus/border trên bảy surface. Chúng không đại diện cho toàn bộ pixel, mọi component native hoặc mọi custom screen.

## 7. Kiểm tra triển khai

- 20 seed: rất sáng, rất tối, gần xám, bão hòa và chín seed giả ngẫu nhiên với seed kiểm tra cố định.
- 2 mode × 3 profile.
- Một hoặc hai màu được xen kẽ trong ma trận.
- Sáu tone × bốn kiểu nút × bảy surface × bảy tổ hợp state.
- Tổng cộng 166.080 phép kiểm tra cặp role/state trong ma trận chuẩn.
- Có kiểm tra thêm high contrast 7:1, surface override, fixed roles, alpha input sai, tính xác định, theme độc lập và giá trị đầu vào sai.
- Widget tests kiểm tra tương tác nút/password/form và đổi theme; showcase tests kiểm tra mobile, desktop, màu thứ hai và high contrast.

Đây là kiểm tra kỹ thuật có thể tái lập, không phải user study chứng minh thẩm mỹ hay tâm lý.

## 8. API đã triển khai

```dart
// Một seed, tự sinh phần còn lại.
final ui = YouthUI.colors(primary: const Color(0xFF1565C0));

// Hai seed, mỗi seed có một họ vai trò đầy đủ.
final ui = YouthUI.colors(
  primary: const Color(0xFF1565C0),
  secondary: const Color(0xFFDA251D),
);

MaterialApp(
  theme: ui.light,
  darkTheme: ui.dark,
  themeMode: ThemeMode.system,
  home: const HomePage(),
);

// Widget không phải set lại màu.
UIButton(label: 'Tiếp tục', onPressed: submit);
```

Tạo theme ở cấp ứng dụng, không gọi colors() cho từng widget. init() cũ vẫn dùng được, nhưng primary giờ là seed để sinh role, không phải cam kết primary role bằng đúng HEX nhập vào. Muốn màu nhận diện gốc: YouthColors.of(context).brandPrimary.

## 9. Giới hạn cần công khai

- Chưa có thử nghiệm người dùng riêng cho Youth UI; chưa đo thẩm mỹ hoặc tốc độ hoàn thành tác vụ.
- Không đo ánh sáng môi trường, màn hình P3/HDR, thị lực hoặc khả năng phân biệt màu của từng người.
- Tương phản được kiểm tra ở các màu trạng thái đã resolve, không phải mọi khung hình nội suy theme/animation. Demo tắt chuyển theme khi bật high contrast.
- Không bảo đảm bảng màu categorical cho biểu đồ thân thiện với mọi dạng khiếm khuyết thị giác màu; chưa có generator chuyên cho biểu đồ.
- Custom background ảnh/gradient cần kiểm tra riêng. Custom text styles/màu native ghi đè có thể phá cặp màu.
- Surface override phải cùng dải sáng/tối hợp lý; nếu trộn nền trắng và đen trong cùng context có thể không có màu chữ chung đạt ngưỡng.
- Khả năng đọc còn phụ thuộc font, kích thước, độ dày nét, bố cục, độ chói và ngữ cảnh. Palette generator không thay thế thiết kế sản phẩm.
