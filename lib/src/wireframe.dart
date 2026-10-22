import 'package:flutter/material.dart';

import 'adaptive.dart';

enum UIWireframeLayout { feed, dashboard, form }

/// Static, theme-aware layout blocks. No shimmer tickers or network requests.
class UIWireframe extends StatelessWidget {
  const UIWireframe.line({super.key, this.widthFactor = 1, this.height = 12})
    : assert(widthFactor > 0 && widthFactor <= 1),
      assert(height > 0),
      _kind = 'line',
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.image({super.key, this.height = 140})
    : assert(height > 0),
      _kind = 'image',
      widthFactor = 1,
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.avatar({super.key, double size = 48})
    : assert(size > 0),
      height = size,
      _kind = 'avatar',
      widthFactor = 1,
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.card({super.key})
    : _kind = 'card',
      widthFactor = 1,
      height = 12,
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.list({super.key, this.count = 3})
    : assert(count >= 0),
      _kind = 'list',
      widthFactor = 1,
      height = 12,
      layout = UIWireframeLayout.feed;
  const UIWireframe.page({super.key, this.layout = UIWireframeLayout.feed})
    : _kind = 'page',
      widthFactor = 1,
      height = 12,
      count = 3;
  final String _kind;
  final double widthFactor, height;
  final int count;
  final UIWireframeLayout layout;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    Widget block({
      required double height,
      double? width,
      bool circle = false,
      IconData? icon,
    }) => Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: s.surfaceContainerHigh,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(circle ? height : 8),
      ),
      child: icon == null
          ? null
          : Center(child: Icon(icon, color: s.onSurfaceVariant, size: 24)),
    );
    Widget content;
    switch (_kind) {
      case 'line':
        content = Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: block(height: height),
          ),
        );
      case 'avatar':
        content = block(
          height: height,
          width: height,
          circle: true,
          icon: Icons.person_outline_rounded,
        );
      case 'image':
        content = block(height: height, icon: Icons.image_outlined);
      case 'list':
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              const Row(
                children: [
                  UIWireframe.avatar(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        UIWireframe.line(widthFactor: .7),
                        SizedBox(height: 8),
                        UIWireframe.line(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      case 'card':
        content = DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: s.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UIWireframe.image(),
                SizedBox(height: 16),
                UIWireframe.line(widthFactor: .7),
                SizedBox(height: 10),
                UIWireframe.line(height: 8),
              ],
            ),
          ),
        );
      default:
        content = UIGrid(
          maxColumns: layout == UIWireframeLayout.form ? 2 : 3,
          children: [
            if (layout == UIWireframeLayout.feed) ...const [
              UIWireframe.card(),
              UIWireframe.card(),
              UIWireframe.card(),
            ] else if (layout == UIWireframeLayout.dashboard) ...const [
              UIWireframe.image(height: 96),
              UIWireframe.image(height: 96),
              UIWireframe.image(height: 96),
              UIWireframe.list(),
              UIWireframe.list(),
              UIWireframe.list(),
            ] else ...const [
              UIWireframe.image(height: 56),
              UIWireframe.image(height: 56),
              UIWireframe.image(height: 56),
              UIWireframe.image(height: 56),
            ],
          ],
        );
    }
    return Semantics(
      label: 'Wireframe',
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: _kind == 'avatar'
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
