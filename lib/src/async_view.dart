import 'dart:async';

import 'package:flutter/material.dart';

import 'state_view.dart';

abstract interface class _UIAsyncOwner {
  bool get isLoading;
  Future<bool> reload();
}

/// Optional caller-owned reload handle. Attach to one UIAsyncView at a time.
/// It owns no HTTP client or credentials. Dispose after unmounting its view.
class UIAsyncController extends ChangeNotifier {
  _UIAsyncOwner? _owner;
  bool _disposed = false;
  bool get isLoading => _owner?.isLoading ?? false;

  /// True on a current successful load (including empty results). False when
  /// detached, disposed, superseded, or failed. Concurrent calls share one load.
  Future<bool> reload() =>
      _disposed ? Future.value(false) : _owner?.reload() ?? Future.value(false);

  void _attach(_UIAsyncOwner owner) {
    if (_disposed || _owner != null) {
      throw FlutterError(
        'Use one live UIAsyncController per mounted UIAsyncView.',
      );
    }
    _owner = owner;
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _owner = null;
    super.dispose();
  }
}

enum _Phase { loading, data, empty, error }

/// Connect any Future-based API/repository to loading, retry, empty and data UI.
/// Loads once after mounting, then on requestKey changes or explicit reload.
/// Rebuilding with a new load closure alone does not start another request.
class UIAsyncView<T> extends StatefulWidget {
  const UIAsyncView({
    super.key,
    required this.load,
    required this.builder,
    this.requestKey,
    this.controller,
    this.isEmpty,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onError,
    this.failureMessage = 'Chưa thể tải dữ liệu. Vui lòng thử lại.',
  });

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;

  /// Stable immutable identity of account/query/record. Change it when inputs
  /// change; obsolete responses cannot replace the new request's UI.
  final Object? requestKey;
  final UIAsyncController? controller;
  final bool Function(T data)? isEmpty;
  final WidgetBuilder? loadingBuilder, emptyBuilder;
  final Widget Function(
    BuildContext context,
    Object error,
    Future<bool> Function() retry,
  )?
  errorBuilder;
  final void Function(Object error, StackTrace stack)? onError;
  final String failureMessage;

  @override
  State<UIAsyncView<T>> createState() => _UIAsyncViewState<T>();
}

class _UIAsyncViewState<T> extends State<UIAsyncView<T>>
    implements _UIAsyncOwner {
  late UIAsyncController _controller;
  _Phase _phase = _Phase.loading;
  T? _data;
  Object? _error;
  int _generation = 0;
  Completer<bool>? _pending;

  @override
  bool get isLoading => _phase == _Phase.loading;

  void _attach() {
    _controller = widget.controller ?? UIAsyncController();
    _controller._attach(this);
  }

  void _detach(bool owned) {
    if (!identical(_controller._owner, this)) return;
    _controller._owner = null;
    if (owned) _controller.dispose();
  }

  void _invalidate() {
    _generation++;
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) pending.complete(false);
    _data = null;
    _error = null;
  }

  @override
  void initState() {
    super.initState();
    _attach();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant UIAsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller == null);
      _attach();
    }
    if (oldWidget.requestKey != widget.requestKey) {
      _invalidate();
      _phase = _Phase.loading;
      _schedule();
    }
  }

  void _schedule() {
    final generation = _generation;
    final pending = _pending = Completer<bool>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation) return;
      _controller._emit();
      unawaited(_run(generation, pending));
    });
  }

  @override
  Future<bool> reload() {
    if (!mounted) return Future.value(false);
    if (_pending != null) return _pending!.future;
    _invalidate();
    final pending = _pending = Completer<bool>();
    setState(() => _phase = _Phase.loading);
    _controller._emit();
    unawaited(_run(_generation, pending));
    return pending.future;
  }

  Future<void> _run(int generation, Completer<bool> pending) async {
    bool current() => mounted && generation == _generation;
    var success = false;
    try {
      final result = await widget.load();
      if (!current()) return;
      final empty = widget.isEmpty?.call(result) ?? false;
      setState(() {
        _data = result;
        _phase = empty ? _Phase.empty : _Phase.data;
      });
      success = true;
    } catch (error, stack) {
      if (!current()) return;
      setState(() {
        _error = error;
        _phase = _Phase.error;
      });
      try {
        widget.onError?.call(error, stack);
      } catch (callbackError, callbackStack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: callbackError,
            stack: callbackStack,
            library: 'youth_ui',
            context: ErrorDescription('while reporting an API load failure'),
          ),
        );
      }
    } finally {
      if (current()) {
        _pending = null;
        _controller._emit();
      }
      if (!pending.isCompleted) pending.complete(success && current());
    }
  }

  @override
  void dispose() {
    _invalidate();
    _detach(widget.controller == null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (_phase) {
    _Phase.loading =>
      widget.loadingBuilder?.call(context) ?? const UIStateView.loading(),
    _Phase.empty =>
      widget.emptyBuilder?.call(context) ??
          UIStateView.empty(
            actionLabel: 'Tải lại',
            onAction: () => unawaited(reload()),
          ),
    _Phase.error =>
      widget.errorBuilder?.call(context, _error!, reload) ??
          UIStateView.error(
            message: widget.failureMessage,
            onAction: () => unawaited(reload()),
          ),
    _Phase.data => widget.builder(context, _data as T),
  };
}
