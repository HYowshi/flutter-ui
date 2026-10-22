part of 'components.dart';

/// One visible notification at a time, deduplicated while active or queued.
/// Uses the nearest ScaffoldMessenger; no global app state or timer loop.
abstract final class UINotice {
  static final _queues = Expando<_UINoticeQueue>();

  /// Returns false when duplicate or the bounded queue (five items) is full.
  /// Supply id when identical wording represents distinct operations.
  static bool show(
    BuildContext context, {
    required String message,
    String? id,
    UITone tone = UITone.primary,
    String? actionLabel,
    VoidCallback? onAction,
    bool? persistent,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (message.trim().isEmpty) {
      throw ArgumentError('message must not be blank');
    }
    if ((actionLabel == null) != (onAction == null) ||
        actionLabel?.trim().isEmpty == true) {
      throw ArgumentError(
        'Provide a non-empty actionLabel and onAction together.',
      );
    }
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration');
    }
    final messenger = ScaffoldMessenger.of(context);
    final queue = _queues[messenger] ??= _UINoticeQueue(messenger);
    final key = id ?? '$tone|$message|$actionLabel';
    if (queue.items.length >= 5 || queue.items.any((item) => item.id == key)) {
      return false;
    }
    final width = MediaQuery.sizeOf(context).width;
    var actionUsed = false;
    final item = _UINoticeItem(key);
    item.bar = SnackBar(
      onVisible: () => queue.didShow(item),
      behavior: SnackBarBehavior.floating,
      width: width >= 600 ? math.min(560, width - 48) : null,
      duration: duration,
      persist: persistent ?? (onAction != null || tone == UITone.danger),
      showCloseIcon: true,
      content: Builder(
        builder: (context) {
          if (item.cancelled) return const SizedBox.shrink();
          final colors = tone.colors(context);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.soft,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        _noticeIcon(tone),
                        size: 18,
                        color: colors.onSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(message)),
                ],
              ),
              if (onAction != null) ...[
                const SizedBox(height: 4),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .inversePrimary,
                  ),
                  onPressed: () {
                    if (actionUsed || item.cancelled) return;
                    actionUsed = true;
                    messenger.hideCurrentSnackBar(
                      reason: SnackBarClosedReason.action,
                    );
                    onAction();
                  },
                  child: Text(actionLabel!),
                ),
              ],
            ],
          );
        },
      ),
    );
    queue.items.add(item);
    queue.showNext();
    return true;
  }

  /// Clears only notices created through this helper, not other SnackBars.
  static void clear(BuildContext context) {
    final queue = _queues[ScaffoldMessenger.of(context)];
    if (queue == null) return;
    queue.clear();
  }

  /// Clears both helper and native SnackBars in this messenger atomically.
  /// Use this instead of calling the native clearSnackBars directly when mixing
  /// both APIs: Flutter does not complete closed futures of discarded queue items.
  static void clearAll(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    _queues[messenger]?.reset();
    messenger.clearSnackBars();
  }
}

IconData _noticeIcon(UITone tone) => switch (tone) {
  UITone.success => Icons.check_circle_outline,
  UITone.warning => Icons.warning_amber_rounded,
  UITone.danger => Icons.error_outline,
  _ => Icons.info_outline,
};

class _UINoticeItem {
  _UINoticeItem(this.id);
  final String id;
  late final SnackBar bar;
  bool visible = false, cancelled = false;
}

class _UINoticeQueue {
  _UINoticeQueue(this.messenger);
  final ScaffoldMessengerState messenger;
  final List<_UINoticeItem> items = [];
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? active;
  _UINoticeItem? activeItem;
  int generation = 0;

  void reset() {
    generation++;
    activeItem?.cancelled = true;
    items.clear();
    active = null;
    activeItem = null;
  }

  void didShow(_UINoticeItem item) {
    item.visible = true;
    if (item.cancelled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close(item));
    }
  }

  void _close(_UINoticeItem item) {
    // Let a native removal settle before calling a controller that only closes
    // the current bar. A helper bar can still be queued behind an external one.
    scheduleMicrotask(() {
      if (messenger.mounted && identical(activeItem, item) && item.visible) {
        active?.close();
      }
    });
  }

  void clear() {
    items.clear();
    final item = activeItem;
    if (item == null) return;
    item.cancelled = true;
    if (item.visible) _close(item);
  }

  void showNext() {
    if (active != null || items.isEmpty) return;
    if (!messenger.mounted) {
      items.clear();
      return;
    }
    final current = items.first;
    final token = generation;
    activeItem = current;
    active = messenger.showSnackBar(current.bar);
    unawaited(
      active!.closed.then((_) {
        if (token != generation) return;
        active = null;
        activeItem = null;
        if (items.isNotEmpty && identical(items.first, current)) {
          items.removeAt(0);
        }
        showNext();
      }),
    );
  }
}
