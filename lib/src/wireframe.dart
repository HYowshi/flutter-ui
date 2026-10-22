import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'wireframe_inference.dart';

export 'wireframe_inference.dart';

/// Static, theme-aware layout blocks. No shimmer tickers or network requests.
class UIWireframe extends StatelessWidget {
  const UIWireframe.line({super.key, this.widthFactor = 1, this.height = 12})
    : assert(widthFactor > 0 && widthFactor <= 1),
      assert(height > 0),
      _plan = null,
      _kind = 'line',
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.image({super.key, this.height = 140})
    : assert(height > 0),
      _plan = null,
      _kind = 'image',
      widthFactor = 1,
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.avatar({super.key, double size = 48})
    : assert(size > 0),
      height = size,
      _plan = null,
      _kind = 'avatar',
      widthFactor = 1,
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.card({super.key})
    : _plan = null,
      _kind = 'card',
      widthFactor = 1,
      height = 12,
      count = 1,
      layout = UIWireframeLayout.feed;
  const UIWireframe.list({super.key, this.count = 3})
    : assert(count >= 0),
      _plan = null,
      _kind = 'list',
      widthFactor = 1,
      height = 12,
      layout = UIWireframeLayout.feed;
  const UIWireframe.page({super.key, this.layout = UIWireframeLayout.feed})
    : _plan = null,
      _kind = 'page',
      widthFactor = 1,
      height = 12,
      count = 3;

  /// Infer a static layout from a JSON-like sample; no input values are shown.
  factory UIWireframe.auto({
    Key? key,
    Object? data,
    UIWireframeLayout? layout,
    List<UIWireframeField> fields = const [],
    Map<String, UIWireframeFieldType> fieldTypes = const {},
    int itemCount = 3,
  }) => UIWireframe.fromPlan(
    key: key,
    plan: inspect(
      data,
      layout: layout,
      fields: fields,
      fieldTypes: fieldTypes,
      itemCount: itemCount,
    ),
  );

  // The named parameter is public; the nullable storage also serves block constructors.
  UIWireframe.fromPlan({super.key, required UIWireframePlan plan})
    // ignore: prefer_initializing_formals
    : _plan = plan,
      _kind = 'auto',
      widthFactor = 1,
      height = 12,
      count = plan.itemCount,
      layout = plan.layout;

  static UIWireframePlan inspect(
    Object? data, {
    UIWireframeLayout? layout,
    List<UIWireframeField> fields = const [],
    Map<String, UIWireframeFieldType> fieldTypes = const {},
    int itemCount = 3,
  }) => UIWireframeInference.inspect(
    data,
    layout: layout,
    fields: fields,
    fieldTypes: fieldTypes,
    itemCount: itemCount,
  );

  final UIWireframePlan? _plan;
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
        content = _WireframeContent(
          plan:
              _plan ??
              UIWireframePlan(
                layout: layout,
                confidence: UIWireframeConfidence.explicit,
                reasons: const ['Preset'],
                fields: const [],
                itemCount: count,
              ),
        );
    }
    return Semantics(
      label: _kind == 'auto' ? 'Wireframe ${_plan!.layout.name}' : 'Wireframe',
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

class _WireframeContent extends StatelessWidget {
  const _WireframeContent({required this.plan});
  final UIWireframePlan plan;

  @override
  Widget build(BuildContext context) => UIAdaptiveBuilder(
    builder: (context, ui) {
      final scheme = Theme.of(context).colorScheme;
      Widget stack(List<Widget> children, {double gap = 16}) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      );
      Widget panel(Widget child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
      Widget slab(double height, {double? width, IconData? icon}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon == null
            ? null
            : Center(
                child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
              ),
      );
      const title = UIWireframe.line(widthFactor: .6, height: 18);
      Widget paragraph() => stack(const [
        UIWireframe.line(height: 8),
        UIWireframe.line(height: 8),
        UIWireframe.line(widthFactor: .75, height: 8),
      ], gap: 10);
      Widget field(UIWireframeFieldType type) {
        final control = switch (type) {
          UIWireframeFieldType.avatar => const UIWireframe.avatar(),
          UIWireframeFieldType.image => const UIWireframe.image(height: 120),
          UIWireframeFieldType.paragraph => slab(96),
          UIWireframeFieldType.toggle => Align(
            alignment: AlignmentDirectional.centerEnd,
            child: slab(28, width: 48, icon: Icons.toggle_on_outlined),
          ),
          UIWireframeFieldType.date => slab(
            48,
            icon: Icons.calendar_today_outlined,
          ),
          UIWireframeFieldType.choice => slab(48, icon: Icons.expand_more),
          UIWireframeFieldType.password => slab(48, icon: Icons.lock_outline),
          UIWireframeFieldType.section => panel(paragraph()),
          _ => slab(48),
        };
        return stack([
          const UIWireframe.line(widthFactor: .4, height: 8),
          control,
        ], gap: 10);
      }

      final fields = plan.fields.isEmpty
          ? const [
              UIWireframeField('title'),
              UIWireframeField('description'),
              UIWireframeField('date', type: UIWireframeFieldType.date),
              UIWireframeField('enabled', type: UIWireframeFieldType.toggle),
            ]
          : plan.fields;
      Widget records() => UIWireframe.list(count: plan.itemCount);
      // The parent still owns scrolling. No nested viewport or intrinsic sizing.
      if (ui.width < 48) return const SizedBox.shrink();
      final content = switch (plan.layout) {
        UIWireframeLayout.feed => UIGrid(
          maxColumns: 3,
          children: [
            for (var i = 0; i < plan.itemCount; i++) const UIWireframe.card(),
          ],
        ),
        UIWireframeLayout.dashboard => stack([
          UIGrid(
            maxColumns: 4,
            children: [
              for (var i = 0; i < 4; i++)
                panel(
                  stack([
                    const UIWireframe.line(widthFactor: .5, height: 8),
                    const UIWireframe.line(widthFactor: .7, height: 26),
                  ]),
                ),
            ],
          ),
          slab(180, icon: Icons.bar_chart_rounded),
          records(),
        ]),
        UIWireframeLayout.form => panel(
          stack([
            title,
            UIGrid(
              maxColumns: 2,
              children: [for (final f in fields) field(f.type)],
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: slab(44, width: 120),
            ),
          ]),
        ),
        UIWireframeLayout.profile => panel(
          stack([
            const UIWireframe.image(height: 100),
            const UIWireframe.avatar(size: 64),
            title,
            paragraph(),
            UIGrid(
              maxColumns: 2,
              children: [for (final f in fields.take(6)) field(f.type)],
            ),
          ]),
        ),
        UIWireframeLayout.article => panel(
          stack([
            title,
            const UIWireframe.line(widthFactor: .35, height: 8),
            if (fields.any((f) => f.type == UIWireframeFieldType.image) ||
                plan.fields.isEmpty)
              const UIWireframe.image(height: 180),
            paragraph(),
            paragraph(),
            paragraph(),
          ]),
        ),
        UIWireframeLayout.product => UIGrid(
          maxColumns: 2,
          children: [
            const UIWireframe.image(height: 240),
            panel(
              stack([
                title,
                const UIWireframe.line(widthFactor: .3, height: 24),
                paragraph(),
                slab(44),
              ]),
            ),
          ],
        ),
        UIWireframeLayout.gallery => UIGrid(
          maxColumns: 4,
          minItemWidth: 160,
          children: [
            for (var i = 0; i < plan.itemCount; i++)
              const AspectRatio(aspectRatio: 1, child: UIWireframe.image()),
          ],
        ),
        UIWireframeLayout.chat => panel(
          stack([
            for (var i = 0; i < plan.itemCount; i++)
              Align(
                alignment: i.isEven
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child: FractionallySizedBox(
                  widthFactor: .78,
                  child: panel(paragraph()),
                ),
              ),
            slab(48),
          ]),
        ),
        UIWireframeLayout.table =>
          ui.compact || ui.textScale > 1.5
              ? stack([
                  for (var i = 0; i < plan.itemCount; i++)
                    panel(
                      stack([for (final f in fields.take(6)) field(f.type)]),
                    ),
                ])
              : panel(
                  stack([
                    for (var i = 0; i <= plan.itemCount; i++)
                      Row(
                        children: [
                          for (var j = 0; j < fields.length.clamp(1, 6); j++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: UIWireframe.line(
                                  height: i == 0 ? 14 : 8,
                                  widthFactor: .8,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ]),
                ),
        UIWireframeLayout.settings => panel(
          stack([title, for (final f in fields) field(f.type)]),
        ),
        UIWireframeLayout.timeline => panel(
          stack([
            for (var i = 0; i < plan.itemCount; i++)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  slab(24, width: 24, icon: Icons.circle_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: stack([
                      const UIWireframe.line(widthFactor: .3, height: 8),
                      title,
                      paragraph(),
                    ]),
                  ),
                ],
              ),
          ]),
        ),
        UIWireframeLayout.detail => panel(
          stack([
            title,
            if (plan.fields.isEmpty)
              paragraph()
            else
              UIGrid(
                maxColumns: 2,
                children: [for (final f in fields) field(f.type)],
              ),
          ]),
        ),
        UIWireframeLayout.list => records(),
        UIWireframeLayout.empty => panel(
          stack([
            Center(
              child: Icon(
                Icons.inbox_outlined,
                size: 40,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const UIWireframe.line(widthFactor: .5),
            const UIWireframe.line(widthFactor: .7, height: 8),
          ]),
        ),
      };
      return SizedBox(width: ui.width, child: content);
    },
  );
}
