part of 'components.dart';

/// Expected backend failure. Field names match UITextField/UIPasswordField.name.
class UIFormException implements Exception {
  const UIFormException({this.message, this.fieldErrors = const {}});
  final String? message;
  final Map<String, String> fieldErrors;
}

/// Optional consumer-owned controller. Attach to only one mounted UIForm.
class UIFormController extends ChangeNotifier {
  _UIFormState? _owner;
  bool _submitting = false;
  String? _error;
  Map<String, String> _errors = const {};
  bool get isSubmitting => _submitting;
  String? get error => _error;
  Map<String, String> get fieldErrors => _errors;
  Future<bool> submit() => _owner?._submit() ?? Future.value(false);

  void _emit() => notifyListeners();

  void _clearFieldError(String name) {
    if (!_errors.containsKey(name)) return;
    _errors = Map.unmodifiable({..._errors}..remove(name));
    notifyListeners();
  }
}

class _UIFormScope extends InheritedNotifier<UIFormController> {
  const _UIFormScope({
    required UIFormController controller,
    required super.child,
  }) : super(notifier: controller);
  static UIFormController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UIFormScope>()?.notifier;
}

/// Compatible with layout-only UIForm; onSubmit enables managed submission.
/// The callback owns networking and throws UIFormException for expected failures.
class UIForm extends StatefulWidget {
  const UIForm({
    super.key,
    required this.children,
    this.formKey,
    this.controller,
    this.onSubmit,
    this.onSuccess,
    this.onError,
    this.submitLabel = 'Lưu thay đổi',
    this.maxColumns = 2,
    this.failureMessage = 'Chưa thể gửi dữ liệu. Vui lòng thử lại.',
  }) : assert(maxColumns > 0);
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;
  final UIFormController? controller;
  final Future<void> Function()? onSubmit;
  final VoidCallback? onSuccess;
  final void Function(Object, StackTrace)? onError;
  final String submitLabel, failureMessage;
  final int maxColumns;
  @override
  State<UIForm> createState() => _UIFormState();
}

class _UIFormState extends State<UIForm> {
  final _key = GlobalKey<FormState>();
  late UIFormController _controller;
  int _generation = 0;
  GlobalKey<FormState> get _formKey => widget.formKey ?? _key;
  void _attach() {
    _controller = widget.controller ?? UIFormController();
    if (_controller._owner != null) {
      throw FlutterError('A UIFormController can only attach to one UIForm.');
    }
    _controller._owner = this;
  }

  void _detach({required bool owned}) {
    _generation++;
    _controller._owner = null;
    _controller._submitting = false;
    _controller._errors = const {};
    _controller._error = null;
    if (owned) _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(covariant UIForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detach(owned: oldWidget.controller == null);
      _attach();
    }
  }

  @override
  void dispose() {
    _detach(owned: widget.controller == null);
    super.dispose();
  }

  void _focusInvalid(Set<FormFieldState<Object?>> invalid) {
    if (invalid.isEmpty) return;
    final first = invalid.first;
    FocusNode? focus;
    void visit(Element element) {
      if (focus != null) return;
      final child = element.widget;
      if (child is EditableText) focus = child.focusNode;
      if (child is Focus && child.focusNode?.canRequestFocus == true) {
        focus = child.focusNode;
      }
      if (focus == null) element.visitChildren(visit);
    }

    (first.context as Element).visitChildren(visit);
    focus?.requestFocus();
    unawaited(
      Scrollable.ensureVisible(
        first.context,
        alignment: .15,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
      ),
    );
  }

  Future<bool> _submit() async {
    if (_controller.isSubmitting || widget.onSubmit == null) return false;
    final invalid = _formKey.currentState?.validateGranularly();
    if (invalid == null) return false;
    if (invalid.isNotEmpty) {
      _focusInvalid(invalid);
      return false;
    }
    final controller = _controller;
    final generation = ++_generation;
    bool current() => mounted && generation == _generation;
    controller._submitting = true;
    controller._error = null;
    controller._errors = const {};
    controller._emit();
    try {
      await widget.onSubmit!();
    } catch (error, stack) {
      if (!current()) return false;
      if (error is UIFormException) {
        controller._errors = Map.unmodifiable(error.fieldErrors);
        controller._error =
            error.message ??
            (error.fieldErrors.isEmpty
                ? widget.failureMessage
                : 'Kiểm tra các trường được đánh dấu.');
      } else {
        controller._error = widget.failureMessage;
        widget.onError?.call(error, stack);
      }
      return false;
    } finally {
      if (current()) {
        controller._submitting = false;
        controller._emit();
        if (controller.fieldErrors.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (current()) {
              _focusInvalid(_formKey.currentState!.validateGranularly());
            }
          });
        }
      }
    }
    if (!current()) return false;
    widget.onSuccess?.call();
    return true;
  }

  @override
  Widget build(BuildContext context) => _UIFormScope(
    controller: _controller,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_controller.error != null) ...[
              UIAlert(
                title: 'Chưa hoàn tất',
                message: _controller.error!,
                tone: UITone.danger,
              ),
              const SizedBox(height: 16),
            ],
            // Block custom controls too, without replacing or clearing their state.
            AbsorbPointer(
              key: const ValueKey('ui-form-fields'),
              absorbing: _controller.isSubmitting,
              child: ExcludeFocus(
                excluding: _controller.isSubmitting,
                child: UIGrid(
                  maxColumns: widget.maxColumns,
                  children: widget.children,
                ),
              ),
            ),
            if (widget.onSubmit != null) ...[
              const SizedBox(height: 20),
              UIActions(
                children: [
                  UIButton(
                    label: widget.submitLabel,
                    icon: Icons.check_rounded,
                    loading: _controller.isSubmitting,
                    onPressed: () => unawaited(_submit()),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Small composable validators. Business rules remain with the application.
abstract final class UIValidators {
  static FormFieldValidator<String> required({
    String message = 'Vui lòng nhập thông tin.',
  }) =>
      (value) => (value?.trim().isEmpty ?? true) ? message : null;
  static FormFieldValidator<String> email({
    String message = 'Nhập email hợp lệ.',
  }) =>
      (value) =>
          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
          ? null
          : message;
  static FormFieldValidator<String> minLength(int length, {String? message}) {
    if (length < 0) throw ArgumentError.value(length, 'length');
    return (value) => (value?.characters.length ?? 0) < length
        ? message ?? 'Cần ít nhất $length ký tự.'
        : null;
  }

  static FormFieldValidator<String> combine(
    List<FormFieldValidator<String>> validators,
  ) => (value) {
    for (final validate in validators) {
      final error = validate(value);
      if (error != null) return error;
    }
    return null;
  };
}
