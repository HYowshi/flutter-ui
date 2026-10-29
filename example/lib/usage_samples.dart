import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youth_ui/youth_ui.dart';

// Copyable partial recipes. App-owned callbacks/models are named explicitly.
const customizationSamples = <String, String>{
  'Sidebar & Navbar': r'''final items = [
  UINavigationItem(id: 'home', label: 'Tổng quan', icon: Icons.home_outlined),
  UINavigationItem(id: 'inbox', label: 'Tin nhắn', icon: Icons.chat_outlined, badge: '12'),
];
UINavigationScaffold(
  title: 'Workspace', items: items,
  selectedIndex: selected, onSelected: (i) => setState(() => selected = i),
  layout: UINavigationLayout.adaptive,
  sidebarVariant: UISidebarVariant.contrast,
  mobileNavbarVariant: UIMobileNavbarVariant.floating,
  child: page, // UIPage/ListView của ứng dụng; shell không tự thêm scroll view
);
// Hoặc ghép UISidebar / UINavbar.mobile vào Scaffold/router hiện tại.
// Route do onSelected của ứng dụng quản lý; dùng id ổn định khi có menu mobile.''',
  'Kết nối API': r'''// Tạo controller trong State, dispose khi đóng trang.
final reload = UIAsyncController();
UIAsyncView<List<Member>>(
  controller: reload,
  requestKey: (accountId, query), // identity đổi => tải lại, bỏ response cũ
  load: () => api.fetchMembers(query), // http, Dio, Firebase, repository...
  isEmpty: (rows) => rows.isEmpty,
  builder: (context, rows) => UITable<Member>(rows: rows, columns: columns),
);
// Sau khi POST thành công:
await reload.reload();
// UIForm(onSubmit: () => api.save(...)) đã có loading/khóa gửi trùng.
// Map lỗi 422 theo tên trường qua UIFormException(fieldErrors: ...).
// Xem example/lib/recipes/api_recipe.dart cho transport HTTP thực tế.''',
  'Trạng thái màn hình': r'''UIStateView(
  kind: UIStateKind.offline,
  title: 'Chưa có kết nối', message: 'Nội dung đã lưu vẫn có thể xem.',
  illustration: const Icon(Icons.cloud_off_outlined, size: 64),
  actionLabel: 'Thử kết nối', onAction: reconnect,
  secondaryActionLabel: 'Xem bản đã lưu', onSecondaryAction: openCache,
);
// Tự truyền trạng thái sau khi nhận kết quả API; không tự dò mạng/quyền.
UIStateView.loading(progress: uploadProgress, onAction: cancelUpload);''',
  'Dialog & Sheet':
      r'''final result = await UIAdaptiveDialog.show<String>(context,
  title: 'Chọn chế độ', presentation: UIPresentation.auto,
  dismissible: true, maxWidth: 600,
  builder: (routeContext) => const Text('Nội dung của ứng dụng'),
  actionsBuilder: (routeContext) => [
    UIButton(label: 'Áp dụng',
      onPressed: () => Navigator.pop(routeContext, 'custom')),
  ],
);
// Dùng routeContext để đóng đúng popup, kể cả khi có Navigator lồng nhau.
// Nội dung cần đổi state: dùng widget Stateful riêng hoặc StatefulBuilder.
// Route chọn kiểu lúc mở; resize không dựng lại route nên giữ dữ liệu.''',
  'Date Picker':
      r'''// UIApp có mặc định delegates en/vi. Tùy chọn locale cho toàn app:
UIApp(primary: Colors.indigo, locale: const Locale('vi'), home: home);

UIDateField(label: 'Ngày hẹn', name: 'appointment', value: appointment,
  onChanged: (value) => setState(() => appointment = value),
  firstDate: DateTime(2026), lastDate: DateTime(2030, 12, 31),
  selectableDayPredicate: (day) => day.weekday <= DateTime.friday,
  validator: (day) => day == null ? 'Hãy chọn ngày' : null,
  format: (day) => '${day.day}/${day.month}/${day.year}',
  clearable: true, helper: 'Chỉ nhận lịch ngày làm việc.',
);
// Hoặc mở riêng, null nghĩa là đã hủy:
final date = await UIDatePicker.show(context);
final range = await UIDatePicker.range(context, initialRange: currentRange);
// Giá trị date-only, không phải timestamp hay múi giờ của lịch hẹn.''',

  'Buttons': r'''// Màu vai trò tự theo theme. style chỉ ghi đè phần bạn truyền.
UIButton(
  label: 'Xuất báo cáo', icon: Icons.download_outlined,
  tone: UITone.secondary, fullWidth: false,
  tooltip: 'Tải báo cáo hiện tại', onPressed: exportReport,
  style: FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// Đặt widget này vào Scaffold.floatingActionButton.
UIFloatingActionButton(
  icon: Icons.add_rounded, tooltip: 'Tạo báo cáo',
  label: 'Tạo báo cáo', onPressed: createReport,
  tone: UITone.accent, size: UIFabSize.regular,
  extended: null, // tự thu gọn trên mobile; true: luôn yêu cầu nhãn
  loading: saving, // app quản lý Future và trạng thái
  // shape: const CircleBorder(), elevation: 3,
  // backgroundColor: Colors.indigo, foregroundColor: Colors.white,
  // heroTag: 'report-create', // chỉ bật khi cần Hero, tag riêng mỗi nút
);''',
  'Form & Inputs': r'''// Đặt controller trong State và dispose khi đóng trang.
final email = TextEditingController();
// @override void dispose() { email.dispose(); super.dispose(); }

UIForm(
  submitLabel: 'Lưu hồ sơ', maxColumns: 1,
  onSubmit: () async { await api.save(email.text.trim()); },
  children: [
    UITextField(name: 'email', label: 'Email liên hệ',
      controller: email, hint: 'ban@example.com',
      variant: UIInputVariant.filled, clearable: true,
      keyboardType: TextInputType.emailAddress,
      validator: UIValidators.combine([
        UIValidators.required(), UIValidators.email(),
      ])),
    UITextField.pin(name: 'pin', label: 'Mã PIN', length: 4,
      validator: UIValidators.required()),
    UITextField.pin(label: 'OTP', obscureText: false,
      autofillHints: const [AutofillHints.oneTimeCode]),
    UITextField(label: 'Giới thiệu', minLines: 3, maxLines: 8,
      maxLength: 500, keyboardType: TextInputType.multiline),
  ],
);''',
  'Alerts & Dialog': r'''UINotice.show(context,
  id: 'save-profile', title: 'Hồ sơ đã cập nhật',
  message: 'Bạn có thể khôi phục phiên bản trước.',
  tone: UITone.success, persistent: true,
  actionLabel: 'Hoàn tác', onAction: restoreProfile,
);
// Dùng cảnh báo trong trang khi lỗi cần được giữ lại.
UIAlert(title: 'Chưa gửi được', message: errorMessage,
  tone: UITone.danger, actionLabel: 'Thử lại',
  onAction: retry, onDismiss: clearError);
// Callback, controller và dữ liệu do ứng dụng sở hữu.''',
  'Table · bảng dữ liệu thích ứng':
      r'''// query/pageSize/selected đặt trong State, không tạo lại mỗi build.
UITable<Person>(
  rows: people, // tạo List mới khi dữ liệu thay đổi
  label: 'Danh sách khách hàng',
  searchQuery: query, // nối với UITextField.search(onChanged: ...)
  searchText: (p) => '${p.name} ${p.email}', // tùy chọn
  pageSize: pageSize, pageSizeOptions: const [5, 10, 20, 50],
  onPageSizeChanged: (n) => setState(() => pageSize = n),
  rowKey: (p) => p.id, selectedKeys: selected, showSelectAll: true,
  onSelectionChanged: (keys) => setState(() => selected = keys),
  loading: loading, error: errorMessage, onRetry: reload,
  empty: const Text('Chưa có khách hàng'),
  columns: [
    UITableColumn(label: 'Tên', minWidth: 220,
      value: (p) => p.name, compare: (a, b) => a.name.compareTo(b.name)),
    UITableColumn(label: 'Trạng thái', minWidth: 160,
      value: (p) => p.active ? 'Hoạt động' : 'Chờ duyệt',
      cellBuilder: (context, p) => UIBadge(
        label: p.active ? 'Hoạt động' : 'Chờ duyệt',
        tone: p.active ? UITone.success : UITone.warning)),
    UITableColumn(label: 'Thao tác', minWidth: 120, value: (_) => '',
      cellBuilder: (context, p) => UIButton(label: 'Chi tiết',
        fullWidth: false, variant: UIButtonVariant.ghost,
        onPressed: () => openPerson(p))),
  ],
); // lọc/sort/phân trang trong bộ nhớ; API server do app quản lý''',
  'Dropdown menu': r'''UISelect<String>(
  label: 'Bộ phận', name: 'department', initialValue: 'design',
  searchable: true, searchHint: 'Nhập tên bộ phận…',
  emptyLabel: 'Không có bộ phận phù hợp', helper: 'Chọn một mục',
  options: const [
    UIOption(value: 'design', label: 'Thiết kế', icon: Icons.palette_outlined),
    UIOption(value: 'dev', label: 'Phát triển'),
    UIOption(value: 'archived', label: 'Lưu trữ', enabled: false),
  ],
  onChanged: selectDepartment,
); // initialValue chỉ khởi tạo; đổi key để chủ động reset trường.''',
  'Images · fallback theo ứng dụng': r'''UIImage.banner(photoUrl,
  height: 240, fit: BoxFit.cover, alignment: Alignment.topCenter,
  borderRadius: BorderRadius.circular(20),
  semanticLabel: 'Ảnh bìa dự án',
  fallbackSource: 'assets/default-cover.png',
  fallback: const Center(child: Text('Chưa có ảnh')),
  variants: const {640: 'https://cdn.example.com/cover-640.jpg',
                   1280: 'https://cdn.example.com/cover-1280.jpg'},
); // khai báo asset trong pubspec, URL web cần CORS hợp lệ''',
  'Motion & Animation':
      r'''UIEntrance(duration: const Duration(milliseconds: 240),
  distance: 12, curve: Curves.easeOutCubic, child: content);
UIReveal(visible: expanded, child: details);
UIAnimatedContent(duration: const Duration(milliseconds: 200),
  child: Text('$step', key: ValueKey(step)));
// Reduced motion do thư viện xử lý. UIReveal giữ state và validation.
// Không dùng reveal thay danh sách lazy hoặc hủy tác vụ mạng.''',
  'Wireframe · nhận diện cấu trúc dữ liệu': r'''UIWireframe.auto(data: response,
  layout: UIWireframeLayout.product, // bỏ để tự nhận diện
  itemCount: 4,
  fieldTypes: const {'portrait': UIWireframeFieldType.avatar},
);
// Dữ liệu mẫu hoặc bố cục đã biết; đây là placeholder, chưa có nghiệp vụ.
// Có thể phân tích một lần rồi tái dùng UIWireframe.fromPlan(plan: plan).''',
  'Cards & Badges':
      r'''UICard(padding: const EdgeInsets.all(20), onTap: openDetail,
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Dự án mới', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 12),
    const UIBadge(label: 'Đang triển khai', tone: UITone.success,
      icon: Icons.check_circle_outline),
  ]));''',
  'Selection controls':
      r'''// Biến trong State; truyền null để vô hiệu hóa callback.
UICheckbox(label: 'Nhận bản tin', value: subscribed,
  onChanged: (v) => setState(() => subscribed = v ?? false));
UISwitch(label: 'Tự đồng bộ', value: sync,
  onChanged: (v) => setState(() => sync = v));
UIToggleButton(label: 'Yêu thích', value: saved,
  onChanged: (v) => setState(() => saved = v));''',
  'Radio · chọn một phương án':
      r'''UIRadioGroup<String>(label: 'Gói dịch vụ', value: plan,
  direction: Axis.horizontal, // vùng hẹp tự xuống hàng
  options: const [
    UIOption(value: 'free', label: 'Miễn phí'),
    UIOption(value: 'pro', label: 'Chuyên nghiệp'),
    UIOption(value: 'team', label: 'Đội nhóm', enabled: false),
  ],
  onChanged: (value) => setState(() => plan = value));''',
  'Cùng một sản phẩm. Bố cục đúng ngữ cảnh.': r'''UIAdaptiveScaffold(
  title: 'Dự án', contentMaxWidth: 800, supportingWidth: 280,
  selectedIndex: index, onDestinationSelected: selectPage,
  destinations: const [
    UIDestination(label: 'Dự án', icon: Icons.folder_outlined),
    UIDestination(label: 'Cài đặt', icon: Icons.settings_outlined),
  ],
  floatingActionButton: UIFloatingActionButton(icon: Icons.add,
    tooltip: 'Tạo dự án', label: 'Tạo dự án', onPressed: createProject),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  child: projectList,
); // scaffold quản lý navigation, khoảng cuộn cuối và vùng tránh FAB''',
  'Khởi tạo một lần': r'''UIApp(primary: const Color(0xFF1565C0),
  secondary: const Color(0xFFDA251D), // tùy chọn màu thương hiệu thứ hai
  home: const YourHomePage());
// Dùng tone/variant trước. Ghi đè ButtonStyle khi cần hình dạng riêng.
// Nếu ghi đè màu, hãy kiểm tra cặp foreground/background ở light và dark.
// Tab “Trang mẫu chạy được” có imports + State + dispose đầy đủ.''',
};

const completeExampleCode = r'''import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

void main() => runApp(const UIApp(primary: Colors.indigo, home: CustomPage()));

class CustomPage extends StatefulWidget {
  const CustomPage({super.key});
  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  final search = TextEditingController();
  final rows = <String>['An', 'Bình', 'Chi', 'Dũng'];
  Set<Object> selected = {};
  int pageSize = 5;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void addItem() {
    setState(() => rows.add('Thành viên ${rows.length + 1}'));
    UINotice.show(context, title: 'Đã thêm', message: rows.last);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Danh sách của tôi'),
      actions: const [UIThemeToggle()]),
    floatingActionButton: UIFloatingActionButton(
      icon: Icons.add_rounded, tooltip: 'Thêm thành viên',
      label: 'Thêm thành viên', onPressed: addItem),
    body: UIPage(children: [
      UITextField.search(controller: search,
        onChanged: (_) => setState(() {})),
      UITable<String>(rows: List.unmodifiable(rows),
        searchQuery: search.text, pageSize: pageSize,
        onPageSizeChanged: (n) => setState(() => pageSize = n),
        rowKey: (name) => name, selectedKeys: selected, showSelectAll: true,
        onSelectionChanged: (keys) => setState(() => selected = keys),
        columns: [UITableColumn(label: 'Tên', value: (name) => name,
          compare: (a, b) => a.compareTo(b))]),
      // Khoảng cuối để FAB không che hàng cuối khi cuộn hết.
      const SizedBox(height: 120),
    ]),
  );
}
''';

class UsageCode extends StatefulWidget {
  const UsageCode({super.key, required this.quick, this.custom});
  final String quick;
  final String? custom;
  @override
  State<UsageCode> createState() => _UsageCodeState();
}

class _UsageCodeState extends State<UsageCode> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final samples = [
      widget.quick,
      widget.custom ?? customizationSamples['Khởi tạo một lần']!,
      completeExampleCode,
    ];
    final code = samples[selected];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < 3; i++)
              ChoiceChip(
                label: Text(
                  ['Dùng nhanh', 'Tùy chỉnh', 'Trang mẫu chạy được'][i],
                ),
                selected: selected == i,
                onSelected: (_) => setState(() => selected = i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          selected == 2
              ? 'Dán toàn bộ vào main.dart của app đã thêm youth_ui. Đổi tên, dữ liệu và callback theo dự án.'
              : 'Đoạn ghép vào build/State: thay model, biến và callback bằng dữ liệu của ứng dụng. Imports: material.dart và youth_ui.dart.',
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: code));
                if (context.mounted) {
                  UINotice.show(context, message: 'Đã sao chép mã Dart.');
                }
              } catch (_) {
                if (context.mounted) {
                  UINotice.show(
                    context,
                    message: 'Chưa thể sao chép. Bạn có thể chọn mã bên dưới.',
                    tone: UITone.warning,
                  );
                }
              }
            },
            icon: const Icon(Icons.copy, size: 15),
            label: const Text('Sao chép'),
          ),
        ),
        SelectableText(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.8,
          ),
        ),
      ],
    );
  }
}
