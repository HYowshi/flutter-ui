import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'components.dart';
import 'color_engine.dart';
import 'theme.dart';

enum UIStateKind { loading, empty, error, offline, forbidden, success }

/// An explicit UI state, not a network/connectivity detector. Owns no requests.
class UIStateView extends StatelessWidget {
  const UIStateView({
    super.key,
    required this.kind,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.progress,
  }) : assert(progress == null || progress >= 0 && progress <= 1),
       assert((secondaryActionLabel == null) == (onSecondaryAction == null));

  const UIStateView.loading({
    super.key,
    this.title,
    this.message,
    this.progress,
    this.illustration,
    this.actionLabel,
    this.onAction,
  }) : kind = UIStateKind.loading,
       secondaryActionLabel = null,
       onSecondaryAction = null,
       assert(progress == null || progress >= 0 && progress <= 1);
  const UIStateView.empty({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  }) : kind = UIStateKind.empty,
       progress = null,
       secondaryActionLabel = null,
       onSecondaryAction = null;
  const UIStateView.error({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  }) : kind = UIStateKind.error,
       progress = null,
       secondaryActionLabel = null,
       onSecondaryAction = null;
  const UIStateView.offline({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  }) : kind = UIStateKind.offline,
       progress = null,
       secondaryActionLabel = null,
       onSecondaryAction = null;
  const UIStateView.forbidden({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  }) : kind = UIStateKind.forbidden,
       progress = null,
       secondaryActionLabel = null,
       onSecondaryAction = null;
  const UIStateView.success({
    super.key,
    this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
  }) : kind = UIStateKind.success,
       progress = null,
       secondaryActionLabel = null,
       onSecondaryAction = null;

  final UIStateKind kind;
  final String? title, message, actionLabel, secondaryActionLabel;
  final Widget? illustration;
  final VoidCallback? onAction, onSecondaryAction;
  final double? progress;

  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      final s = Theme.of(context).colorScheme;
      final (defaultTitle, icon, tone, defaultAction) = switch (kind) {
        UIStateKind.loading => (
          'Đang tải',
          Icons.hourglass_top_rounded,
          UITone.primary,
          'Hủy',
        ),
        UIStateKind.empty => (
          'Chưa có nội dung',
          Icons.inbox_outlined,
          UITone.primary,
          'Tạo mới',
        ),
        UIStateKind.error => (
          'Chưa thể hoàn tất',
          Icons.error_outline_rounded,
          UITone.danger,
          'Thử lại',
        ),
        UIStateKind.offline => (
          'Bạn đang ngoại tuyến',
          Icons.wifi_off_rounded,
          UITone.warning,
          'Kết nối lại',
        ),
        UIStateKind.forbidden => (
          'Chưa có quyền truy cập',
          Icons.lock_outline_rounded,
          UITone.warning,
          'Yêu cầu quyền',
        ),
        UIStateKind.success => (
          'Đã hoàn tất',
          Icons.check_circle_outline_rounded,
          UITone.success,
          'Tiếp tục',
        ),
      };
      final colors = tone.colors(context);
      final reduced = MediaQuery.disableAnimationsOf(context);
      final visual =
          illustration ??
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.soft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: kind == UIStateKind.loading && !reduced
                  ? SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        color: colors.onSoft,
                        semanticsLabel: title ?? defaultTitle,
                      ),
                    )
                  : Icon(icon, size: 32, color: colors.onSoft),
            ),
          );
      return Center(
        child: SingleChildScrollView(
          primary: false,
          padding: EdgeInsets.all(ui.compact ? 20 : 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: ExcludeSemantics(child: visual)),
                const SizedBox(height: 20),
                Semantics(
                  liveRegion:
                      kind == UIStateKind.loading || kind == UIStateKind.error,
                  header: true,
                  child: Text(
                    title ?? defaultTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: s.onSurfaceVariant, height: 1.6),
                  ),
                ],
                if (kind == UIStateKind.loading && progress != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${(progress! * 100).round()}%',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (onAction != null || onSecondaryAction != null) ...[
                  const SizedBox(height: 24),
                  UIActions(
                    children: [
                      if (onAction != null)
                        UIButton(
                          label: actionLabel ?? defaultAction,
                          tone: tone,
                          onPressed: onAction,
                        ),
                      if (onSecondaryAction != null)
                        UIButton(
                          label: secondaryActionLabel!,
                          variant: UIButtonVariant.ghost,
                          onPressed: onSecondaryAction,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
