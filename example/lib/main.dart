import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youth_ui/youth_ui.dart';

import 'usage_samples.dart';

void main() => runApp(const ShowcaseApp());

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});
  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  Color primary = const Color(0xFF1565C0);
  Color? secondary;
  UIProfile profile = UIProfile.balanced;
  bool highContrast = false;
  bool reduce = false;
  final mode = UIThemeController(mode: ThemeMode.light);
  @override
  void dispose() {
    mode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UIApp(
    primary: primary,
    secondary: secondary,
    profile: profile,
    contrastLevel: highContrast ? 1 : 0,
    controller: mode,
    reduceMotion: reduce,
    title: 'Flutter UI · Component Studio',
    home: Studio(
      primary: primary,
      secondary: secondary,
      profile: profile,
      highContrast: highContrast,
      onSecondary: (c) => setState(() => secondary = c),
      onProfile: (v) => setState(() => profile = v),
      onHighContrast: (v) => setState(() => highContrast = v),
      reduce: reduce,
      onColor: (c) => setState(() => primary = c),
      onDark: () => mode.toggle(),
      onReduce: (v) => setState(() => reduce = v),
    ),
  );
}

class Studio extends StatefulWidget {
  const Studio({
    super.key,
    required this.primary,
    required this.reduce,
    required this.onColor,
    required this.onDark,
    required this.onReduce,
    required this.secondary,
    required this.profile,
    required this.highContrast,
    required this.onSecondary,
    required this.onProfile,
    required this.onHighContrast,
  });
  final Color? secondary;
  final UIProfile profile;
  final bool highContrast;
  final ValueChanged<Color?> onSecondary;
  final ValueChanged<UIProfile> onProfile;
  final ValueChanged<bool> onHighContrast;
  final Color primary;
  final bool reduce;
  final ValueChanged<Color> onColor;
  final VoidCallback onDark;
  final ValueChanged<bool> onReduce;
  @override
  State<Studio> createState() => _StudioState();
}

class _StudioState extends State<Studio> {
  int selected = 0;
  final scroll = ScrollController();
  static const labels = [
    'Tổng quan',
    'Bảng màu',
    'Buttons',
    'Form & Inputs',
    'Cards & Badges',
    'Thông báo',
    'Animation',
    'Bắt đầu sử dụng',
    'Selection controls',
    'Adaptive UI',
    'Dropdown menu',
    'Images',
    'Wireframe',
    'Table',
    'Radio',
    'Trạng thái màn hình',
    'Dialog & Sheet',
    'Date Picker',
  ];
  static const icons = [
    Icons.grid_view_rounded,
    Icons.palette_outlined,
    Icons.touch_app_outlined,
    Icons.edit_note_rounded,
    Icons.dashboard_outlined,
    Icons.notifications_none_rounded,
    Icons.auto_awesome_outlined,
    Icons.code_rounded,
    Icons.toggle_on_outlined,
    Icons.devices_rounded,
    Icons.unfold_more_rounded,
    Icons.image_outlined,
    Icons.view_quilt_outlined,
    Icons.table_chart_outlined,
    Icons.radio_button_checked,
    Icons.info_outline_rounded,
    Icons.web_asset_outlined,
    Icons.date_range_outlined,
  ];
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void select(int index) {
    setState(() => selected = index);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return Scaffold(
      appBar: wide
          ? null
          : AppBar(
              title: const Text(
                'Flutter UI',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: [
                IconButton(
                  onPressed: widget.onDark,
                  tooltip: 'Đổi sáng / tối',
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                ),
              ],
            ),
      drawer: wide ? null : Drawer(child: sidebar(context, closeDrawer: true)),
      body: SafeArea(
        child: Row(
          children: [
            if (wide) SizedBox(width: 244, child: sidebar(context)),
            Expanded(
              child: Column(
                children: [
                  if (wide)
                    Container(
                      height: 78,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: s.outlineVariant.withValues(alpha: .5),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'THƯ VIỆN THIẾT KẾ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: s.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          const UIBadge(
                            label: 'Flutter / Dart',
                            icon: Icons.flutter_dash,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: widget.onDark,
                            tooltip: 'Đổi sáng / tối',
                            icon: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const ValueKey('studio-content-scroll'),
                      controller: scroll,
                      padding: EdgeInsets.all(wide ? 40 : 20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selected == 0)
                                hero(context)
                              else ...[
                                Text(
                                  'FLUTTER UI / ${labels[selected].toUpperCase()}',
                                  style: TextStyle(
                                    color: s.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  labels[selected],
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  descriptions[selected],
                                  style: TextStyle(
                                    color: s.onSurfaceVariant,
                                    height: 1.7,
                                  ),
                                ),
                                const SizedBox(height: 28),
                              ],
                              if (selected == 0 || selected == 1)
                                themeSection(context),
                              if (selected == 0) ...[
                                const SizedBox(height: 36),
                                const Text(
                                  'Thiết kế một lần. Dùng ở mọi nơi.',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tương tác trực tiếp với từng component. Mở “Mã sử dụng” để mang vào app.',
                                  style: TextStyle(color: s.onSurfaceVariant),
                                ),
                                const SizedBox(height: 24),
                              ],
                              if (selected == 0 || selected == 2)
                                const ButtonDemo(),
                              if (selected == 0 || selected == 8)
                                const SelectionDemo(),
                              if (selected == 9) const AdaptiveDemo(),
                              if (selected == 10) const DropdownDemo(),
                              if (selected == 11) const ImageDemo(),
                              if (selected == 12) const WireframeDemo(),
                              if (selected == 13) const TableDemo(),
                              if (selected == 14) const RadioDemo(),
                              if (selected == 15) const StateViewDemo(),
                              if (selected == 16) const AdaptiveDialogDemo(),
                              if (selected == 17) const DatePickerDemo(),
                              if (selected == 0 || selected == 3)
                                const InputDemo(),
                              if (selected == 0 || selected == 4)
                                const CardDemo(),
                              if (selected == 0 || selected == 5)
                                const FeedbackDemo(),
                              if (selected == 0 || selected == 6)
                                MotionDemo(
                                  reduce: widget.reduce,
                                  onReduce: widget.onReduce,
                                ),
                              if (selected == 7) const UsageDemo(),
                              const SizedBox(height: 32),
                              Divider(
                                color: s.outlineVariant.withValues(alpha: .5),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 20,
                                runSpacing: 10,
                                children: [
                                  Text(
                                    'FLUTTER UI  /  YOUTH UI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: s.onSurfaceVariant,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  Text(
                                    'Built with Flutter. Made to be reused.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: s.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const descriptions = [
    '',
    'Đổi một màu gốc. Toàn bộ thư viện phản hồi cùng nhau.',
    'Hover, focus, nhấn, loading và disabled. Màu sắc tự lấy từ theme.',
    'Nhập liệu, xác thực, hiện mật khẩu và các lựa chọn có trạng thái thật.',
    'Bề mặt, nội dung và các nhãn trạng thái nhất quán.',
    'Phản hồi rõ ràng cho mỗi hành động của người dùng.',
    'Chuyển động có mục đích, có thể chạy lại và giảm chuyển động.',
    'Khởi tạo theme một lần. Sau đó chỉ gọi widget.',
    'Checkbox, switch, toggle và nhóm chọn. Hiệu ứng gọn trong từng control.',
    'Cùng một mã Dart tự thay đổi theo vùng chứa, chuột và cỡ chữ.',
    'Một ô chọn, hai cách mở phù hợp với PC và mobile. Màu và trạng thái thống nhất.',
    'Gọi ảnh một dòng: giữ khung, decode theo vùng hiển thị, có loading và fallback.',
    'Nhận diện cấu trúc dữ liệu, chọn bố cục và tự thích ứng theo vùng chứa.',
    'Bảng có sắp xếp, phân trang và chọn dòng; tự thành thẻ khi vùng hiển thị hẹp.',
    'Chọn một phương án, dùng bàn phím và kế thừa màu từ theme.',
    'Loading, dữ liệu rỗng, lỗi, ngoại tuyến và quyền truy cập có cùng ngôn ngữ thiết kế.',
    'Popup tự chọn dialog hoặc bottom sheet, giữ nội dung và thao tác rõ ràng.',
    'Chọn ngày, khoảng ngày, giới hạn hợp lệ và dùng cùng form.',
  ];
  Widget sidebar(BuildContext context, {bool closeDrawer = false}) {
    final s = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: s.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: s.outlineVariant.withValues(alpha: .45)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: s.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.layers_rounded, color: s.onPrimary, size: 23),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Flutter UI',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Bộ giao diện dùng chung',
            style: TextStyle(color: s.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 40),
          Text(
            'KHÁM PHÁ',
            style: TextStyle(
              color: s.onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 1.7,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: List.generate(
                labels.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      dense: true,
                      selected: selected == i,
                      selectedTileColor: s.primaryContainer.withValues(
                        alpha: .45,
                      ),
                      selectedColor: s.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      leading: Icon(icons[i], size: 20),
                      title: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected == i
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        select(i);
                        if (closeDrawer) Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'v0.16.0 · Ready-to-use Flutter UI',
            style: TextStyle(fontSize: 10, color: s.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget hero(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: s.primaryContainer.withValues(alpha: .25),
        borderRadius: BorderRadius.circular(26),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UIBadge(
                label: 'FLUTTER COMPONENT STUDIO',
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(height: 23),
              Text(
                'UI đồng bộ.\nBắt đầu từ một màu.',
                style: TextStyle(
                  fontSize: box.maxWidth > 700 ? 43 : 32,
                  fontWeight: FontWeight.w900,
                  height: 1.17,
                  letterSpacing: -1.7,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Khởi tạo theme từ màu thương hiệu, rồi ghép các component\ncho ứng dụng Flutter trên mobile, desktop và web.',
                style: TextStyle(
                  color: s.onSurfaceVariant,
                  height: 1.8,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  UIButton(
                    label: 'Bắt đầu sử dụng',
                    fullWidth: false,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => select(7),
                  ),
                  UIButton(
                    label: 'Xem component',
                    fullWidth: false,
                    variant: UIButtonVariant.outline,
                    onPressed: () => select(2),
                  ),
                ],
              ),
            ],
          );
          if (box.maxWidth < 760) return text;
          return Row(
            children: [
              Expanded(flex: 6, child: text),
              const SizedBox(width: 36),
              Expanded(
                flex: 4,
                child: UIEntrance(
                  child: UICard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: s.primaryContainer,
                              child: Icon(
                                Icons.palette_outlined,
                                color: s.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Một theme nhất quán',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Từ màu thương hiệu đến từng component.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            UIBadge(label: 'Light / Dark'),
                            UIBadge(
                              label: 'Mobile / Desktop',
                              tone: UITone.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Chữ, nền, viền và trạng thái tương tác cùng kế thừa bộ màu.',
                          style: TextStyle(
                            color: s.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ExcludeSemantics(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final color in [
                                s.primary,
                                s.secondary,
                                s.tertiary,
                                s.primaryContainer,
                              ])
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: s.outlineVariant),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget themeSection(BuildContext context) => ThemeEditor(
    primary: widget.primary,
    secondary: widget.secondary,
    onColor: widget.onColor,
    onSecondary: widget.onSecondary,
    profile: widget.profile,
    onProfile: widget.onProfile,
    highContrast: widget.highContrast,
    onHighContrast: widget.onHighContrast,
  );
}

class DemoBlock extends StatelessWidget {
  const DemoBlock({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.code,
    required this.child,
    required this.effects,
  });
  final String number, title, description, code, effects;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: UICard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        number,
                        style: TextStyle(
                          color: s.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: s.onSurfaceVariant,
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.motion_photos_on_outlined,
                        size: 15,
                        color: s.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          effects,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.6,
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: s.outlineVariant.withValues(alpha: .5)),
            ExpansionTile(
              title: const Text(
                'Mã sử dụng',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              leading: const Icon(Icons.code, size: 18),
              shape: const Border(),
              collapsedShape: const Border(),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UsageCode(
                        quick: code,
                        custom: customizationSamples[title],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void toast(BuildContext context, String text) {
  UINotice.show(context, message: text);
}

class ThemeEditor extends StatefulWidget {
  const ThemeEditor({
    super.key,
    required this.primary,
    required this.secondary,
    required this.onColor,
    required this.onSecondary,
    required this.profile,
    required this.onProfile,
    required this.highContrast,
    required this.onHighContrast,
  });
  final Color primary;
  final Color? secondary;
  final ValueChanged<Color> onColor;
  final ValueChanged<Color?> onSecondary;
  final UIProfile profile;
  final ValueChanged<UIProfile> onProfile;
  final bool highContrast;
  final ValueChanged<bool> onHighContrast;
  @override
  State<ThemeEditor> createState() => _ThemeEditorState();
}

class _ThemeEditorState extends State<ThemeEditor> {
  final controller = TextEditingController();
  final second = TextEditingController(text: '#DA251D');
  String? error, secondError;
  static const seeds = [
    Color(0xFF1565C0),
    Color(0xFF7545B8),
    Color(0xFF087B59),
    Color(0xFFBE3155),
    Color(0xFFFFDF42),
  ];
  String hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  @override
  void initState() {
    super.initState();
    controller.text = hex(widget.primary);
    if (widget.secondary != null) second.text = hex(widget.secondary!);
  }

  @override
  void didUpdateWidget(covariant ThemeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primary != widget.primary) {
      controller.text = hex(widget.primary);
      error = null;
    }
    if (widget.secondary != null && oldWidget.secondary != widget.secondary) {
      second.text = hex(widget.secondary!);
      secondError = null;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    second.dispose();
    super.dispose();
  }

  Color? parse(String v) => RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(v.trim())
      ? Color(int.parse('FF${v.trim().substring(1)}', radix: 16))
      : null;
  void apply() {
    final first = parse(controller.text),
        other = widget.secondary == null ? null : parse(second.text);
    setState(() {
      error = first == null ? 'Dùng #RRGGBB' : null;
      secondError = widget.secondary != null && other == null
          ? 'Dùng #RRGGBB'
          : null;
    });
    if (first == null || secondError != null) return;
    widget.onColor(first);
    if (other != null) widget.onSecondary(other);
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme, tokens = YouthColors.of(context);
    final checks = tokens.audit(),
        passed = tokens.audit().where((c) => c.passed).length;
    return UICard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Một hoặc hai màu. Một hệ giao diện.',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Giữ seed thương hiệu, sinh đầy đủ vai trò chữ / nền / viền theo HCT.',
            style: TextStyle(
              color: s.onSurfaceVariant,
              height: 1.6,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final c in seeds)
                Semantics(
                  label: 'Seed ${hex(c)}',
                  selected: widget.primary == c,
                  button: true,
                  child: Tooltip(
                    message: hex(c),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () => widget.onColor(c),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: widget.primary == c
                                ? s.onSurface
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: widget.primary == c
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: uiForeground(c),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: 156,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Màu chính · HEX',
                    errorText: error,
                    isDense: true,
                  ),
                  onSubmitted: (_) => apply(),
                ),
              ),
              UIButton(
                label: 'Áp dụng',
                variant: UIButtonVariant.soft,
                onPressed: apply,
              ),
            ],
          ),
          const SizedBox(height: 14),
          UISwitch(
            label: 'Dùng thêm màu thứ hai',
            value: widget.secondary != null,
            onChanged: (v) => widget.onSecondary(
              v ? parse(second.text) ?? const Color(0xFFDA251D) : null,
            ),
          ),
          if (widget.secondary != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: 240,
              child: TextField(
                controller: second,
                decoration: InputDecoration(
                  labelText: 'Màu thứ hai · HEX',
                  errorText: secondError,
                ),
                onSubmitted: (_) => apply(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Màu thứ hai sinh cả nhóm secondary; không thay một mã màu riêng lẻ.',
              style: TextStyle(fontSize: 12, color: s.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 18),
          UISelect<UIProfile>(
            label: 'Phân bổ sắc độ',
            initialValue: widget.profile,
            items: const [
              DropdownMenuItem(
                value: UIProfile.balanced,
                child: Text('Cân bằng · mặc định'),
              ),
              DropdownMenuItem(
                value: UIProfile.reading,
                child: Text('Ưu tiên đọc · nền ít sắc hơn'),
              ),
              DropdownMenuItem(
                value: UIProfile.expressive,
                child: Text('Biểu cảm · màu nhấn rõ hơn'),
              ),
            ],
            onChanged: (v) {
              if (v != null) widget.onProfile(v);
            },
          ),
          UISwitch(
            label: 'Tăng tương phản chữ lên 7:1',
            value: widget.highContrast,
            onChanged: widget.onHighContrast,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              token(
                'Brand gốc',
                tokens.brandPrimary,
                uiForeground(tokens.brandPrimary),
              ),
              if (tokens.brandSecondary != null)
                token(
                  'Brand thứ hai',
                  tokens.brandSecondary!,
                  uiForeground(tokens.brandSecondary!),
                ),
              token('Action', s.primary, s.onPrimary),
              token('Secondary', s.secondary, s.onSecondary),
              token('Accent tự sinh', s.tertiary, s.onTertiary),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Phân lớp bề mặt',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              token('Canvas', tokens.canvas, s.onSurface),
              token('Card', s.surfaceContainerLowest, s.onSurface),
              token('Container', s.surfaceContainer, s.onSurface),
              token('Nổi', s.surfaceContainerHigh, s.onSurface),
            ],
          ),
          const SizedBox(height: 20),
          UIAlert(
            tone: passed == checks.length ? UITone.success : UITone.danger,
            title: '$passed/${checks.length} cặp vai trò đạt ngưỡng kiểm tra',
            message:
                'Chữ ≥ ${tokens.textContrast.toStringAsFixed(1)}:1; focus và viền control ≥ 3:1 trên các bề mặt chuẩn. Không thay thế kiểm tra toàn màn hình.',
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            title: const Text(
              'Xem các cặp được kiểm tra',
              style: TextStyle(fontSize: 12),
            ),
            children: [
              for (final check in checks)
                ListTile(
                  dense: true,
                  leading: Icon(
                    check.passed
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    size: 18,
                  ),
                  title: Text(
                    check.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    '${check.ratio.toStringAsFixed(2)}:1',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget token(String name, Color c, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(9)),
    child: Text(
      name,
      style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

class ButtonDemo extends StatefulWidget {
  const ButtonDemo({super.key});
  @override
  State<ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  bool loading = false;
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '01',
    title: 'Buttons',
    description: 'Button và Floating Action Button dùng chung vai trò màu. FAB tự thu gọn nhãn trên vùng hẹp.',
    effects: 'Màu hover / pressed được kiểm tra sau phối lớp · focus có viền riêng · loading khóa thao tác',
    code: "UIButton(label: 'Tiếp tục', onPressed: submit);\nUIButton(label: 'Hủy', variant: UIButtonVariant.outline, onPressed: cancel);\nUIButton(label: 'Đang lưu', loading: true);\n\n// Đặt vào Scaffold.floatingActionButton:\nUIFloatingActionButton(icon: Icons.add, tooltip: 'Tạo mới',\n  label: 'Tạo mới', onPressed: createItem);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final v in UIButtonVariant.values)
              UIButton(
                label: ['Chính', 'Nền nhạt', 'Viền', 'Tối giản'][v.index],
                variant: v,
                onPressed: () => toast(context, 'Bạn vừa nhấn nút ${v.name}.'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            UIButton(
              label: 'Lưu thay đổi',
              icon: Icons.check_rounded,
              loading: loading,
              onPressed: () async {
                setState(() => loading = true);
                await Future<void>.delayed(const Duration(milliseconds: 1300));
                if (!mounted) return;
                setState(() => loading = false);
                if (context.mounted) {
                  toast(
                    context,
                    'Đã chạy xong demo loading. Không gửi dữ liệu.',
                  );
                }
              },
            ),
            UIButton(
              label: 'Quan trọng',
              tone: UITone.secondary,
              onPressed: () => toast(context, 'Nút secondary.'),
            ),
            UIButton(
              label: 'Nổi bật',
              tone: UITone.accent,
              onPressed: () => toast(context, 'Nút accent.'),
            ),
            const UIButton(label: 'Không khả dụng'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Floating Action Button',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Tự thu nhãn ở vùng hẹp; tooltip luôn có tên hành động. Thử đổi kích thước cửa sổ.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final size in UIFabSize.values)
              UIFloatingActionButton(
                icon: Icons.add_rounded,
                tooltip: 'Tạo mục · ${size.name}',
                size: size,
                onPressed: () => toast(context, 'Tạo mục mới · ${size.name}'),
              ),
            UIFloatingActionButton(
              icon: Icons.edit_outlined,
              tooltip: 'Soạn nội dung',
              label: 'Soạn nội dung',
              tone: UITone.secondary,
              onPressed: () => toast(context, 'Đã mở hành động soạn nội dung.'),
            ),
            UIFloatingActionButton(
              icon: Icons.upload_rounded,
              tooltip: 'Tải lên',
              loading: loading,
              onPressed: () async {
                setState(() => loading = true);
                await Future<void>.delayed(const Duration(milliseconds: 1300));
                if (!mounted) return;
                setState(() => loading = false);
              },
            ),
            const UIFloatingActionButton(
              icon: Icons.lock_outline,
              tooltip: 'Chưa có quyền',
            ),
          ],
        ),
      ],
    ),
  );
}

class SelectionDemo extends StatefulWidget {
  const SelectionDemo({super.key});
  @override
  State<SelectionDemo> createState() => _SelectionDemoState();
}

class _SelectionDemoState extends State<SelectionDemo> {
  bool checked = true, notifications = false, saved = false;
  String view = 'list';
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '07',
    title: 'Selection controls',
    description: 'Các lựa chọn dùng lại cho mọi ứng dụng Flutter. Nhãn và khoảng trống không bắt tương tác; hover chỉ hiện quanh control.',
    effects: 'Hover cục bộ · focus bàn phím · dấu chọn rõ ràng · disabled · chuyển trạng thái',
    code: "UICheckbox(value: checked, onChanged: setChecked);\nUISwitch(value: enabled, onChanged: setEnabled);\nUIToggleButton(label: 'Đã lưu', value: saved, onChanged: setSaved);\nUISegmentedControl<String>(options: options, value: view, onChanged: setView);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Checkbox', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        UICheckbox(
          label: 'Nhận thông báo qua email',
          value: checked,
          onChanged: (v) => setState(() => checked = v ?? false),
        ),
        const UICheckbox(
          label: 'Lựa chọn không khả dụng',
          value: false,
          onChanged: null,
        ),
        const UICheckbox(
          label: 'Đã chọn · không khả dụng',
          value: true,
          onChanged: null,
        ),
        const SizedBox(height: 20),
        const Text('Switch', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        UISwitch(
          label: 'Bật thông báo',
          value: notifications,
          onChanged: (v) => setState(() => notifications = v),
        ),
        const UISwitch(label: 'Không khả dụng', value: false, onChanged: null),
        const UISwitch(
          label: 'Đang bật · không khả dụng',
          value: true,
          onChanged: null,
        ),
        const SizedBox(height: 20),
        const Text(
          'Toggle button',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            UIToggleButton(
              label: saved ? 'Đã lưu' : 'Lưu mục này',
              icon: Icons.bookmark_border_rounded,
              selectedIcon: Icons.bookmark_rounded,
              value: saved,
              onChanged: (v) => setState(() => saved = v),
            ),
            const UIToggleButton(
              label: 'Không khả dụng',
              value: false,
              onChanged: null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Chọn một chế độ',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        UISegmentedControl<String>(
          options: const [
            UIOption(
              value: 'list',
              label: 'Danh sách',
              icon: Icons.view_list_rounded,
            ),
            UIOption(
              value: 'grid',
              label: 'Lưới',
              icon: Icons.grid_view_rounded,
            ),
          ],
          value: view,
          onChanged: (v) => setState(() => view = v),
        ),
        const SizedBox(height: 12),
        Text('Chế độ: ${view == 'list' ? 'Danh sách' : 'Lưới'}'),
      ],
    ),
  );
}

class AdaptiveDemo extends StatefulWidget {
  const AdaptiveDemo({super.key});
  @override
  State<AdaptiveDemo> createState() => _AdaptiveDemoState();
}

class _AdaptiveDemoState extends State<AdaptiveDemo> {
  double width = 360;
  bool largeText = false, actualSize = false;
  final horizontal = ScrollController();
  @override
  void dispose() {
    horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '08',
    title: 'Cùng một sản phẩm. Bố cục đúng ngữ cảnh.',
    description: 'Mobile tập trung vào tác vụ chính. Tablet dùng thanh điều hướng gọn. Desktop tách nội dung và phần hỗ trợ, giữ form ở chiều rộng dễ đọc. Thử nhập dữ liệu rồi đổi kích thước.',
    effects: 'Phân cấp rõ · không kéo giãn form · điều hướng đổi vị trí · giữ dữ liệu · hỗ trợ chữ lớn',
    code: "UIAdaptiveScaffold(\n  title: 'Hồ sơ cá nhân',\n  subtitle: 'Quản lý thông tin và tùy chọn của bạn.',\n  destinations: const [\n    UIDestination(label: 'Hồ sơ', icon: Icons.person_outline),\n    UIDestination(label: 'Thông báo', icon: Icons.notifications_none),\n  ],\n  selectedIndex: page,\n  onDestinationSelected: (value) => setState(() => page = value),\n  child: profileForm,\n  supporting: profileSummary,\n  actions: UIActions(children: [UIButton(label: 'Lưu thay đổi', onPressed: save)]),\n);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final size in [360.0, 768.0, 1080.0])
              UIToggleButton(
                label:
                    '${size == 360
                        ? 'Mobile'
                        : size == 768
                        ? 'Tablet'
                        : 'Desktop'} · ${size.toInt()}',
                value: width == size,
                onChanged: (_) => setState(() => width = size),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 8,
          children: [
            UISwitch(
              label: 'Chữ lớn 200%',
              value: largeText,
              onChanged: (v) => setState(() => largeText = v),
            ),
            UISwitch(
              label: 'Xem kích thước gốc',
              value: actualSize,
              onChanged: (v) => setState(() => actualSize = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final height = width == 360
                ? 720.0
                : width == 768
                ? 680.0
                : 640.0;
            final zoom = actualSize || constraints.maxWidth >= width
                ? 1.0
                : constraints.maxWidth / width;
            final preview = SizedBox(
              key: const ValueKey('adaptive-preview'),
              width: width,
              height: height,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(width, height),
                  textScaler: largeText
                      ? const TextScaler.linear(2)
                      : MediaQuery.textScalerOf(context),
                ),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const AdaptiveSample(),
                ),
              ),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${width.toInt()} × ${height.toInt()} · xem trước ${(zoom * 100).round()}%'
                    '${zoom < 1 ? ' · bật kích thước gốc để kiểm tra chữ và vùng bấm' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (actualSize)
                  Scrollbar(
                    controller: horizontal,
                    thumbVisibility: width > constraints.maxWidth,
                    child: SingleChildScrollView(
                      controller: horizontal,
                      scrollDirection: Axis.horizontal,
                      child: preview,
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: width * zoom,
                      height: height * zoom,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        child: preview,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class AdaptiveSample extends StatefulWidget {
  const AdaptiveSample({super.key});
  @override
  State<AdaptiveSample> createState() => _AdaptiveSampleState();
}

class _AdaptiveSampleState extends State<AdaptiveSample> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(text: 'An Nguyễn');
  final email = TextEditingController(text: 'an.nguyen@example.com');
  int page = 0;
  bool notify = true, security = true, saved = false;
  String period = 'week';
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  Widget section(
    BuildContext context,
    String title,
    String description,
    Widget child,
  ) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: s.surfaceContainerLowest,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: s.onSurfaceVariant,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return UIAdaptiveScaffold(
      title: ['Hồ sơ cá nhân', 'Thông báo', 'Bảo mật'][page],
      subtitle: [
        'Thông tin giúp mọi người nhận ra bạn trong không gian làm việc.',
        'Chọn những cập nhật hữu ích và thời điểm nhận tin.',
        'Giữ tài khoản của bạn an toàn.',
      ][page],
      destinations: const [
        UIDestination(
          label: 'Hồ sơ',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
        UIDestination(
          label: 'Thông báo',
          icon: Icons.notifications_none,
          selectedIcon: Icons.notifications,
        ),
        UIDestination(
          label: 'Bảo mật',
          icon: Icons.shield_outlined,
          selectedIcon: Icons.shield,
        ),
      ],
      selectedIndex: page,
      onDestinationSelected: (v) => setState(() {
        page = v;
        saved = false;
      }),
      supportingTitle: 'Gợi ý cho hồ sơ',
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Icon(Icons.layers_outlined, color: s.primary, size: 28),
      ),
      supporting: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: s.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: s.primary,
                  foregroundColor: s.onPrimary,
                  child: const Text('AN'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Không gian cá nhân',
                  style: TextStyle(
                    color: s.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mọi thay đổi bắt đầu từ những thông tin rõ ràng.',
                  style: TextStyle(
                    color: s.onPrimaryContainer,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'MẸO NHỎ',
            style: TextStyle(
              color: s.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dùng tên bạn thường gọi và một email có thể liên hệ.',
            style: TextStyle(
              color: s.onSurfaceVariant,
              height: 1.6,
              fontSize: 13,
            ),
          ),
        ],
      ),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saved)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  'Đã lưu trong bản demo',
                  style: TextStyle(color: s.primary, fontSize: 13),
                ),
              ),
            ),
          UIAdaptiveBuilder(
            builder: (context, ui) => Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    name.text = 'An Nguyễn';
                    email.text = 'an.nguyen@example.com';
                    notify = true;
                    security = true;
                    period = 'week';
                    saved = false;
                  }),
                  child: const Text('Đặt lại'),
                ),
                const Spacer(),
                Flexible(
                  child: UIButton(
                    label: 'Lưu thay đổi',
                    fullWidth: false,
                    onPressed: () {
                      if (page != 0 ||
                          (form.currentState?.validate() ?? false)) {
                        setState(() => saved = true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: page == 0
          ? Form(
              key: form,
              child: section(
                context,
                'Thông tin cơ bản',
                'Thông tin liên hệ chỉ được dùng trong bản demo này.',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UITextField(
                      key: const ValueKey('adaptive-name'),
                      label: 'Tên hiển thị',
                      controller: name,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Nhập tên hiển thị.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    UITextField(
                      label: 'Email liên hệ',
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.alternate_email,
                      validator: (v) =>
                          (v ?? '').contains('@') ? null : 'Nhập email hợp lệ.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bạn có thể chỉnh sửa lại bất cứ lúc nào.',
                      style: TextStyle(
                        color: s.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : page == 1
          ? section(
              context,
              'Tùy chọn nhận tin',
              'Ít gián đoạn hơn, đúng thông tin bạn cần.',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UISwitch(
                    label: 'Nhận thông báo',
                    value: notify,
                    onChanged: (v) => setState(() => notify = v),
                  ),
                  const SizedBox(height: 20),
                  UIRadioGroup<String>(
                    value: period,
                    options: const [
                      UIOption(value: 'day', label: 'Hàng ngày'),
                      UIOption(value: 'week', label: 'Hàng tuần'),
                      UIOption(value: 'month', label: 'Hàng tháng'),
                    ],
                    onChanged: (v) => setState(() => period = v ?? 'week'),
                  ),
                ],
              ),
            )
          : section(
              context,
              'Bảo vệ tài khoản',
              'Kiểm soát các thông báo về hoạt động đăng nhập.',
              UISwitch(
                value: security,
                label: 'Cảnh báo khi có đăng nhập mới',
                onChanged: (v) => setState(() => security = v),
              ),
            ),
    );
  }
}

class DropdownDemo extends StatefulWidget {
  const DropdownDemo({super.key});
  @override
  State<DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<DropdownDemo> {
  final form = GlobalKey<FormState>();
  String selected = 'personal';
  static const choices = [
    UIOption(
      value: 'personal',
      label: 'Cá nhân',
      icon: Icons.person_outline_rounded,
    ),
    UIOption(
      value: 'design',
      label: 'Thiết kế hệ thống',
      icon: Icons.palette_outlined,
    ),
    UIOption(
      value: 'youth',
      label: 'Ứng dụng thanh niên',
      icon: Icons.groups_outlined,
    ),
    UIOption(
      value: 'projects',
      label: 'Quản lý dự án',
      icon: Icons.work_outline_rounded,
    ),
    UIOption(value: 'docs', label: 'Kho tài liệu', icon: Icons.folder_outlined),
    UIOption(
      value: 'planning',
      label: 'Kế hoạch phát triển sản phẩm và phối hợp giữa các nhóm',
      icon: Icons.event_note_rounded,
    ),
    UIOption(
      value: 'mobile',
      label: 'Giao diện mobile',
      icon: Icons.smartphone_rounded,
    ),
    UIOption(
      value: 'web',
      label: 'Website cộng đồng',
      icon: Icons.language_rounded,
    ),
    UIOption(
      value: 'reports',
      label: 'Báo cáo hoạt động',
      icon: Icons.bar_chart_rounded,
    ),
    UIOption(
      value: 'events',
      label: 'Sự kiện sắp tới',
      icon: Icons.event_outlined,
    ),
    UIOption(
      value: 'archive',
      label: 'Lưu trữ · tạm khóa',
      icon: Icons.lock_outline_rounded,
      enabled: false,
    ),
    UIOption(
      value: 'settings',
      label: 'Cài đặt ứng dụng',
      icon: Icons.settings_outlined,
    ),
  ];
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '09',
    title: 'Dropdown menu',
    description: 'Popup bám ô chọn trên PC; bảng chọn từ dưới lên trên mobile cảm ứng. Cùng màu theme, bo góc, dấu chọn và trạng thái focus.',
    effects: 'Tìm không dấu · hàng cao theo nội dung · danh sách lazy · ↑/↓ Home End Enter Esc · form validation',
    code: "UISelect<String>(\n  label: 'Không gian làm việc',\n  initialValue: 'personal',\n  options: const [\n    UIOption(value: 'personal', label: 'Cá nhân'),\n    UIOption(value: 'design', label: 'Thiết kế hệ thống'),\n  ],\n  onChanged: selectWorkspace,\n); // Tự thêm tìm kiếm khi có từ 8 lựa chọn.",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UIGrid(
          maxColumns: 2,
          children: [
            UISelect<String>(
              label: 'Không gian làm việc',
              initialValue: selected,
              options: choices,
              helper: 'Thử tìm “ung dung” hoặc “thiet ke”.',
              onChanged: (v) => setState(() => selected = v!),
            ),
            const UISelect<String>(
              label: 'Lựa chọn không khả dụng',
              initialValue: 'personal',
              options: choices,
              helper: 'Disabled không mở menu.',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Bạn đã chọn: ${choices.firstWhere((o) => o.value == selected).label}',
        ),
        const SizedBox(height: 24),
        Form(
          key: form,
          child: UISelect<String>(
            label: 'Lựa chọn bắt buộc',
            options: choices.take(3).toList(),
            validator: (v) =>
                v == null ? 'Hãy chọn một không gian làm việc.' : null,
            onChanged: (_) {},
          ),
        ),
        const SizedBox(height: 16),
        UIActions(
          children: [
            UIButton(
              label: 'Kiểm tra lựa chọn',
              onPressed: () => form.currentState!.validate(),
            ),
            UIButton(
              label: 'Đặt lại',
              variant: UIButtonVariant.outline,
              onPressed: () => form.currentState!.reset(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const UIAlert(
          message: 'Bấm ngoài menu hoặc Esc để đóng. Mục đang chọn có dấu ✓; mục bị khóa không nhận thao tác. Menu tự theo màu và chế độ sáng/tối.',
        ),
      ],
    ),
  );
}

class InputDemo extends StatefulWidget {
  const InputDemo({super.key});
  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  final email = TextEditingController();
  final password = TextEditingController();
  String result = 'success';
  int attempts = 0;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '02',
    title: 'Form & Inputs',
    description: 'Nhập tự nhiên, nhận lỗi đúng lúc và giữ nguyên dữ liệu khi gửi thất bại.',
    effects: 'Rời ô để kiểm tra · sửa lỗi trực tiếp · focus lỗi đầu tiên · khoá khi gửi · lỗi server theo tên trường',
    code: "UIForm(\n  onSubmit: () async {\n    await api.save(email.text);\n    // Lỗi server: throw UIFormException(\n    //   fieldErrors: {'email': 'Email đã tồn tại.'});\n  },\n  children: [\n    UITextField(name: 'email', label: 'Email',\n      controller: email, validator: UIValidators.email()),\n    UIPasswordField(name: 'password', controller: password),\n  ],\n);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const UIAlert(
          title: 'Thử một quy trình gửi thật',
          message: 'Chọn kết quả mô phỏng, nhập dữ liệu rồi gửi. Demo chỉ chạy trong trình duyệt, không tạo tài khoản.',
          liveRegion: false,
        ),
        const SizedBox(height: 20),
        UISelect<String>(
          label: 'Kết quả mô phỏng',
          initialValue: result,
          options: const [
            UIOption(value: 'success', label: 'Thành công'),
            UIOption(value: 'field', label: 'Email đã được sử dụng'),
            UIOption(value: 'network', label: 'Lỗi kết nối'),
          ],
          onChanged: (value) => setState(() => result = value!),
        ),
        const SizedBox(height: 24),
        UIForm(
          submitLabel: 'Kiểm tra biểu mẫu',
          onSubmit: () async {
            final outcome = result;
            setState(() => attempts++);
            await Future<void>.delayed(const Duration(milliseconds: 900));
            if (outcome == 'field') {
              throw const UIFormException(
                fieldErrors: {
                  'email': 'Email này đã được sử dụng. Hãy chọn email khác.',
                },
              );
            }
            if (outcome == 'network') {
              throw const UIFormException(
                message:
                    'Không thể kết nối. Dữ liệu vẫn được giữ để bạn thử lại.',
              );
            }
          },
          onSuccess: () => UINotice.show(
            context,
            message: 'Dữ liệu hợp lệ. Đã hoàn tất bản gửi mô phỏng.',
            tone: UITone.success,
          ),
          children: [
            UITextField(
              name: 'email',
              label: 'Email',
              controller: email,
              hint: 'ban@example.com',
              helper: 'Kiểm tra sau khi rời ô hoặc gửi.',
              prefixIcon: Icons.mail_outline,
              clearable: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: UIValidators.email(),
            ),
            UIPasswordField(
              name: 'password',
              controller: password,
              helper: 'Ít nhất 8 ký tự. Có thể bấm biểu tượng để xem.',
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              validator: UIValidators.minLength(8),
            ),
            UITextField.multiline(
              label: 'Giới thiệu',
              maxLength: 180,
              helper: 'Tự tăng chiều cao từ 3 đến 6 dòng.',
            ),
            const UITextField(
              label: 'Thông tin đã xác minh',
              helper: 'Ví dụ trường không khả dụng',
              enabled: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Số lần gửi mô phỏng: $attempts'),
        const SizedBox(height: 28),
        const Text(
          'Textbox dùng nhanh',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nền mềm cho tìm kiếm; prefix/suffix cho đơn vị; read-only vẫn cho phép chọn và sao chép.',
        ),
        const SizedBox(height: 16),
        UIGrid(
          maxColumns: 2,
          children: [
            UITextField.search(
              label: 'Tìm trong thư viện',
              onFieldSubmitted: (query) => UINotice.show(
                context,
                title: 'Tìm kiếm mẫu',
                message: query.isEmpty
                    ? 'Bạn chưa nhập từ khoá.'
                    : 'Từ khoá: $query',
              ),
            ),
            const UITextField(
              label: 'Ngân sách',
              initialValue: '250000',
              suffixText: 'VND',
              keyboardType: TextInputType.number,
              variant: UIInputVariant.filled,
            ),
            UITextField.pin(
              label: 'Mã PIN',
              length: 4,
              helper: '4 chữ số · bàn phím số · ẩn nội dung',
            ),
            UITextField.pin(
              label: 'Mã xác thực OTP',
              obscureText: false,
              autofillHints: const [AutofillHints.oneTimeCode],
              helper: '6 chữ số · thử dán cả chữ và số',
            ),
            const UITextField(
              label: 'Mã tham chiếu',
              initialValue: 'REF-2026',
              readOnly: true,
              helper: 'Chỉ đọc · có thể chọn và sao chép',
            ),
            const UITextField(
              label: 'Lỗi được ứng dụng cung cấp',
              initialValue: 'demo',
              errorText:
                  'Thông báo lỗi có thể đặt trực tiếp, ngoài managed form.',
            ),
          ],
        ),
      ],
    ),
  );
}

class CardDemo extends StatelessWidget {
  const CardDemo({super.key});
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '03',
    title: 'Cards & Badges',
    description: 'Nhóm nội dung và thể hiện trạng thái bằng ngôn ngữ thị giác nhất quán.',
    effects: 'Card có onTap nâng nhẹ khi hover · ripple khi nhấn · badge đổi theo theme',
    code: "UICard(onTap: openDetail, child: content);\nUIBadge(label: 'Đã xác nhận', tone: UITone.success);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            UIBadge(label: 'Thành viên'),
            UIBadge(
              label: 'Đã xác nhận',
              tone: UITone.success,
              icon: Icons.check,
            ),
            UIBadge(label: 'Chờ duyệt', tone: UITone.warning),
            UIBadge(label: 'Cần bổ sung', tone: UITone.danger),
          ],
        ),
        const SizedBox(height: 24),
        UICard(
          onTap: () => toast(context, 'Bạn đã mở thẻ hoạt động demo.'),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.volunteer_activism_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dự án sáng tạo',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Chạm để thử hiệu ứng của thẻ',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ],
    ),
  );
}

class FeedbackDemo extends StatefulWidget {
  const FeedbackDemo({super.key});
  @override
  State<FeedbackDemo> createState() => _FeedbackDemoState();
}

class _FeedbackDemoState extends State<FeedbackDemo> {
  bool online = false, archived = false;
  int batch = 0;
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '04',
    title: 'Alerts & Dialog',
    description: 'Phản hồi đặt đúng nơi: banner cho trạng thái, thông báo ngắn cho thao tác và dialog cho quyết định.',
    effects: 'Hàng đợi tối đa 5 · chống trùng · Hoàn tác · lỗi quan trọng giữ đến khi đóng · nút thao tác theo theme',
    code: "UINotice.show(context,\n  message: 'Đã lưu trữ mục.',\n  tone: UITone.success,\n  actionLabel: 'Hoàn tác',\n  onAction: restoreItem,\n);\n\nUIAlert(message: 'Đang ngoại tuyến',\n  tone: UITone.warning,\n  actionLabel: 'Thử lại', onAction: reconnect);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UIAlert(
          title: online ? 'Đã kết nối' : 'Bạn đang ngoại tuyến',
          message: online
              ? 'Có thể tiếp tục đồng bộ dữ liệu.'
              : 'Bản nháp vẫn được giữ. Kiểm tra kết nối rồi thử lại.',
          tone: online ? UITone.success : UITone.warning,
          actionLabel: online ? 'Mô phỏng mất mạng' : 'Thử kết nối lại',
          onAction: () => setState(() => online = !online),
        ),
        const SizedBox(height: 20),
        UICard(
          child: Row(
            children: [
              Icon(
                archived
                    ? Icons.inventory_2_outlined
                    : Icons.description_outlined,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  archived
                      ? 'Mục demo đã được lưu trữ'
                      : 'Tài liệu demo đang hiển thị',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        UIActions(
          children: [
            UIButton(
              label: 'Thử SnackBar',
              variant: UIButtonVariant.soft,
              onPressed: () => UINotice.show(
                context,
                message: 'Đã sao chép liên kết.',
                tone: UITone.success,
              ),
            ),
            UIButton(
              label: 'Lưu trữ và Hoàn tác',
              onPressed: archived
                  ? null
                  : () {
                      setState(() => archived = true);
                      UINotice.show(
                        context,
                        id: 'archive-demo',
                        message: 'Đã lưu trữ mục demo.',
                        tone: UITone.success,
                        actionLabel: 'Hoàn tác',
                        onAction: () {
                          if (mounted) setState(() => archived = false);
                        },
                      );
                    },
            ),
            UIButton(
              label: 'Thử hàng đợi',
              variant: UIButtonVariant.outline,
              onPressed: () {
                final run = ++batch;
                for (var i = 1; i <= 3; i++) {
                  UINotice.show(
                    context,
                    id: 'batch-$run-$i',
                    message: 'Thông báo $i / 3 · lượt $run',
                  );
                }
              },
            ),
            UIButton(
              label: 'Thử chống trùng',
              variant: UIButtonVariant.outline,
              onPressed: () {
                for (var i = 0; i < 3; i++) {
                  UINotice.show(
                    context,
                    id: 'duplicate-demo',
                    message: 'Ba lần gọi, chỉ một thông báo.',
                  );
                }
              },
            ),
            UIButton(
              label: 'Thử lỗi quan trọng',
              tone: UITone.danger,
              variant: UIButtonVariant.soft,
              onPressed: () => UINotice.show(
                context,
                message: 'Chưa đồng bộ được bản nháp. Đóng thông báo sau khi đã đọc.',
                tone: UITone.danger,
              ),
            ),
            UIButton(
              label: 'Thông báo có tiêu đề',
              variant: UIButtonVariant.soft,
              onPressed: () => UINotice.show(
                context,
                title: 'Đồng bộ hoàn tất',
                message: 'Các thay đổi đã được cập nhật. Bạn có thể tiếp tục làm việc.',
                tone: UITone.success,
              ),
            ),
            UIButton(
              label: 'Thử nội dung dài',
              variant: UIButtonVariant.outline,
              onPressed: () => UINotice.show(
                context,
                title: 'Chi tiết cần kiểm tra',
                message: List.filled(
                  8,
                  'Một mục chưa được đồng bộ. Dữ liệu được giữ lại để bạn kiểm tra và thử lại.',
                ).join(' '),
                tone: UITone.warning,
                persistent: true,
              ),
            ),
            UIButton(
              label: 'Xoá hàng đợi',
              variant: UIButtonVariant.ghost,
              onPressed: () => UINotice.clear(context),
            ),
            UIButton(
              label: 'Mở dialog',
              variant: UIButtonVariant.outline,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  icon: const Icon(Icons.info_outline),
                  title: const Text('Xác nhận thao tác'),
                  content: const Text(
                    'Chỉ dùng dialog khi cần người dùng quyết định trước khi tiếp tục.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Thông báo có Hoàn tác và lỗi quan trọng sẽ giữ đến khi bạn thao tác hoặc đóng. Các mục còn lại xếp hàng lần lượt.',
        ),
      ],
    ),
  );
}

class MotionDemo extends StatefulWidget {
  const MotionDemo({super.key, required this.reduce, required this.onReduce});
  final bool reduce;
  final ValueChanged<bool> onReduce;
  @override
  State<MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<MotionDemo> {
  int replay = 0, step = 0;
  bool detailsVisible = false;
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '05',
    title: 'Motion & Animation',
    description:
        'Chuyển động nhẹ giúp nhận biết thay đổi, giữ nội dung là trọng tâm.',
    effects: '160 / 240 / 320 ms · xuất hiện / thay nội dung / mở thu · ngừng ticker khi ẩn · tôn trọng reduced motion',
    code: "UIEntrance(\n  key: ValueKey(replay),\n  child: yourWidget,\n);\nUIAnimatedContent(\n  child: Text('Bước \$step', key: ValueKey(step)),\n);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UISwitch(
          label: 'Giảm chuyển động',
          value: widget.reduce,
          onChanged: widget.onReduce,
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [Text('Chuyển theme toàn ứng dụng'), UIThemeToggle()],
        ),
        const SizedBox(height: 20),
        UIButton(
          label: detailsVisible ? 'Thu gọn nội dung' : 'Mở nội dung bổ sung',
          variant: UIButtonVariant.outline,
          icon: detailsVisible ? Icons.expand_less : Icons.expand_more,
          onPressed: () => setState(() => detailsVisible = !detailsVisible),
        ),
        UIReveal(
          visible: detailsVisible,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: UICard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Mở/thu mà vẫn giữ nội dung đã nhập',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const UITextField(
                    label: 'Ghi chú giữ lại khi thu gọn',
                    helper: 'Khi ẩn, phần này không nhận focus, tương tác hoặc chạy ticker.',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, box) {
            final children = [
              motionTile(
                context,
                'Xuất hiện nhẹ nhàng',
                UIEntrance(
                  key: ValueKey(replay),
                  child: const UIBadge(
                    label: 'Xin chào, sáng tạo!',
                    icon: Icons.waving_hand_outlined,
                  ),
                ),
                UIButton(
                  label: 'Chạy lại',
                  icon: Icons.replay_rounded,
                  variant: UIButtonVariant.soft,
                  onPressed: () => setState(() => replay++),
                ),
              ),
              motionTile(
                context,
                'Chuyển nội dung',
                UIAnimatedContent(
                  child: UIBadge(
                    key: ValueKey(step),
                    label: ['Khám phá', 'Kết nối', 'Cùng tiến bước'][step],
                    tone: [
                      UITone.primary,
                      UITone.success,
                      UITone.secondary,
                    ][step],
                  ),
                ),
                UIButton(
                  label: 'Đổi nội dung',
                  icon: Icons.swap_horiz_rounded,
                  variant: UIButtonVariant.soft,
                  onPressed: () => setState(() => step = (step + 1) % 3),
                ),
              ),
            ];
            return box.maxWidth > 650
                ? Row(
                    children: [
                      Expanded(child: children[0]),
                      const SizedBox(width: 18),
                      Expanded(child: children[1]),
                    ],
                  )
                : Column(
                    children: [
                      children[0],
                      const SizedBox(height: 18),
                      children[1],
                    ],
                  );
          },
        ),
      ],
    ),
  );
  Widget motionTile(
    BuildContext context,
    String title,
    Widget demo,
    Widget action,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 100, child: Center(child: demo)),
        action,
      ],
    ),
  );
}

class ImageDemo extends StatefulWidget {
  const ImageDemo({super.key});
  @override
  State<ImageDemo> createState() => _ImageDemoState();
}

class _ImageDemoState extends State<ImageDemo> {
  bool missing = true;
  BoxFit fit = BoxFit.cover;
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '10',
    title: 'Images · fallback theo ứng dụng',
    description: 'Nguồn rỗng hoặc lỗi dùng ảnh dự phòng của bạn. Nếu ảnh dự phòng cũng lỗi, chuyển sang widget cuối. Khung, bo góc và cách căn ảnh được giữ nguyên.',
    effects: 'Asset / URL / provider · placeholder riêng · fallback một bước · retry an toàn · khung thích ứng',
    code: "UIImage(photoUrl,\n  fallbackSource: 'assets/default-cover.png',\n  fallback: const Icon(Icons.hide_image_outlined),\n  placeholder: const UIWireframe.image(),\n);\n\nUIImage.avatar(avatarUrl,\n  fallbackSource: 'assets/default-avatar.png',\n  fallback: const Center(child: Text('AN')),\n);\n\n// Tự xử lý toàn bộ giao diện lỗi:\nUIImage(photoUrl, errorBuilder: (context, error, stack) =>\n  const Center(child: Text('Ảnh chưa có sẵn')));",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const UIImage.banner(
          'assets/studio.png',
          semanticLabel: 'Ảnh mẫu cục bộ',
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            UIImage.avatar('assets/studio.png'),
            UIImage.thumbnail('assets/studio.png'),
            UIImage.avatar(
              null,
              fallback: Center(child: Text('AN')),
              semanticLabel: 'Ảnh đại diện thay thế bằng tên viết tắt',
            ),
            UIImage.thumbnail(null, fallbackSource: 'assets/studio.png'),
          ],
        ),
        const SizedBox(height: 20),
        UISwitch(
          value: missing,
          label: 'Nguồn chính không có sẵn',
          onChanged: (value) => setState(() => missing = value),
        ),
        const SizedBox(height: 12),
        UISelect<BoxFit>(
          label: 'Cách đặt ảnh',
          initialValue: fit,
          options: const [
            UIOption(value: BoxFit.cover, label: 'Cover · lấp đầy khung'),
            UIOption(value: BoxFit.contain, label: 'Contain · giữ toàn bộ ảnh'),
          ],
          onChanged: (value) => setState(() => fit = value ?? BoxFit.cover),
        ),
        const SizedBox(height: 12),
        const Text('Ảnh dự phòng riêng · bật/tắt nguồn để thử đổi ảnh'),
        const SizedBox(height: 8),
        UIImage(
          missing ? null : 'assets/studio.png',
          height: 140,
          fit: fit,
          fallbackSource: 'assets/fallback.png',
          fallback: const Center(child: Text('Ảnh dự phòng chưa có sẵn')),
        ),
        const SizedBox(height: 20),
        const Text('Cả hai nguồn đều lỗi · widget fallback cuối'),
        const SizedBox(height: 8),
        const UIImage(
          null,
          height: 100,
          fallbackSource: 'assets/intentional-missing.png',
          fallback: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hide_image_outlined),
                SizedBox(width: 8),
                Flexible(child: Text('Chưa có ảnh')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('errorBuilder · giao diện lỗi do ứng dụng quyết định'),
        const SizedBox(height: 8),
        UIImage(
          null,
          height: 80,
          errorBuilder: (context, error, stack) =>
              const Center(child: Text('Nội dung ảnh sẽ được cập nhật')),
        ),
        const SizedBox(height: 20),
        const Text('Fallback mặc định'),
        const SizedBox(height: 8),
        const UIImage(null, height: 80, allowRetry: false),
      ],
    ),
  );
}

class WireframeDemo extends StatefulWidget {
  const WireframeDemo({super.key});
  @override
  State<WireframeDemo> createState() => _WireframeDemoState();
}

class _WireframeDemoState extends State<WireframeDemo> {
  static const samples = <String, Object?>{
    'Bài viết': {'title': 'Tiêu đề', 'body': 'Nội dung', 'cover': 'cover.png'},
    'Bảng tin': [
      {'title': 'Tin mới', 'image': 'photo.png', 'body': 'Nội dung'},
    ],
    'Hồ sơ': {
      'name': 'Thanh niên',
      'avatar': null,
      'email': 'user@example.test',
    },
    'Sản phẩm': {
      'name': 'Sách',
      'price': 50000,
      'currency': 'VND',
      'image': 'book.png',
    },
    'Thư viện ảnh': ['a.png', 'b.webp', 'c.jpg'],
    'Hội thoại': [
      {'sender': 'An', 'text': 'Xin chào', 'timestamp': '2026-10-22'},
    ],
    'Bảng dữ liệu': [
      {'id': 1, 'name': 'An', 'score': 8},
      {'id': 2, 'name': 'Bình', 'score': 9},
    ],
    'Cài đặt': {'notifications': true, 'sound': false, 'language': 'vi'},
    'Dòng thời gian': [
      {'date': '2026-10-22', 'event': 'Tạo hoạt động'},
    ],
    'Dashboard': {
      'stats': {'members': 120},
      'series': [10, 20, 30],
    },
    'Trang quảng bá': {
      'hero': {
        'headline': 'Một không gian làm việc thống nhất',
        'subtitle': 'Tập trung vào công việc quan trọng',
        'heroImage': 'https://cdn.example.test/hero',
        'primaryAction': {'label': 'Bắt đầu', 'href': '/start'},
      },
      'features': ['Cộng tác', 'Tổ chức', 'Theo dõi'],
    },
    'Sự kiện': {
      'title': 'Ngày hội sáng tạo',
      'startsAt': '2026-11-25',
      'location': 'Đồng Nai',
      'organizer': 'Đơn vị tổ chức',
      'poster': 'poster.png',
      'registrationUrl': '/register',
    },
    'Gói dịch vụ': {
      'plans': [
        {
          'name': 'Cá nhân',
          'price': 99000,
          'billingPeriod': 'month',
          'features': ['Ghi chú', 'Lưu trữ'],
        },
        {
          'name': 'Nhóm',
          'price': 199000,
          'billingPeriod': 'month',
          'features': ['Cộng tác', 'Quản lý'],
        },
      ],
    },
    'Danh sách sản phẩm': [
      {'name': 'Sách A', 'price': 50000, 'currency': 'VND', 'image': 'a.png'},
      {'name': 'Sách B', 'price': 60000, 'currency': 'VND', 'image': 'b.png'},
    ],
    'Chưa rõ loại': {'reference': 'X123', 'value': null},
    'Dữ liệu rỗng': [],
  };
  String sampleName = 'Bài viết';
  UIWireframeLayout? layoutOverride;
  late Object? data = samples[sampleName];
  late final input = TextEditingController(
    text: const JsonEncoder.withIndent('  ').convert(data),
  );
  late UIWireframePlan plan = UIWireframe.inspect(data);
  String? error;
  Timer? _analysisTimer;
  String? _lastScheduledText;
  @override
  void initState() {
    super.initState();
    input.addListener(_scheduleAnalysis);
  }

  void _scheduleAnalysis() {
    if (_lastScheduledText == input.text) return;
    _lastScheduledText = input.text;
    _analysisTimer?.cancel();
    _analysisTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) apply();
    });
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    input.removeListener(_scheduleAnalysis);
    input.dispose();
    super.dispose();
  }

  void apply() {
    _analysisTimer?.cancel();
    if (input.text.length > 20000) {
      setState(() => error = 'Bản demo giới hạn JSON ở 20.000 ký tự.');
      return;
    }
    try {
      final parsed = jsonDecode(input.text);
      setState(() {
        data = parsed;
        plan = UIWireframe.inspect(data, layout: layoutOverride);
        error = null;
      });
    } on FormatException {
      setState(
        () => error = 'JSON chưa hợp lệ. Bản xem trước giữ kết quả gần nhất.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '11',
    title: 'Wireframe · nhận diện cấu trúc dữ liệu',
    description: '17 bố cục. Phân tích dữ liệu mẫu, kiểu trường và dấu hiệu ngữ nghĩa; tự đổi cách sắp xếp theo vùng hiển thị. Không hiển thị giá trị đầu vào.',
    effects: 'Phân tích có giới hạn · có lý do lựa chọn · không AI/network · không ticker',
    code: "UIWireframe.auto(data: sample);\n\n// Biết rõ màn hình: ưu tiên chỉ định.\nUIWireframe.auto(data: sample, layout: UIWireframeLayout.profile);\n\n// Chưa có dữ liệu, dùng schema form:\nUIWireframe.auto(fields: const [\n  UIWireframeField('email', type: UIWireframeFieldType.email),\n  UIWireframeField('password', type: UIWireframeFieldType.password),\n]);\n\nfinal plan = UIWireframe.inspect(sample);\nUIWireframe.fromPlan(plan: plan);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UIGrid(
          maxColumns: 2,
          children: [
            UISelect<String>(
              label: 'Dữ liệu mẫu',
              initialValue: sampleName,
              options: [
                for (final name in samples.keys)
                  UIOption(value: name, label: name),
              ],
              onChanged: (name) {
                if (name == null) return;
                setState(() {
                  sampleName = name;
                  data = samples[name];
                  input.text = const JsonEncoder.withIndent('  ').convert(data);
                  plan = UIWireframe.inspect(data, layout: layoutOverride);
                  error = null;
                });
              },
            ),
            UISelect<String>(
              label: 'Bố cục',
              initialValue: layoutOverride?.name ?? 'auto',
              options: [
                const UIOption(value: 'auto', label: 'Tự nhận diện'),
                for (final item in UIWireframeLayout.values)
                  UIOption(value: item.name, label: item.name),
              ],
              onChanged: (name) => setState(() {
                layoutOverride = name == null || name == 'auto'
                    ? null
                    : UIWireframeLayout.values.byName(name);
                plan = UIWireframe.inspect(data, layout: layoutOverride);
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        UITextField(
          label: 'JSON mẫu · tự phân tích khi ngừng nhập',
          helper:
              'Tự nhận diện sau 350 ms; JSON lỗi giữ bố cục hợp lệ gần nhất.',
          controller: input,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 12),
        UIButton(label: 'Phân tích dữ liệu', onPressed: apply),
        if (error != null) ...[
          const SizedBox(height: 12),
          UIAlert(message: error!, tone: UITone.danger),
        ],
        const SizedBox(height: 16),
        UIAlert(
          title: '${plan.layout.name} · ${plan.confidence.name}',
          message:
              '${plan.reasons.join(' ')}\nMức bằng chứng là heuristic, không phải xác suất chính xác. Dữ liệu khó phân biệt sẽ dùng detail/list; có thể chọn bố cục thủ công.',
        ),
        const SizedBox(height: 16),
        if (plan.fields.isNotEmpty) ...[
          Text(
            'Kiểu trường: ${plan.fields.map((f) => '${f.name}: ${f.type.name}').join(' · ')}',
          ),
          const SizedBox(height: 16),
        ],
        UIWireframe.fromPlan(plan: plan),
      ],
    ),
  );
}

class UsageDemo extends StatelessWidget {
  const UsageDemo({super.key});
  @override
  Widget build(BuildContext context) => const DemoBlock(
    number: 'START',
    title: 'Khởi tạo một lần',
    description: 'Truyền một màu; tùy chọn màu thứ hai. Không cần tự chọn màu chữ, nền hay hover.',
    effects: 'Sinh theme light/dark theo vai trò · giữ brand gốc · widget tự kế thừa',
    code: "UIApp(\n  primary: Colors.indigo,\n  home: Scaffold(body: UIPage(children: [\n    UIForm(children: [UITextField(label: 'Email'), UIPasswordField()]),\n    UIImage('assets/photo.png'),\n    UIActions(children: [UIButton(label: 'Tiếp tục', onPressed: submit)]),\n    UIThemeToggle(),\n  ])),\n);\n\n// Phác bố cục khi chưa có nội dung:\nUIWireframe.page(layout: UIWireframeLayout.dashboard);",
    child: UIAlert(
      title: 'Màu gốc khác vai trò tương tác',
      message: 'Seed được giữ trong YouthColors.brandPrimary. Action, container, chữ, viền và trạng thái được sinh theo chế độ và kiểm tra tương phản.',
    ),
  );
}

class RadioDemo extends StatefulWidget {
  const RadioDemo({super.key});
  @override
  State<RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<RadioDemo> {
  String? value = 'weekly';
  bool disabled = false;
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '13',
    title: 'Radio · chọn một phương án',
    description: 'Chỉ vùng control 48px nhận bấm/hover. Tab vào nhóm, phím mũi tên đổi phương án, Space chọn. Nhãn dài tự xuống dòng.',
    effects: 'Native RadioGroup · focus bàn phím · disabled · theme · ngang/dọc thích ứng',
    code: "UIRadioGroup<String>(\n  label: 'Tần suất',\n  value: frequency,\n  options: const [\n    UIOption(value: 'daily', label: 'Hàng ngày'),\n    UIOption(value: 'weekly', label: 'Hàng tuần'),\n  ],\n  onChanged: (value) => setState(() => frequency = value),\n);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UISwitch(
          value: disabled,
          label: 'Khóa nhóm lựa chọn',
          onChanged: (v) => setState(() => disabled = v),
        ),
        const SizedBox(height: 16),
        UIRadioGroup<String>(
          label: 'Tần suất nhận tin',
          value: value,
          direction: Axis.horizontal,
          options: const [
            UIOption(value: 'daily', label: 'Hàng ngày'),
            UIOption(value: 'weekly', label: 'Hàng tuần'),
            UIOption(value: 'monthly', label: 'Hàng tháng'),
            UIOption(
              value: 'locked',
              label: 'Phương án không khả dụng',
              enabled: false,
            ),
          ],
          onChanged: disabled ? null : (v) => setState(() => value = v),
        ),
        const SizedBox(height: 16),
        Text('Lựa chọn hiện tại: $value'),
        const SizedBox(height: 20),
        UIRadioGroup<int>(
          label: 'Nhóm độc lập',
          value: 1,
          onChanged: null,
          options: const [
            UIOption(value: 1, label: 'Lựa chọn đã chọn · bị khóa'),
            UIOption(
              value: 2,
              label: 'Nhãn dài tự xuống dòng khi không gian hiển thị nhỏ hoặc người dùng tăng cỡ chữ',
            ),
          ],
        ),
      ],
    ),
  );
}

typedef _DemoMember = ({int id, String name, int points, bool active});

class TableDemo extends StatefulWidget {
  const TableDemo({super.key});
  @override
  State<TableDemo> createState() => _TableDemoState();
}

class _TableDemoState extends State<TableDemo> {
  static final rows = List.generate(
    23,
    (i) => (
      id: i + 1,
      name: ['An', 'Bình', 'Chi', 'Dũng'][i % 4],
      points: (i * 17 + 8) % 100,
      active: i.isEven,
    ),
  );
  Set<Object> selected = {};
  bool loading = false, empty = false, failed = false;
  String query = '';
  int pageSize = 5;
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '12',
    title: 'Table · bảng dữ liệu thích ứng',
    description: 'Bấm tiêu đề để sắp xếp, chọn từng dòng và chuyển trang. Mobile/chữ lớn tự dùng thẻ có nhãn cột. Chỉ dựng ô của trang hiện tại.',
    effects: 'Tìm kiếm không dấu · chọn cả trang · số dòng tùy chọn · độ rộng cột · lỗi/thử lại · mobile/desktop',
    code: "UITable<Person>(\n  rows: people,\n  columns: [\n    UITableColumn(label: 'Tên', value: (p) => p.name,\n      compare: (a, b) => a.name.compareTo(b.name)),\n    UITableColumn(label: 'Điểm', value: (p) => '\${p.points}',\n      numeric: true, compare: (a, b) => a.points.compareTo(b.points)),\n  ],\n  rowKey: (p) => p.id,\n  selectedKeys: selected,\n  onSelectionChanged: (keys) => setState(() => selected = keys),\n);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UITextField.search(
          label: 'Tìm thành viên, điểm hoặc trạng thái',
          onChanged: (value) => setState(() => query = value),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            UISwitch(
              value: loading,
              label: 'Đang tải',
              onChanged: (v) => setState(() => loading = v),
            ),
            UISwitch(
              value: failed,
              label: 'Lỗi kết nối',
              onChanged: (v) => setState(() => failed = v),
            ),
            UISwitch(
              value: empty,
              label: 'Dữ liệu rỗng',
              onChanged: (v) => setState(() => empty = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        UITable<_DemoMember>(
          label: 'Danh sách thành viên',
          rows: empty ? rows.take(0).toList() : rows,
          pageSize: pageSize,
          onPageSizeChanged: (value) => setState(() => pageSize = value),
          searchQuery: query,
          showSelectAll: true,
          error: failed ? 'Không thể tải thành viên. Hãy thử lại.' : null,
          onRetry: () => setState(() => failed = false),
          loading: loading,
          rowKey: (p) => p.id,
          selectedKeys: selected,
          onSelectionChanged: (keys) => setState(() => selected = keys),
          columns: [
            UITableColumn(
              label: 'Tên',
              value: (p) => p.name,
              compare: (a, b) => a.name.compareTo(b.name),
            ),
            UITableColumn(
              label: 'Điểm',
              minWidth: 80,
              value: (p) => '${p.points}',
              numeric: true,
              compare: (a, b) => a.points.compareTo(b.points),
            ),
            UITableColumn(
              label: 'Trạng thái',
              value: (p) => p.active ? 'Hoạt động' : 'Chờ duyệt',
              cellBuilder: (context, p) => UIBadge(
                label: p.active ? 'Hoạt động' : 'Chờ duyệt',
                tone: p.active ? UITone.success : UITone.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Đã chọn: ${selected.length} dòng'),
      ],
    ),
  );
}

class StateViewDemo extends StatefulWidget {
  const StateViewDemo({super.key});
  @override
  State<StateViewDemo> createState() => _StateViewDemoState();
}

class _StateViewDemoState extends State<StateViewDemo> {
  UIStateKind kind = UIStateKind.empty;
  bool custom = false;
  static const names = [
    'Đang tải',
    'Dữ liệu rỗng',
    'Có lỗi',
    'Ngoại tuyến',
    'Thiếu quyền',
    'Hoàn tất',
  ];
  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '14',
    title: 'Trạng thái màn hình',
    description: 'Một component cho từng tình huống. Ứng dụng chủ động truyền trạng thái, nội dung và callback.',
    effects: 'Tôn trọng reduced motion · cuộn khi chữ lớn · thay hình minh họa · hành động tùy chọn',
    code: "UIStateView.empty(message: 'Thêm dự án đầu tiên của bạn.',\n  onAction: createProject);\nUIStateView.error(message: errorMessage, onAction: retry);\nUIStateView.loading(progress: .65);",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UISelect<UIStateKind>(
          label: 'Tình huống',
          initialValue: kind,
          options: [
            for (final value in UIStateKind.values)
              UIOption(value: value, label: names[value.index]),
          ],
          onChanged: (value) {
            if (value != null) setState(() => kind = value);
          },
        ),
        const SizedBox(height: 16),
        UISwitch(
          label: 'Hình minh họa tùy chỉnh',
          value: custom,
          onChanged: (v) => setState(() => custom = v),
        ),
        const SizedBox(height: 16),
        UICard(
          child: UIStateView(
            kind: kind,
            message: switch (kind) {
              UIStateKind.loading =>
                'Đã xử lý 65% nội dung. Bạn có thể hủy thao tác.',
              UIStateKind.empty =>
                'Tạo dự án đầu tiên để bắt đầu cộng tác với đội của bạn.',
              UIStateKind.error =>
                'Nội dung chưa tải được. Hãy thử lại sau một chút.',
              UIStateKind.offline =>
                'Bản nháp vẫn được giữ trên thiết bị trong ví dụ này.',
              UIStateKind.forbidden =>
                'Liên hệ người quản lý để được cấp quyền phù hợp.',
              UIStateKind.success =>
                'Bạn đã hoàn tất bước này. Có thể tiếp tục công việc.',
            },
            illustration: custom
                ? const Icon(Icons.auto_awesome_rounded, size: 64)
                : null,
            progress: kind == UIStateKind.loading ? .65 : null,
            onAction: () => toast(
              context,
              'Đã gọi callback của trạng thái ${names[kind.index].toLowerCase()}.',
            ),
          ),
        ),
      ],
    ),
  );
}

class AdaptiveDialogDemo extends StatefulWidget {
  const AdaptiveDialogDemo({super.key});
  @override
  State<AdaptiveDialogDemo> createState() => _AdaptiveDialogDemoState();
}

class _AdaptiveDialogDemoState extends State<AdaptiveDialogDemo> {
  String result = 'Chưa có kết quả';
  Future<void> open(UIPresentation presentation) async {
    final answer = await UIAdaptiveDialog.show<String>(
      context,
      title: 'Gửi phản hồi',
      presentation: presentation,
      builder: (_) => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Popup tự cuộn khi nội dung dài hoặc bàn phím mở. Chọn Lưu để trả kết quả về trang.',
          ),
          SizedBox(height: 16),
          UITextField(label: 'Nội dung phản hồi', minLines: 3, maxLines: 6),
        ],
      ),
      actionsBuilder: (routeContext) => [
        UIButton(
          label: 'Hủy',
          variant: UIButtonVariant.ghost,
          onPressed: () => Navigator.pop(routeContext),
        ),
        UIButton(
          label: 'Lưu phản hồi mẫu',
          onPressed: () => Navigator.pop(routeContext, 'Đã lưu phản hồi mẫu'),
        ),
      ],
    );
    if (mounted) setState(() => result = answer ?? 'Đã đóng, không lưu');
  }

  @override
  Widget build(BuildContext context) => DemoBlock(
    number: '15',
    title: 'Dialog & Sheet',
    description: 'Mobile mở sheet, vùng rộng mở dialog. Có thể chọn kiểu trình bày, nội dung, thao tác và kết quả trả về.',
    effects: 'Route native · focus bàn phím · tránh bàn phím · giới hạn vùng cuộn · reduced motion',
    code: "final accepted = await UIAdaptiveDialog.confirm(context,\n  title: 'Lưu thay đổi?', message: 'Nội dung đã sẵn sàng.',\n  confirmLabel: 'Lưu');\nif (accepted) { await save(); }",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UIActions(
          children: [
            UIButton(
              label: 'Mở tự động',
              icon: Icons.open_in_new,
              onPressed: () => open(UIPresentation.auto),
            ),
            UIButton(
              label: 'Dialog',
              variant: UIButtonVariant.outline,
              onPressed: () => open(UIPresentation.dialog),
            ),
            UIButton(
              label: 'Bottom Sheet',
              variant: UIButtonVariant.outline,
              onPressed: () => open(UIPresentation.sheet),
            ),
            UIButton(
              label: 'Xác nhận thao tác',
              variant: UIButtonVariant.soft,
              onPressed: () async {
                final answer = await UIAdaptiveDialog.confirm(
                  context,
                  title: 'Lưu thay đổi?',
                  message: 'Đây là ví dụ xác nhận, không gửi dữ liệu thật.',
                  confirmLabel: 'Lưu',
                );
                if (mounted) {
                  setState(
                    () =>
                        result = answer ? 'Đã xác nhận lưu' : 'Đã hủy xác nhận',
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(result),
      ],
    ),
  );
}

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});
  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime? date;
  DateTimeRange? range;
  int submitted = 0;
  String format(DateTime value) => '${value.day}/${value.month}/${value.year}';
  @override
  Widget build(BuildContext context) => Localizations.override(
    context: context,
    locale: const Locale('vi'),
    child: Builder(
      builder: (context) => DemoBlock(
        number: '16',
        title: 'Date Picker',
        description: 'Chọn ngày hoặc khoảng ngày bằng lịch native. Trường ngày tích hợp validation, xóa lựa chọn và lỗi theo tên trong UIForm.',
        effects: 'Ngày không kèm giờ · giới hạn khoảng · loại trừ ngày · bàn phím · tiếng Việt / locale ứng dụng',
        code: "UIDateField(label: 'Ngày bắt đầu', value: startDate,\n  onChanged: (date) => setState(() => startDate = date),\n  firstDate: DateTime(2026), lastDate: DateTime(2030, 12, 31),\n  validator: (date) => date == null ? 'Hãy chọn ngày' : null);\n\nfinal range = await UIDatePicker.range(context);",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UIForm(
              submitLabel: 'Kiểm tra ngày đã chọn',
              maxColumns: 1,
              onSubmit: () async {
                setState(() => submitted++);
              },
              children: [
                UIDateField(
                  name: 'startDate',
                  label: 'Ngày bắt đầu',
                  value: date,
                  onChanged: (value) => setState(() => date = value),
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2030, 12, 31),
                  helper: 'Trong năm 2026–2030, chỉ chọn thứ Hai đến thứ Sáu.',
                  selectableDayPredicate: (value) =>
                      value.weekday <= DateTime.friday,
                  validator: (value) =>
                      value == null ? 'Hãy chọn một ngày làm việc.' : null,
                ),
                UIDateField(
                  label: 'Ngày chỉ đọc',
                  value: DateTime(2026, 11, 25),
                  helper: 'Không có callback nên không thể sửa.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Đã xác thực: $submitted lần'),
            const SizedBox(height: 16),
            UIButton(
              label: 'Chọn khoảng ngày',
              icon: Icons.date_range_outlined,
              variant: UIButtonVariant.outline,
              onPressed: () async {
                final selected = await UIDatePicker.range(
                  context,
                  initialRange: range,
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2030, 12, 31),
                  title: 'Khoảng thời gian',
                );
                if (mounted && selected != null) {
                  setState(() => range = selected);
                }
              },
            ),
            if (range != null) ...[
              const SizedBox(height: 12),
              Text('${format(range!.start)} — ${format(range!.end)}'),
            ],
          ],
        ),
      ),
    ),
  );
}
